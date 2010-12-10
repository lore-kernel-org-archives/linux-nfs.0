Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f180.google.com ([209.85.161.180]:59513 "EHLO
	mail-gx0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751954Ab0LJRbS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Dec 2010 12:31:18 -0500
Received: by gxk19 with SMTP id 19so2475145gxk.11
        for <linux-nfs@vger.kernel.org>; Fri, 10 Dec 2010 09:31:18 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFS: Fix panic after nfs_umount()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 10 Dec 2010 12:31:14 -0500
Message-ID: <20101210173003.2746.95078.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

After a few unsuccessful NFS mount attempts in which the client and
server cannot agree on an authentication flavor both support, the
client panics.  nfs_umount() is invoked in the kernel in this case.

Turns out nfs_umount()'s UMNT RPC invocation causes the RPC client to
write off the end of the rpc_clnt's iostat array.  This is because the
mount client's nrprocs field is initialized with the count of defined
procedures (two: MNT and UMNT), rather than the size of the client's
proc array (four).

The fix is to use the same initialization technique used by most other
upper layer clients in the kernel.

Introduced by commit 0b524123, which failed to update nrprocs when
support was added for UMNT in the kernel.

BugLink: https://bugzilla.kernel.org/show_bug.cgi?id=24302
BugLink: http://bugs.launchpad.net/bugs/683938

Reported-by: Stefan Bader <stefan.bader@canonical.com>
Tested-by: Stefan Bader <stefan.bader@canonical.com>
Cc: stable@kernel.org # >= 2.6.32
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Hi Trond-

This should go into 2.6.37-rc and to stable; see above.  Thanks.

 fs/nfs/mount_clnt.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index eceafe7..4f981f1 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -505,13 +505,13 @@ static struct rpc_procinfo mnt3_procedures[] = {
 
 static struct rpc_version mnt_version1 = {
 	.number		= 1,
-	.nrprocs	= 2,
+	.nrprocs	= ARRAY_SIZE(mnt_procedures),
 	.procs		= mnt_procedures,
 };
 
 static struct rpc_version mnt_version3 = {
 	.number		= 3,
-	.nrprocs	= 2,
+	.nrprocs	= ARRAY_SIZE(mnt3_procedures),
 	.procs		= mnt3_procedures,
 };
 

