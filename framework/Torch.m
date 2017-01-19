//
//  Torch.m
//

#import "Torch.h"

#import <dlfcn.h>

static const luaL_reg lualibs[] =
{
    { "libtorch",       luaopen_libtorch },
    { "libpaths",       luaopen_libpaths },
    { "libnnx",       luaopen_libnnx },
    { NULL,         NULL }
};

// function to open up all the Lua libraries you declared above
static lua_State* openlualibs(lua_State *l)
{
    luaL_openlibs(l);
    luaopen_libtorch(l);
    luaopen_libpaths(l);
//    luaopen_libthnn(l);
    luaopen_libnnx(l);
    luaopen_libsys(l);
    
//    const luaL_reg *lib;
//    for (lib = lualibs; lib->func != NULL; lib++)
//    {
//        lua_pushcfunction(l, lib->func);
//        lua_pushstring(l, lib->name);
//        lua_call(l, 1, 0);
//    }
//    lua_pop(l, 1);
    return l;
}

@implementation Torch

- (NSString *)bundleResourcesPathForFolderName:(NSString *)folderName
{
  return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:folderName];
}

- (NSString *)bundleResourcesPathForFrameworkName:(NSString *)frameworkName
{
  return [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:frameworkName] stringByAppendingPathComponent:@"Resources"];
}

- (void)addLuaPackagePathForBundlePath:(NSString *)bundlePath subdirectory:(NSString *)subdirectory
{
  // Add path for finding individual lua files
  NSMutableString *pathToAdd = [NSMutableString stringWithString:bundlePath];
  if (subdirectory.length > 0) {
    [pathToAdd appendString:@"/"];
    [pathToAdd appendString:subdirectory];
  }
  [pathToAdd appendString:@"/?.lua"];
  [self appendLuaPackagePathWithPath:pathToAdd];
  
  // Add path for finding packages that are prepared with init.lua
  pathToAdd = [NSMutableString stringWithString:bundlePath];
  if (subdirectory.length > 0) {
    [pathToAdd appendString:@"/"];
    [pathToAdd appendString:subdirectory];
  }
  [pathToAdd appendString:@"/?/init.lua"];
  [self appendLuaPackagePathWithPath:pathToAdd];
}

- (void)appendLuaPackagePathWithPath:(NSString *)pathToAdd
{
  lua_getglobal(L, "package");
  lua_getfield(L, -1, "path");
  NSString *packagePath = [NSString stringWithUTF8String:lua_tostring(L, -1)];
  
  NSMutableString *updatedPath = [[NSMutableString alloc] initWithString:packagePath];
  if (updatedPath.length > 0) {
    [updatedPath appendString:@";"];
  }
  [updatedPath appendString:pathToAdd];
  
  lua_pop(L, 1);
  lua_pushstring(L, updatedPath.UTF8String);
  lua_setfield(L, -2, "path");
  lua_pop(L, 1);
}
- (void)requireFrameworkPackage:(NSString *)package frameworkResourcesPath:(NSString *)resourcesPath
{
    NSString *path = [[resourcesPath stringByAppendingPathComponent:package] stringByAppendingPathComponent:@"init.lua"];
    int ret = luaL_dofile(L, [path UTF8String]);
    if (ret == 1) {
        NSLog(@"could not load invalid lua resource: %@\n", package);
    }
}

- (void)require:(NSString *)file inFolder:(NSString *)folderName
{
    NSString *path = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:folderName]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.lua",file]];
    int ret = luaL_dofile(L, [path UTF8String]);
    if (ret == 1) {
        NSLog(@"could not load invalid lua resource: %@\n", file);
    }
}

- (void)initialize
{
  // initialize Lua stack
  //lua_executable_dir("./lua");
    
  L = lua_open();
    
   void *address =  dlsym(RTLD_DEFAULT, "THNN_DoubleAbs_updateGradInput");
    
    NSLog(@"address:%p",address);
    
//  luaL_openlibs(L);
    openlualibs(L);

//  
  [self addLuaPackagePathForBundlePath:[[NSBundle mainBundle] resourcePath] subdirectory:nil];
//
    NSString *frameworkResourcesPath = [self bundleResourcesPathForFrameworkName:@"Torch.framework"];
//
  [self addLuaPackagePathForBundlePath:frameworkResourcesPath subdirectory:nil];

  
//    luaopen_libpaths(L);
//    [self requireFrameworkPackage:@"paths" frameworkResourcesPath:frameworkResourcesPath];

    // load dok
//    [self requireFrameworkPackage:@"dok" frameworkResourcesPath:frameworkResourcesPath];
    
  // load Torch
//  luaopen_libtorch(L);
//  [self requireFrameworkPackage:@"torch" frameworkResourcesPath:frameworkResourcesPath];

 
    
  // load nn
//  luaopen_libnn(L);
//  [self requireFrameworkPackage:@"nn" frameworkResourcesPath:frameworkResourcesPath];
  
  
    
  // load nnx
//  luaopen_libnnx(L);
  [self requireFrameworkPackage:@"nnx" frameworkResourcesPath:frameworkResourcesPath];
    
//  // load image
//  luaopen_libimage(L);
//  [self requireFrameworkPackage:@"image" frameworkResourcesPath:frameworkResourcesPath];
    
  // load xlua
//  [self requireFrameworkPackage:@"xlua" frameworkResourcesPath:frameworkResourcesPath];
  
    // load optnet
  [self requireFrameworkPackage:@"optnet" frameworkResourcesPath:frameworkResourcesPath];

  

    
  return;
}

- (void)runMain:(NSString *)fileName inFolder:(NSString *)folderName
{
  NSString *mainFolder = [self bundleResourcesPathForFolderName:folderName];
  [self addLuaPackagePathForBundlePath:mainFolder subdirectory:nil];
  [self require:fileName inFolder:folderName];
}

- (void)loadFileWithName:(NSString *)filename inResourceFolder:(NSString *)folderName andLoadMethodName:(NSString *)methodName
{
    const char *filelocation_c_str = [[[self bundleResourcesPathForFolderName:folderName]stringByAppendingPathComponent:filename] cStringUsingEncoding:NSASCIIStringEncoding];
    const char *method_name_c_str = [methodName cStringUsingEncoding:NSASCIIStringEncoding];
    
    lua_getglobal(L,method_name_c_str);
    lua_pushstring(L,filelocation_c_str);
    int res = lua_pcall(L, 1, 0, 0);
    if (res != 0)
    {
        NSLog(@"error running function `f': %s",lua_tostring(L, -1));
    }
}

- (lua_State *)getLuaState
{
  return L;
}

@end
