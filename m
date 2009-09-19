Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:54374 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752931AbZISPLY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Sep 2009 11:11:24 -0400
Date: Sun, 20 Sep 2009 01:09:54 +1000 (EST)
From: James Morris <jmorris@namei.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>,
        "J. Bruce Fields" <bfields@fieldses.org>
cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        Casey Schaufler <casey@schaufler-ca.com>,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH 0/4][RFC] NFSv3: implement extended attribute (XATTR)
 protocol
Message-ID: <alpine.LRH.2.00.0909200020360.31818@tundra.namei.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This patchset is the initial posting of an implementation of extended 
attribute support for the Linux NFSv3 code, and intended as an RFC.

This code is based initially on the GPL'd NFSv3 xattr code from IRIX 
(thanks, Casey!), as well as the existing Linux NFSv3 ACL code. It is 
implemented as a side-protocol and should not affect any existing protocol 
operation.  These patches are against the devel branch of the linux-nfs 
tree.

Currently, the code is implemented only to support Linux namespace.name 
xattrs in the "user" namespace.  It could be extended to support other 
similar name/value pair xattr implementations (and not far from IRIX wire 
compat), although that's not an aim of this version.  There may also be 
some scope for limited support of system xattrs (e.g. 'dumb' security 
label transport), although I've not looked beyond user.* so far.

Three operations are implemented by the new XATTR protocol and map to 
syscalls:

 - GETXATTR     getxattr(2)
 - LISTXTTR     listxattr(2)
 - SETXATTR     setxattr(2) and removexattr(2)

This code passes basic testing of the above syscalls, although there are 
some areas which still need work:

 - Dynamic allocation of RPC buffers/pages (currently, the max size of 
   e.g. the getxattr(2) value buffer is allocated at the RPC layer for 
   each call -- suggestions on the best approach for this welcome)

 - Determine appropriate NFS error codes for each operation

 - Formal documentation of the XATTR protocol

 - Interoperability with other OSs (we probably should at least
   discuss with BSD folk)

 - Handle size probing for getxattr(2) and listxattr(2) in the client 
   (currently faked).  I think we should handle this at the client and not 
   support it over the wire, as probes are almost always followed 
   immediately by full calls, and the protocol can be kept simpler by 
   expecting the client to perform a full call over the wire in response 
   to a userland probe and caching the result.

 - Caching of xattrs at the client

Please review and comment!

Note that I'll be giving a talk on this at LinuxCon on Thursday: 
http://linuxcon.linuxfoundation.org/meetings/1589 So, in addition to 
discussion here, please come along to the talk if you're at the conf, and 
we may also be able to discuss it at Plumbers in one of the BoFs.

Full diffstat:

 fs/nfs/Kconfig             |   36 ++++
 fs/nfs/Makefile            |    2 
 fs/nfs/client.c            |   51 ++++++
 fs/nfs/dir.c               |    8 -
 fs/nfs/file.c              |    8 -
 fs/nfs/internal.h          |   19 ++
 fs/nfs/nfs3acl.c           |  155 +++++++++++--------
 fs/nfs/nfs3xattr.c         |  264 +++++++++++++++++++++++++++++++++
 fs/nfs/nfs3xattr_user.c    |   52 ++++++
 fs/nfs/nfs3xdr.c           |  187 +++++++++++++++++++++++
 fs/nfs/super.c             |    3 
 fs/nfsd/Kconfig            |    8 +
 fs/nfsd/Makefile           |    1 
 fs/nfsd/nfs3xattr.c        |  352 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfsctl.c           |    3 
 fs/nfsd/nfssvc.c           |   60 +++++++
 fs/nfsd/vfs.c              |    5 
 include/linux/nfs_fs.h     |   16 --
 include/linux/nfs_fs_sb.h  |    3 
 include/linux/nfs_mount.h  |    3 
 include/linux/nfs_xattr.h  |   21 ++
 include/linux/nfs_xdr.h    |   45 +++++
 include/linux/nfsd/nfsd.h  |   13 +
 include/linux/nfsd/xdr3.h  |   46 +++++
 include/linux/sunrpc/svc.h |    2 
 25 files changed, 1265 insertions(+), 98 deletions(-)


- James
-- 
James Morris
<jmorris@namei.org>
