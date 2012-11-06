//
//  Shader.fsh
//  opengl
//
//  Created by Shinya Akiba on 12/10/27.
//  Copyright (c) 2012年 Shinya Akiba. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
