Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:35667 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005Ab1CJR3f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Mar 2011 12:29:35 -0500
Received: by gwaa18 with SMTP id a18so534277gwa.19
        for <linux-nfs@vger.kernel.org>; Thu, 10 Mar 2011 09:29:34 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/8] Snapshot of client-side NFSv4 migration support
To: linux-nfs@vger.kernel.org
Date: Thu, 10 Mar 2011 12:29:30 -0500
Message-ID: <20110310171345.8878.25548.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Here are some patches that move Linux towards client side support for
NFSv4.0 migration.  An earlier version of this patch set was
demonstrated at Connectathon 2011.  Think of this post as a request
for architectural review.

This set currently supports recovering from NFS4ERR_MOVED, and has
rudimentary support for NFS4ERR_LEASE_MOVED.  Recent versions of this
set have been tested with the prototype Solaris server migration
implementation (though this specific version of the set has not been
tested).

By default, the Solaris server implementation migrates state, so state
recovery after migration in this client is not yet supported or
tested.  It may work, somewhat, for certain nicely behaving cases.

There are still some protocol questions around state recovery after
migration, most immediately involving how clients should communicate
new callback endpoint information to the destination server in such a
way that existing leases are not broken.

In addition, the Solaris server implementation does not yet support
minor version 1, so this set has minor version 1 support sketched in,
but not fully implemented or tested.

These patches are on top of 2.6.38-rc8 with Trond's transport
swapping patches.  A full git repo with all these patches is available
here:

  http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=commit;h=18d7665fd9c89268b4e15637df86e3b0c7144b29

This commit is tag "cel-03102011-1022".

---

Chuck Lever (8):
      NFS: Implement support for NFS4ERR_LEASE_MOVED
      NFS: Add migration recovery callouts in nfs4proc.c
      NFS: Remove "const" from "struct nfs_server *" fields
      NFS: Add basic migration support to state manager thread
      NFS: Add functions to swap transports during migration recovery
      NFS: Introduce nfs4_proc_get_mig_status()
      NFS: Save root file handle in nfs_server
      NFS: Add a lame client-side function to display file handles


 fs/nfs/client.c           |    2 +
 fs/nfs/getroot.c          |    6 ++
 fs/nfs/inode.c            |   44 ++++++++++++
 fs/nfs/internal.h         |    2 +
 fs/nfs/nfs4_fs.h          |    6 ++
 fs/nfs/nfs4namespace.c    |  162 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c         |  125 ++++++++++++++++++++++++++++++-----
 fs/nfs/nfs4state.c        |  150 ++++++++++++++++++++++++++++++++++++++++--
 fs/nfs/nfs4xdr.c          |   81 ++++++++++++++++++++++-
 include/linux/nfs4.h      |    1 
 include/linux/nfs_fs.h    |   13 ++++
 include/linux/nfs_fs_sb.h |    6 ++
 include/linux/nfs_xdr.h   |   35 ++++++----
 13 files changed, 593 insertions(+), 40 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>
