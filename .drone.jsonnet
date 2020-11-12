local build() = [
      {
         "name": "buildImage",
         "image": "plugins/docker",
        "settings":{
            "repo": "wethex/condenser"
            ,"tags": ["${DRONE_TAG}", "stable"]
            ,"target": "production"
            ,"username":{
               "from_secret": "docker_username"
            }
            ,"password":{
               "from_secret": "docker_password"
            }
        },
    
      }
   ];

local deploy(script='deploy') = [
   {
      "name": "deploy",
      "image": "dtzar/helm-kubectl",
      "environment": {
         "KUBERNETES_SERVICE_HOST":{
            "from_secret": "KUBERNETES_SERVICE_HOST"
         }
         ,"KUBERNETES_CA":{
            "from_secret": "KUBERNETES_CA"
         }
         ,"KUBERNETES_TOKEN":{
            "from_secret": "KUBERNETES_TOKEN"
         }
         ,"KUBERNETES_NAMESPACE":{
            "from_secret": "KUBERNETES_NAMESPACE"
         }
      },
      "commands": [
         "echo start deploy"
         ,"sh ./scripts/loadKubeConf.sh"
         ,"REPOSITORY=wethex/condenser TAG=stable sh ./scripts/"+script+".sh"
      ]
   }
];

// pipeline
[
{
   "kind": "pipeline",
   "type": "docker",
   "name": "publishStable",
   "steps":
      // notify() +
      build()
      + deploy()
      // + notify('tag status report',
      //    {
      //       "image": "docker-registry.drone:5000/ryke/server:${DRONE_TAG}",
      //       "deployUrl": "https://wow.ryke.io"
      //    },
      //    './.drone/deploy.md.tpl',
      //     {
      //       "status": [ 'success','failure']
      //    }
      // )
      
   , "trigger": {
      "ref": {
         "include": [
            "refs/tags/v*"
         ]
         ,
         "exclude": [
            "refs/tags/v*-rc*"
         ]
      }
   }
}
]