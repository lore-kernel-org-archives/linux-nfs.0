Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e9.ny.us.ibm.com ([32.97.182.139]:47996 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752492Ab1KKXFx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Nov 2011 18:05:53 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <treinish@linux.vnet.ibm.com>;
	Fri, 11 Nov 2011 18:05:52 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pABN5oQI309038
	for <linux-nfs@vger.kernel.org>; Fri, 11 Nov 2011 18:05:50 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pABN5oQR001758
	for <linux-nfs@vger.kernel.org>; Fri, 11 Nov 2011 18:05:50 -0500
From: Matthew Treinish <treinish@linux.vnet.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: treinish@linux.vnet.ibm.com
Subject: [PATCH/RFC 0/7] Volatile Filehandle Client-side Support
Date: Fri, 11 Nov 2011 18:04:25 -0500
Message-Id: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch series implements client side support for volatile file handle
recovery (RFC 3530 section 4.2 and 4.3) with walk back using the dcache. To
test the client you either need a server that supports volatile file handles or 
you can hard code the server to output NFS4ERR_FHEXPIRED instead of
NFSERR_STALE. (See the last patch in the series)

The approach used here for recovery is to perform lookups for each file handle
that receives a FHEXPIRED error. If the lookup also fails with FHEXPIRED using
the dcache, it will recursively walk back to the root of the mount, and recover 
that using get_root. 

Simple testing has shown that this approach works and will correctly recover
from a FHEXPIRED error code. However, the current implementation uses
d_obtain_alias if a nfs4_proc function is only given an inode. When hardlinks 
are involved, this results in getting a path, but not necessarily a path which
the user has access, which might lead to permission issues.

Since the RFC did not mandate how to recover from FHEXPIRED I would
assume this approach solves majority of the generic use cases, but, I think
that some more discussion is needed on this topic. Also, considering that this
is my first kernel patch set, I think it definitely needs review.

Matthew Treinish (7):
  New mount option for volatile filehandle recovery
  Added support for FH_EXPIRE_TYPE attribute.
  Add VFS objects from nfs4_proc calls into  nfs4_exception.
  Save root file handle in nfs_server.
  Added VFH FHEXPIRED recovery functions.
  Perform recovery on both inodes for rename.
  Added error handling for NFS4ERR_FHEXPIRED

 fs/nfs/client.c           |    3 +
 fs/nfs/getroot.c          |    7 ++
 fs/nfs/nfs4_fs.h          |    2 +
 fs/nfs/nfs4proc.c         |  245 +++++++++++++++++++++++++++++++++++++++------
 fs/nfs/nfs4xdr.c          |   27 +++++
 fs/nfs/super.c            |    6 +
 include/linux/nfs_fs_sb.h |    2 +
 include/linux/nfs_mount.h |    1 +
 include/linux/nfs_xdr.h   |    1 +
 9 files changed, 265 insertions(+), 29 deletions(-)

-- 
1.7.4.4

