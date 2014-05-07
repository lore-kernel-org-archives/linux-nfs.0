Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f44.google.com ([209.85.220.44]:64680 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751297AbaEGPBT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 May 2014 11:01:19 -0400
Received: by mail-pa0-f44.google.com with SMTP id ld10so1288098pab.17
        for <linux-nfs@vger.kernel.org>; Wed, 07 May 2014 08:01:19 -0700 (PDT)
Message-ID: <536A4AA2.5030906@gmail.com>
Date: Wed, 07 May 2014 23:00:50 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] NFS4.0: Add some test cases for nfsv4 acl
References: <5358EEAD.4090501@gmail.com> <20140506202400.GO18281@fieldses.org>
In-Reply-To: <20140506202400.GO18281@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/7/2014 04:24, J. Bruce Fields wrote:
> On Thu, Apr 24, 2014 at 06:59:57PM +0800, Kinglong Mee wrote:
>> +def doTestGetACL(t, env, path):
>> +    c = env.c1
>> +    ops = c.use_obj(path) + [c.getattr([FATTR4_ACL])]
>> +    res = c.compound(ops)
>> +    check(res)
>> +
>> +    attrs = res.resarray[-1].obj_attributes
>> +    if FATTR4_ACL not in attrs.keys():
>> +        t.fail("Attributes not contains FATTR4_ACL")
> ...
>> +def testGetACLLink(t, env):
>> +    """ Get ACL of symlink file
>> +
>> +    FLAGS: acl getattr symlink all
>> +    DEPEND: ACLSUPP LOOKLINK
>> +    CODE: ACL1a
>> +    """
>> +    doTestGetACL(t, env, env.opts.uselink)
> 
> Dumb question: does that actually work?

Yes, it is.

> 
> Looks like a good set of tests to have, in any case.  What are the
> results against a Linux server?

With my last fix of BUG() for ACL, and exports as 
#cat /etc/exports
/nfstest        *(rw,no_root_squash,no_subtree_check,insecure,fsid=0)
#./testserver.py 127.0.0.1:/ --maketree --rundeps acl
**************************************************
ACL1a    st_acl.testGetACLLink                                    : PASS
ACL1b    st_acl.testGetACLBlock                                   : PASS
ACL1c    st_acl.testGetACLChar                                    : PASS
ACL1d    st_acl.testGetACLDir                                     : PASS
ACL1f    st_acl.testGetACLFifo                                    : PASS
ACL1r    st_acl.testGetACLFile                                    : PASS
ACL1s    st_acl.testGetACLSocket                                  : PASS
ACL2     st_acl.testWriteFileWithoutACL                           : PASS
ACL3     st_acl.testReadFileWithoutACL                            : PASS
ACL4     st_acl.testAppendFileWithoutACL                          : PASS
ACL5     st_acl.testChownWithoutACL                               : PASS
ACL6     st_acl.testSetACLWithoutACL                              : FAILURE
           Trying to set acl without ACL should return
           NFS4ERR_PERM, instead got NFS4_OK
ACL7     st_acl.testCreateFileWithoutACL                          : PASS
ACL8     st_acl.testListDirWithoutACL                             : PASS
ACL9     st_acl.testMkdirWithoutACL                               : PASS
ACL10    st_acl.testLookupFileWithoutACL                          : PASS
ACL11    st_acl.testUnlinkFileWithoutACL                          : PASS
ACLSUPP  st_acl.testCheckSupportedACL                             : PASS
INIT     st_setclientid.testValid                                 : PASS
LOOKBLK  st_lookup.testBlock                                      : PASS
LOOKCHAR st_lookup.testChar                                       : PASS
LOOKDIR  st_lookup.testDir                                        : PASS
LOOKFIFO st_lookup.testFifo                                       : PASS
LOOKFILE st_lookup.testFile                                       : PASS
LOOKLINK st_lookup.testLink                                       : PASS
LOOKSOCK st_lookup.testSocket                                     : PASS
MKDIR    st_create.testDir                                        : PASS
MKFILE   st_open.testOpen                                         : PASS
**************************************************

