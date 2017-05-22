//
//  ViewController.m
//  OpenGLES5.4 变换
//
//  Created by ShiWen on 2017/5/22.
//  Copyright © 2017年 ShiWen. All rights reserved.
//

#import "ViewController.h"
#import "lowPolyAxesAndModels2.h"
#import "AGLKContext.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "lowPolyAxesAndModels2.h"
//形变量类型
typedef enum {
    ScenTransLate = 0,
    SceneRotate,
    ScenScale,
}SceneTransformationSelector;
//沿着哪个轴发生的形变量
typedef enum {
    SceneXAxis = 0,
    ScenYAxis,
    ScenZAxis,
}ScenTransformationAxisSelector;

@interface ViewController ()
{
    //第一个形变量
    SceneTransformationSelector firstType;
    ScenTransformationAxisSelector firstAxis;
    float firstValue;
    //第二个形变量
    SceneTransformationSelector secondType;
    ScenTransformationAxisSelector secondAxis;
    float secondValue;
    //第三个形变量
    SceneTransformationSelector thirdType;
    ScenTransformationAxisSelector thirdAxis;
    float thirdValue;

}
@property (nonatomic,strong) AGLKVertexAttribArrayBuffer *mVertexbuffer;
@property (nonatomic,strong) AGLKVertexAttribArrayBuffer *mNomalbuffer;

@property (weak, nonatomic) IBOutlet UISlider *firstSlied;
@property (weak, nonatomic) IBOutlet UISlider *secondSlider;
@property (weak, nonatomic) IBOutlet UISlider *thiredSlider;

@property (nonatomic,strong) GLKBaseEffect *mBassEffect;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self restoreAction];
    [self setupConfig];
}
-(void)setupConfig{
    
    GLKView *glView = (GLKView *)self.view;
    glView.drawableDepthFormat = GLKViewDrawableDepthFormat16;

    glView.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    [AGLKContext setCurrentContext:glView.context];

    [((AGLKContext*)glView.context) setClearColor:GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f)];
    
    self.mBassEffect = [[GLKBaseEffect alloc] init];
    self.mBassEffect.useConstantColor = GL_TRUE;
    self.mBassEffect.constantColor = GLKVector4Make(0.0f, 1.0f, 1.0f, 1.0f);
    self.mBassEffect.light0.enabled = GL_TRUE;
    self.mBassEffect.light0.ambientColor = GLKVector4Make(0.4, 0.4, 0.4, 1.0);
    self.mBassEffect.light0.position = GLKVector4Make(1.0f, 1.0, 1.0, 0.0f);
    self.mBassEffect.light0.diffuseColor = GLKVector4Make(0.7, 0.4, 0.4, 1.0);
    
    self.mVertexbuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(GLfloat)*3 numberOfVertices:sizeof(lowPolyAxesAndModels2Verts)/(sizeof(GLfloat)*3) bytes:lowPolyAxesAndModels2Verts usage:GL_STATIC_DRAW];
    self.mNomalbuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(GLfloat)*3 numberOfVertices:sizeof(lowPolyAxesAndModels2Normals)/sizeof(GLfloat)*3 bytes:lowPolyAxesAndModels2Normals usage:GL_STATIC_DRAW];
    self.mBassEffect.light0.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    [((AGLKContext *)glView.context) enable:GL_DEPTH_TEST];
    GLKMatrix4 modelviewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(30.0f),
                                                        1.0,  // Rotate about X axis
                                                        0.0,
                                                        0.0);
    modelviewMatrix = GLKMatrix4Rotate(modelviewMatrix,
                                       GLKMathDegreesToRadians(-30.0f),
                                       0.0,
                                       1.0,  // Rotate about Y axis
                                       0.0);
    modelviewMatrix = GLKMatrix4Translate(modelviewMatrix,
                                          0.0,
                                          0.3,
                                          0.0);
