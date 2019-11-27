vcpkg_fail_port_install(MESSAGE "${PORT} currently only supports Linux and Mac platforms" ON_TARGET "Windows")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ntop/PF_RING
    REF 582fa09bc58411cfe6f27facd7e6438924f779d2
    SHA512 78dd2d2f9df259483196905f80a904534632a835f742d1f8b3ad645ea80f2dad78356960a2b35e2678525786a7344fa248b708bd3f86101c43fb36c7abc05598
    HEAD_REF dev
)

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    SKIP_CONFIGURE
)

vcpkg_build_make()
vcpkg_copy_pdbs()

# Install manually because pfring cannot set prefix
if (NOT CMAKE_BUILD_TYPE OR CMAKE_BUILD_TYPE STREQUAL debug)
    set(PFRING_OBJ_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
    
    if (CMAKE_BUILD_TYPE STREQUAL debug)
        file(GLOB_RECURSE PFRING_KO_FILES "${PFRING_OBJ_DIR}/*.ko")
        file(INSTALL ${PFRING_KO_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/share/${PORT})
        
        file(INSTALL ${SOURCE_PATH}/userland/lib/pfring.h DESTINATION ${CURRENT_PACKAGES_DIR}/debug/include)
    endif()
    
    file(GLOB_RECURSE PFRING_LIBS "${PFRING_OBJ_DIR}/*${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")
    file(INSTALL ${PFRING_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    
    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        file(GLOB_RECURSE PFRING_DLLS "${PFRING_OBJ_DIR}/*${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}")
        file(INSTALL ${PFRING_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    endif()
endif()

if (NOT CMAKE_BUILD_TYPE OR CMAKE_BUILD_TYPE STREQUAL release)
    set(PFRING_OBJ_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
    
    file(GLOB_RECURSE PFRING_KO_FILES "${PFRING_OBJ_DIR}/*.ko")
    file(INSTALL ${PFRING_KO_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
    
    file(GLOB_RECURSE PFRING_LIBS "${PFRING_OBJ_DIR}/*${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}")
    file(INSTALL ${PFRING_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    
    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        file(GLOB_RECURSE PFRING_DLLS "${PFRING_OBJ_DIR}/*${VCPKG_TARGET_SHARED_LIBRARY_SUFFIX}")
        file(INSTALL ${PFRING_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    endif()
    
    file(INSTALL ${SOURCE_PATH}/userland/lib/pfring.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
endif()

#Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)