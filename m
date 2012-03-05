Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e8.ny.us.ibm.com ([32.97.182.138]:45603 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932365Ab2CEU2w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 15:28:52 -0500
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <treinish@linux.vnet.ibm.com>;
	Mon, 5 Mar 2012 15:28:51 -0500
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id CF82738C805E
	for <linux-nfs@vger.kernel.org>; Mon,  5 Mar 2012 15:27:13 -0500 (EST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q25KR4Vs3301610
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 15:27:05 -0500
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q25KQuKn013603
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 13:26:57 -0700
From: Matthew Treinish <treinish@linux.vnet.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: treinish@linux.vnet.ibm.com
Subject: [PATCH/RFC v3 00/10] Volatile File Handle Client-side Support
Date: Mon,  5 Mar 2012 15:26:41 -0500
Message-Id: <1330979211-894-1-git-send-email-treinish@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch series implements client side support for volatile file handle
recovery (RFC 3530 section 4.2 and 4.3) with walk back using the dcache. To
test the client you either need a server that supports volatile file handles or
you can hard code the Linux server to output NFS4ERR_FHEXPIRED instead of
NFSERR_STALE.

The approach used here for recovery is to perform lookups for each file handle
that receives a FHEXPIRED error. If the lookup also fails with FHEXPIRED, using
the dcache, it will recursively walk back to the root of the mount, and recover
that using get_root.

The 2 key changes in this iteration are fixing recovery from getattr and 
adding support for VFH during migration/replication. Recovery from getattr is
accomplished by taking the file handle and searching for a match in the dcache.
I couldn't find a better way to get a dentry or inode from the filehandle,
since nfs_fhget() needs the fattr for the file. (Which clearly isn't accessible
or up to date if getattr is being called)

For migration/replication, if FH4_VOL_MIGRATION is set in FH_EXPIRE_TYPE, then
after the client migrates or replicates to another server we can assume that
all the file handles have expired. nfs4_vfh_replication() will traverse all
the dentries in the dcache for the NFS mount and perform a nfs4_proc_lookup()
on them to refresh the file handle. However, the VFH migration/replication 
recovery function is currently not being used. When migration and replication
are added to the tree I will add patches that will call it at the appropriate 
time. 

Also, when used for replication and migration, volatile file handles allows 
the client to switch between 2 servers that have file synced exports
but different filesystems. For example, if 2 read-only servers are synced
using rsync and then remain static the client should have no issues switching
between the servers with volatile file handles.

Volatile file handle support fulfills an actual need. The z/OS NFS server
currently uses volatile file handles and the Linux client can't handle them
preventing those who use the z/OS server from connecting with a Linux client.
Additionally, other clients, such as Solaris, AIX, z/OS, and possibly Windows,
can handle volatile file handles. So I think including support is necessary 
despite the flaws in the spec that were previously discussed. This is why I 
included a mount option that disables the recovery routines by default, so 
there is no risk to the user who doesn't understand what the potential issues
are when recovering from volatile file handles.

v3:
- Fixed recovery from nfs4_proc_getattr() which is only passed a file handle
- Added support for migration/replication file handle recovery

v2:
- Added rpc_cred passing to the vfh lookup and added handling of access errors
  on the lookup

Matthew Treinish (10):
  New mount option for volatile filehandle recovery
  Add support for FH_EXPIRE_TYPE attribute.
  Save root file handle in nfs_server.
  Store root dentry in server object
  Store objects in nfs4_exception to be used during FHEXPIRED recovery.
  Add nfs4_vfh_getdentry() for getattr recovery.
  Add VFH FHEXPIRED recovery functions.
  Perform recovery on both inodes for rename.
  Added error handling for NFS4ERR_FHEXPIRED
  VFH recovery from a replication/migration event.

 fs/nfs/client.c           |    3 +
 fs/nfs/getroot.c          |    8 +
 fs/nfs/nfs4_fs.h          |    5 +
 fs/nfs/nfs4proc.c         |  422 +++++++++++++++++++++++++++++++++++++++++----
 fs/nfs/nfs4xdr.c          |   27 +++
 fs/nfs/super.c            |    7 +
 include/linux/nfs_fs_sb.h |    3 +
 include/linux/nfs_mount.h |    1 +
 include/linux/nfs_xdr.h   |    1 +
 9 files changed, 447 insertions(+), 30 deletions(-)

-- 
1.7.4.4