//
    self.mBassEffect.transform.modelviewMatrix = modelviewMatrix;
    
    [((AGLKContext *)glView.context) enable:GL_BLEND];
    [((AGLKContext *)glView.context)
     setBlendSourceFunction:GL_SRC_ALPHA
     destinationFunction:GL_ONE_MINUS_SRC_ALPHA];
}
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    
    GLfloat  aspectRatio =
    (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    self.mBassEffect.light0.diffuseColor = GLKVector4Make(
                                                         1.0f, // Red
                                                         0.3f, // Green
                                                         1.0f, // Blue 
                                                         1.0f);// Alpha
    self.mBassEffect.transform.projectionMatrix =
    GLKMatrix4MakeOrtho(-0.8 * aspectRatio,0.8 * aspectRatio,-0.8,0.8,-5.0,5.0);
    
    GLKMatrix4 oldMatrix = self.mBassEffect.transform.modelviewMatrix;
    
    GLKMatrix4 newMatrix = GLKMatrix4Multiply(oldMatrix, [self scenGLKMatrixFromType:firstType adAxis:firstAxis adValue:firstValue]);
    newMatrix =GLKMatrix4Multiply(newMatrix, [self scenGLKMatrixFromType:secondType adAxis:secondAxis adValue:secondValue]);
    newMatrix = GLKMatrix4Multiply(newMatrix, [self scenGLKMatrixFromType:thirdType adAxis:thirdAxis adValue:thirdValue]);
    
    self.mBassEffect.transform.modelviewMatrix = newMatrix;
    [((AGLKContext *)view.context) clear:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
    [self.mVertexbuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    [self.mNomalbuffer prepareToDrawWithAttrib:GLKVertexAttribNormal numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    [self.mBassEffect prepareToDraw];
    [AGLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:lowPolyAxesAndModels2NumVerts];
    
    // Restore the saved Modelview matrix
    self.mBassEffect.transform.modelviewMatrix =
    oldMatrix;
    
    // 设置灯光样色为蓝色
    self.mBassEffect.light0.diffuseColor = GLKVector4Make(0.0f, // Red
                                                          122.0/255.0, // Green
                                                          1.0f, // Blue
                                                          1.0f);// Alpha
    
    [self.mBassEffect prepareToDraw];
    
    // Draw triangles using vertices in the prepared vertex
    // buffers
    [AGLKVertexAttribArrayBuffer 
     drawPreparedArraysWithMode:GL_TRIANGLES
     startVertexIndex:0
     numberOfVertices:lowPolyAxesAndModels2NumVerts];
}
- (IBAction)valueChange:(UISlider *)sender {
    NSInteger tag = sender.tag;
    float value = sender.value;
    if (tag == 1) {
        firstValue = value;
    }
    if (tag == 2) {
        secondValue = value;
    }
    if (tag == 3) {
        thirdValue = value;
    }
}
- (IBAction)restoreAction {
    firstValue = 0.5f;
    secondValue = 0.5f;
    thirdValue = 0.5f;
    self.firstSlied.value = 0.5;
    self.secondSlider.value = 0.5;
    self.thiredSlider.value = 0.5;
}

//形变类型发生改变
- (IBAction)changeType:(UISegmentedControl *)sender {
    NSInteger tag = sender.tag;
    NSInteger selected = sender.selectedSegmentIndex;
    if (tag == 1) {
        switch (selected) {
            case 1:
                firstType = SceneRotate;
                break;
            case 2:
                firstType = ScenScale;
                break;
            default:
                firstType = ScenTransLate;
                break;
        }
    }
    if (tag == 2) {
        switch (selected) {
            case 1:
                secondType = SceneRotate;
                break;
            case 2:
                secondType = ScenScale;
                break;
            default:
                secondType = ScenTransLate;
                break;
        }
    }
    if (tag == 3) {
        switch (selected) {
            case 1:
                thirdType = SceneRotate;
                break;
            case 2:
                thirdType = ScenScale;
                break;
            default:
                thirdType = ScenTransLate;
                break;
        }
    }

}
///形变轴发生改变
- (IBAction)changeAxis:(UISegmentedControl *)sender {
    NSInteger tag = sender.tag;
    NSInteger selected = sender.selectedSegmentIndex;
    if (tag == 1) {
        switch (selected) {
            case 1:
                firstAxis = ScenYAxis;
                break;
            case 2:
                firstAxis = ScenZAxis;
                break;
            default:
                firstAxis = SceneXAxis;
                break;
        }
    }
    if (tag == 2) {
        switch (selected) {
            case 1:
                thirdAxis = ScenYAxis;
                break;
            case 2:
                thirdAxis = ScenZAxis;
                break;
            default:
                thirdAxis = SceneXAxis;
                break;
        }
    }
    if (tag == 3) {
        switch (selected) {
            case 1:
                thirdAxis = ScenYAxis;
                break;
            case 2:
                thirdAxis = ScenZAxis;
                break;
            default:
                thirdAxis = SceneXAxis;
                break;
        }
    }
}

-(GLKMatrix4)scenGLKMatrixFromType:(SceneTransformationSelector)type adAxis:(ScenTransformationAxisSelector)axis adValue:(float)value{
    value = value - 0.5;
    GLKMatrix4 newMatrix = GLKMatrix4Identity;
    switch (type) {
        case SceneRotate:
            //旋转
            switch (axis) {
                case ScenYAxis:
                    //Y轴变化
                    newMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(180 * value), 0, 1, 0);
                    break;
                case ScenZAxis:
                    //Z轴变化
                    newMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(180 * value), 0, 0, 1);
                    break;
                default:
                    //x轴
                    newMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(180 * value), 1, 0, 0);
                    break;
            }
            break;
        case ScenScale:
            //放大
            switch (axis) {
                case ScenYAxis:
                    //Y轴变化
                    //向哪个轴变化，改变哪个轴数据，不变为1.0
                    newMatrix = GLKMatrix4MakeScale(1.0,1.0+value,1.0);
                    break;
                case ScenZAxis:
                    //Z轴变化
                    newMatrix = GLKMatrix4MakeScale(1.0,1.0,1.0+value);
                    break;
                default:
                    //x轴
                    newMatrix = GLKMatrix4MakeScale(1.0+value,1.0,1.0);

                    break;
            }
            break;
        default:
            //平移
            switch (axis) {
                case ScenYAxis:
                    //Y轴变化
                    newMatrix = GLKMatrix4MakeTranslation(0, 0.3 * value, 0);
                    break;
                case ScenZAxis:
                    //Z轴变化
                    newMatrix = GLKMatrix4MakeTranslation(0, 0, 0.3 * value);
                    break;
                default:
                    newMatrix = GLKMatrix4MakeTranslation(0.3 * value, 0, 0);
                    break;
            }
            break;

    }

    
    
    return newMatrix;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
