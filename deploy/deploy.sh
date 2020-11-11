helm upgrade --reuse-values  --set image.tag="stable" wethex -n wethex ./wethex

# helm upgrade --install wethex -n wethex -f values.yaml ./wethex