thanks,
Kinglong Mee

> 
> --b.
> 
>> +
>> +def testGetACLSocket(t, env):
>> +    """ Get ACL of socket file
>> +
>> +    FLAGS: acl getattr socket all
>> +    DEPEND: ACLSUPP LOOKSOCK
>> +    CODE: ACL1s
>> +    """
>> +    doTestGetACL(t, env, env.opts.usesocket)
>> +
>> +def testGetACLChar(t, env):
>> +    """ Get ACL of char file
>> +
>> +    FLAGS: acl getattr char all
>> +    DEPEND: ACLSUPP LOOKCHAR
>> +    CODE: ACL1c
>> +    """
>> +    doTestGetACL(t, env, env.opts.usechar)
>> +
>> +def testGetACLBlock(t, env):
>> +    """ Get ACL of block file
>> +
>> +    FLAGS: acl getattr block all
>> +    DEPEND: ACLSUPP LOOKBLK
>> +    CODE: ACL1b
>> +    """
>> +    doTestGetACL(t, env, env.opts.useblock)
>> +
>> +def doCheckACL(t, c, file, acl):
>> +    res = c.compound(c.use_obj(file) + [c.getattr([FATTR4_ACL])])
>> +    check(res)
>> +
>> +    attrs = res.resarray[-1].obj_attributes
>> +    if FATTR4_ACL not in attrs.keys():
>> +         t.fail("Attributes not contains FATTR4_ACL")
>> +
>> +#    print printableacl(acl)
>> +#    print printableacl(attrs[FATTR4_ACL])
>> +
>> +def doSetACLEnv(t, env, type = NF4REG):
>> +    c = env.c1
>> +    path = c.homedir + [t.code]
>> +    res = c.create_obj(path, attrs={FATTR4_MODE:0777})
>> +    check(res)
>> +
>> +    c1 = clientWithSys(env, 9999, 9999);
>> +    c1.init_connection()
>> +
>> +    path += [t.code]
>> +    attrs = {FATTR4_MODE: 0777}
>> +
>> +    if type == NF4REG:
>> +        fh, stateid = c1.create_confirm(t.code, path, attrs=attrs,
>> +                                        deny=OPEN4_SHARE_DENY_NONE)
>> +        return (c1, path, fh, stateid)
>> +    else:
>> +        res = c1.create_obj(path, attrs=attrs)
>> +        check(res)
>> +        return (c1, path)
>> +
>> +def testWriteFileWithoutACL(t, env):
>> +    """ Check write file without write ACL
>> +
>> +    FLAGS: acl file all
>> +    DEPEND: ACLSUPP MKFILE
>> +    CODE: ACL2
>> +    """
>> +    c1, path, fh, stateid = doSetACLEnv(t, env)
>> +
>> +    testacl = [nfsace4(ALLOWED, 0, MASK_ALL_FILE & ~ACE4_WRITE_DATA, "OWNER@")]
>> +    res = c1.compound(c1.use_obj(path) + [c1.setattr({FATTR4_ACL: testacl})])
>> +    check(res)
>> +
>> +    doCheckACL(t, c1, fh, testacl)
>> +
>> +    res = c1.open_file(t.code, path, access=OPEN4_SHARE_ACCESS_WRITE)
>> +    check(res, NFS4ERR_ACCESS, "Trying to OPEN file without write ACL")
>> +
>> +def testReadFileWithoutACL(t, env):
>> +    """ Check read file without read ACL
>> +
>> +    FLAGS: acl file all
>> +    DEPEND: ACLSUPP MKFILE
>> +    CODE: ACL3
>> +    """
>> +    c1, path, fh, stateid = doSetACLEnv(t, env)
>> +
>> +    testacl = [nfsace4(ALLOWED, 0, MASK_ALL_FILE & ~ACE4_READ_DATA, "OWNER@")]
>> +    res = c1.compound(c1.use_obj(path) + [c1.setattr({FATTR4_ACL: testacl})])
>> +    check(res)
>> +
>> +    doCheckACL(t, c1, fh, testacl)
>> +
>> +    res = c1.open_file(t.code, path, deny = OPEN4_SHARE_DENY_READ)
>> +    check(res, NFS4ERR_ACCESS, "Trying to OPEN file without read ACL")
>> +
>> +def testAppendFileWithoutACL(t, env):
>> +    """ Check write file without append ACL
>> +
>> +    FLAGS: acl file all
>> +    DEPEND: ACLSUPP MKFILE
>> +    CODE: ACL4
>> +    """
>> +    c1, path, fh, stateid = doSetACLEnv(t, env)
>> +
>> +    testacl = [nfsace4(ALLOWED, 0, MASK_ALL_FILE & ~ACE4_APPEND_DATA, "OWNER@")]
>> +    res = c1.compound(c1.use_obj(path) + [c1.setattr({FATTR4_ACL: testacl})])
>> +    check(res)
>> +
>> +    doCheckACL(t, c1, fh, testacl)
>> +
>> +    res = c1.open_file(t.code, path, access=OPEN4_SHARE_ACCESS_WRITE)
>> +    check(res, NFS4ERR_ACCESS, "Trying to OPEN file without append ACL")
>> +
>> +def testChownWithoutACL(t, env):
>> +    """ Check change file's owner without WRITE OWNER ACL
>> +
>> +    FLAGS: acl file all
>> +    DEPEND: ACLSUPP MKFILE
>> +    CODE: ACL5
>> +    """
>> +    c1, path, fh, stateid = doSetACLEnv(t, env)
>> +
>> +    testacl = [nfsace4(ALLOWED, 0, MASK_ALL_FILE & ~ACE4_WRITE_OWNER, "OWNER@")]
>> +    res = c1.compound(c1.use_obj(path) + [c1.setattr({FATTR4_ACL: testacl})])
>> +    check(res)
>> +
>> +    doCheckACL(t, c1, fh, testacl)
>> +
>> +    res = c1.compound(c1.use_obj(path) + [c1.setattr({FATTR4_OWNER: "6666"})])
>> +    check(res, NFS4ERR_PERM, "Trying to change file's owner without ACL")
>> +
>> +def testSetACLWithoutACL(t, env):
>> +    """ Check set ACL without SETACL ACL
>> +
>> +    FLAGS: acl file all
>> +    DEPEND: ACLSUPP MKFILE
>> +    CODE: ACL6
>> +    """
>> +    c1, path, fh, stateid = doSetACLEnv(t, env)
>> +
>> +    testacl = [nfsace4(ALLOWED, 0, MASK_ALL_FILE & ~ACE4_WRITE_ACL, "OWNER@")]
>> +    ops = c1.use_obj(path) + [c1.setattr({FATTR4_ACL: testacl})]
>> +    res = c1.compound(ops)
>> +    check(res)
>> +
>> +    doCheckACL(t, c1, fh, testacl)
>> +
>> +    res = c1.compound(ops)
>> +    check(res, NFS4ERR_PERM, "Trying to set acl without ACL")
>> +
>> +def testCreateFileWithoutACL(t, env):
>> +    """ Check create file in directory without ACL
>> +
>> +    FLAGS: acl dir all
>> +    DEPEND: ACLSUPP MKDIR
>> +    CODE: ACL7
>> +    """
>> +    c1, path = doSetACLEnv(t, env, type = NF4DIR)
>> +
>> +    testacl = [nfsace4(ALLOWED, 0, MASK_ALL_DIR & ~ACE4_ADD_FILE, "OWNER@")]
>> +    res = c1.compound(c1.use_obj(path) + [c1.setattr({FATTR4_ACL: testacl})])
>> +    check(res)
>> +
>> +    doCheckACL(t, c1, path, testacl)
>> +
>> +    path += [t.code]
>> +    res = c1.create_obj(path)
>> +    # NFSD's shortage, can not create sub-directory
>> +    check(res, NFS4ERR_ACCESS)
>> +
>> +    res = c1.create_file(t.code, path)
>> +    check(res, NFS4ERR_ACCESS, "Trying to create file without ACL")
>> +
>> +def testListDirWithoutACL(t, env):
>> +    """ Check list directory without ACL
>> +
>> +    FLAGS: acl dir all
>> +    DEPEND: ACLSUPP MKDIR
>> +    CODE: ACL8
>> +    """
>> +    c1, path = doSetACLEnv(t, env, type = NF4DIR)
>> +
>> +    testacl = [nfsace4(ALLOWED, 0, MASK_ALL_DIR & ~ACE4_LIST_DIRECTORY, "OWNER@")]
>> +    res = c1.compound(c1.use_obj(path) + [c1.setattr({FATTR4_ACL: testacl})])
>> +    check(res)
>> +
>> +    doCheckACL(t, c1, path, testacl)
>> +
>> +    res = c1.compound(c1.use_obj(path) + [c1.readdir()])
>> +    check(res, NFS4ERR_ACCESS, "Trying to list directory without ACL")
>> +
>> +def testMkdirWithoutACL(t, env):
>> +    """ Check creat sub-directory without ACL
>> +
>> +    FLAGS: acl dir all
>> +    DEPEND: ACLSUPP MKDIR
>> +    CODE: ACL9
>> +    """
>> +    c1, path = doSetACLEnv(t, env, type = NF4DIR)
>> +
>> +    testacl = [nfsace4(ALLOWED, 0, MASK_ALL_DIR & ~ACE4_ADD_SUBDIRECTORY, "OWNER@")]
>> +    res = c1.compound(c1.use_obj(path) + [c1.setattr({FATTR4_ACL: testacl})])
>> +    check(res)
>> +
>> +    doCheckACL(t, c1, path, testacl)
>> +
>> +    path += [t.code]
>> +    res = c1.create_file(t.code, path)
>> +    # NFSD's shortage, can not create file
>> +    check(res, NFS4ERR_ACCESS)
>> +
>> +    res = c1.create_obj(path)
>> +    check(res, NFS4ERR_ACCESS, "Trying to create sub-directory without ACL")
>> +
>> +def testLookupFileWithoutACL(t, env):
>> +    """ Check lookup file without ACL
>> +
>> +    FLAGS: acl dir all
>> +    DEPEND: ACLSUPP MKDIR
>> +    CODE: ACL10
>> +    """
>> +    c1, path = doSetACLEnv(t, env, type = NF4DIR)
>> +
>> +    testacl = [nfsace4(ALLOWED, 0, MASK_ALL_DIR & ~ACE4_EXECUTE, "OWNER@")]
>> +    res = c1.compound(c1.use_obj(path) + [c1.setattr({FATTR4_ACL: testacl})])
>> +    check(res)
>> +
>> +    doCheckACL(t, c1, path, testacl)
>> +
>> +    res = c1.compound(c1.use_obj(path) + c1.lookup_path([t.code]))
>> +    check(res, NFS4ERR_ACCESS, "Trying to lookup sub-file without ACL")
>> +
>> +def testUnlinkFileWithoutACL(t, env):
>> +    """ Check unlink sub-file without ACL
>> +
>> +    FLAGS: acl dir all
>> +    DEPEND: ACLSUPP MKDIR
>> +    CODE: ACL11
>> +    """
>> +    c1, path = doSetACLEnv(t, env, type = NF4DIR)
>> +
>> +    testacl = [nfsace4(ALLOWED, 0, MASK_ALL_DIR & ~ACE4_DELETE_CHILD, "OWNER@")]
>> +    res = c1.compound(c1.use_obj(path) + [c1.setattr({FATTR4_ACL: testacl})])
>> +    check(res)
>> +
>> +    doCheckACL(t, c1, path, testacl)
>> +
>> +    res = c1.compound(c1.use_obj(path) + [c1.remove_op(t.code)])
>> +    check(res, NFS4ERR_ACCESS, "Trying to lookup sub-file without ACL")
>> -- 
>> 1.9.0
>>
> 
