Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oproxy6-pub.bluehost.com ([67.222.54.6]:60464 "HELO
	oproxy6-pub.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753329Ab3EIQhd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 May 2013 12:37:33 -0400
Message-ID: <1368117430.5695.30.camel@slavad-ubuntu-12.04>
Subject: [PATCH v4 0/5] nfsd + hfsplus: introduce generalized version of
 NFSv4 ACLs <-> POSIX ACLs mapping algorithms
From: Vyacheslav Dubeyko <slava@dubeyko.com>
To: Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux NFS list <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@infradead.org>,
        Hin-Tak Leung <htl10@users.sourceforge.net>,
        Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 09 May 2013 20:37:10 +0400
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

This patchset implements ACLs support in hfsplus driver and generalizes NFSv4 ACLs <-> POSIX ACLs mapping algorithms.

v3->v4
* Introduce interface of NFSv4 ACLs <-> POSIX ACLs mapping (J. Bruce Fields request).
* Introduce generalization of NFSv4 ACLs <-> POSIX ACLs mapping algorithms (J. Bruce Fields request).
* Rework ACLs support in HFS+ driver with the purpose of using generalized mapping algorithms.
* Change dprint() on hfs_dbg() calls.
* Enhance debug output in fs/hfsplus/acl.c.

v2->v3
* Fix errors in dprint_hexdump() macro.
* Correct format on %zd for size_t in dprint() calls.

v1->v2
* Add several dprint() messages.
* Change hardcoded function names on __func__ macro.
* Fix coding style errors.

The include/linux/nfs4acl.h header file is created with the purpose of sharing declarations and structures that were moved from fs/nfsd/nfs4acl.c and fs/nfsd/acl.h. Moreover, this header file introduces declaration of operations (nfsv4_ace_operations, nfsv4_ace_flags_operations, nfsv4_acl_id_operations, nfsv4_acl_mapping_operations) that can be specialized in concrete file system driver in the case of necessity. Otherwise, it is possible to use generalized mapping code without operations specialization. And, finally, it is declared nfsv4_acl_info structure that includes operations, pointer on mapping NFSv4 ACL and pointer on special mapping environment of concrete file system.

The essence of mapping algorithms (located in fs/nfsd/nfs4acl.c, previously) were generalized and moved in fs/nfs4acl.c with the purpose of sharing between file system drivers. A concrete file system driver can use mapping code by means of map_posix_acl_to_nfsv4_one(), map_nfsv4_acl_to_posix(), nfs4_acl_posix_to_nfsv4(), nfs4_acl_nfsv4_to_posix() methods. Also, it is possible to specialize internal mapping operations in the case of very special way of operations under raw structures for concrete file system driver case.

Mac OS X supports NFSv4 ACLs. It keeps its in the form of specially named xattr (com.apple.system.Security). HFS+ driver uses generalized implementation of NFSv4 ACLs <-> POSIX ACLs mapping algorithms. But it should be specialized internal mapping operations for the proper conversion of raw NFSv4 ACLs representation on HFS+ volume into POSIX ACLs. Thereby, it were implemented in hfsplus driver all necessary specialized internal mapping operations.

With the best regards,
Vyacheslav Dubeyko.
---
 Vyacheslav Dubeyko (3):
    NFSv4: introduce interface of NFSv4 ACLs <-> POSIX ACLs mapping
    nfsd: introduce generalization of NFSv4 ACLs <-> POSIX ACLs mapping algorithms
    hfsplus: introduce implementation of the ACLs support

 fs/Makefile                 |    2 +-
 fs/hfsplus/Makefile         |    2 +-
 fs/hfsplus/acl.c            | 1903 +++++++++++++++++++++++++++++++++++++++++++
 fs/hfsplus/acl.h            |   96 +++
 fs/hfsplus/dir.c            |    2 +
 fs/hfsplus/hfsplus_fs.h     |    8 +
 fs/hfsplus/hfsplus_raw.h    |   26 +
 fs/hfsplus/inode.c          |    9 +
 fs/hfsplus/xattr.c          |   20 +-
 fs/hfsplus/xattr.h          |   32 +-
 fs/hfsplus/xattr_security.c |   13 +
 fs/nfs4acl.c                | 1261 ++++++++++++++++++++++++++++
 fs/nfsd/acl.h               |   11 +-
 fs/nfsd/nfs4acl.c           |  782 +-----------------
 include/linux/nfs4acl.h     |  300 +++++++
 15 files changed, 3688 insertions(+), 779 deletions(-)
--
1.7.9.5


