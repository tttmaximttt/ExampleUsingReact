module.exports = {
    entry:'./app-client.js',
    output:{
        filename:'public/bundle.js'
    },
    module:{
        loaders:[
            {
                exclude:/(node_modules|app-serve.js)/,
                loader:'babel'
            }
        ]
    }
};