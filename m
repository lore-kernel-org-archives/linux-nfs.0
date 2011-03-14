Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:50788 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752192Ab1CNM40 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Mar 2011 08:56:26 -0400
Received: by iwn34 with SMTP id 34so4886177iwn.19
        for <linux-nfs@vger.kernel.org>; Mon, 14 Mar 2011 05:56:26 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/12] Snapshot of client-side NFSv4 migration support (v2)
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 14 Mar 2011 08:56:22 -0400
Message-ID: <20110314125204.2413.8870.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This is a second snapshot of migration support for the Linux NFS
client.  This snapshot is untested.  I think I've addressed recent
review comments.

The one remaining piece seems to be adding logic to send a SETCLIENTID
to the destination server to update the client's callback endpoint
information.  I think we'll need to move cl_ipaddr and other fields
related to constructing the long-form client ID into the nfs_server
struct.  More discussion is needed.

---

Chuck Lever (12):
      NFS: Implement support for NFS4ERR_LEASE_MOVED
      NFS: Add migration recovery callouts in nfs4proc.c
      NFS: Remove "const" from "struct nfs_server *" fields
      NFS: Add basic migration support to state manager thread
      NFS: Add functions to swap transports during migration recovery
      NFS: Introduce nfs4_proc_get_mig_status()
      NFS: Introduce NFS_ATTR_FATTR_V4_LOCATIONS
      NFS: Save root file handle in nfs_server
      NFS: Add a client-side function to display file handles
      NFS: Add NFS4CLNT_UPDATE_CLIENTID
      SUNRPC: Add API to acquire source address
      SUNRPC: Remove obsolete comment


 fs/nfs/client.c             |    2 +
 fs/nfs/getroot.c            |    5 +
 fs/nfs/inode.c              |   45 ++++++++++++
 fs/nfs/internal.h           |    2 +
 fs/nfs/nfs4_fs.h            |    7 ++
 fs/nfs/nfs4namespace.c      |  162 +++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c           |  143 +++++++++++++++++++++++++++++++++-----
 fs/nfs/nfs4state.c          |  150 ++++++++++++++++++++++++++++++++++++++--
 fs/nfs/nfs4xdr.c            |   50 ++++++++++---
 include/linux/nfs_fs.h      |   14 ++++
 include/linux/nfs_fs_sb.h   |    6 ++
 include/linux/nfs_xdr.h     |   38 ++++++----
 include/linux/sunrpc/clnt.h |    1 
 net/sunrpc/clnt.c           |  136 +++++++++++++++++++++++++++++++++++-
 14 files changed, 700 insertions(+), 61 deletions(-)

-- 
Chuck Lever
