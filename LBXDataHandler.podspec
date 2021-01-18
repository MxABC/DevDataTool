Pod::Spec.new do |s|
    s.name         = 'LBXDataHandler'
    s.version      = '1.0.5'
    s.summary      = 'iOS data converter,hash,encryption and decryption'
    s.homepage     = 'https://github.com/MxABC/DevDataTool'
    s.license      = 'MIT'
    s.authors      = {'MxABC' => 'lbxia20091227@foxmail.com'}
    s.platform     = :ios, '7.0'
    s.source       = {:git => 'https://github.com/MxABC/DevDataTool.git', :tag => s.version}
    s.ios.deployment_target = "7.0"

    s.requires_arc = true
    s.source_files = 'Model/LBXDataHandler/Crypto/**/*.{h,m,c}','Model/LBXDataHandler/HASH/**/*.{h,m,c}','Model/LBXDataHandler/Base64/*.{h,m,c}','Model/LBXDataHandler/Converter/*.{h,m}','Model/LBXDataHandler/*.{h,m}'
    s.ios.frameworks = 'Foundation'

end
