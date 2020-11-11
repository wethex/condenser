
local TAG = {
   COMMIT: '${DRONE_COMMIT_BRANCH}-${DRONE_COMMIT_SHA:0:8}',
   PR: 'PR-${DRONE_SOURCE_BRANCH}-${DRONE_COMMIT_BRANCH}-${DRONE_PULL_REQUEST}-${DRONE_COMMIT_SHA:0:8}',
   TAG: '${DRONE_TAG}',
};

local build(tag='COMMIT') = [
      {
         "name": "buildImage",
         "image": "docker",
         "commands": [
            "export IMAGE="+IMGS[tag],
            "sh ./scripts/package.sh",
            "docker push $IMAGE"
         ],
         "volumes": [
            {
               "name": "docker",
               "path": "/var/run/docker.sock"
            }
         ]
      }
   ];

local deploy(script='deploy',tag='TAG') = [
   {
      "name": "deploy",
      "image": "dtzar/helm-kubectl",
      "privileged": true,
      "volumes": [
         {
            "name": "kubesecret",
            "path": "/.kubesecret"
         },
         {
            "name": "hostEnv",
            "path": "/.hostEnv"
         }
      ],
      "commands": [
         "echo start deploy"
         ,"sh .drone/loadKubeConf.sh"
         ,"REPOSITORY=docker-registry.drone:5000/ryke/server TAG="+TAG[tag]+" sh ./scripts/"+script+".sh"
      ]
   }
];

local deployVolume=[
   {
      "name": "kubesecret",
      "host": {
         "path": "/run/secrets/kubernetes.io/serviceaccount"
      }
   },
   {
      "name": "hostEnv",
      "host": {
         "path": "/proc/1/environ"
      }
   }
];

// tag
{
   "kind": "pipeline",
   "type": "docker",
   "name": "NewTag",
   "steps":
      notify()
      +build('TAG')
      + deploy('deploy')
      + notify('tag status report',
         {
            "image": "docker-registry.drone:5000/ryke/server:${DRONE_TAG}",
            "deployUrl": "https://wow.ryke.io"
         },
         './.drone/deploy.md.tpl',
          {
            "status": [ 'success','failure']
         }
      )
      ,
   "volumes": buildVolume+deployVolume,
   "trigger": {
      "ref": {
         "include": [
            "refs/tags/v*"
         ],
         "exclude": [
            "refs/tags/v*-rc*"
         ]
      }
   }
}