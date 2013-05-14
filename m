Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:59179 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757464Ab3ENO0X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 May 2013 10:26:23 -0400
Received: by mail-ie0-f177.google.com with SMTP id 9so1082667iec.8
        for <linux-nfs@vger.kernel.org>; Tue, 14 May 2013 07:26:23 -0700 (PDT)
Subject: [PATCH] NFS: Fix security flavor negotiation with legacy binary
 mounts
To: darrick.wong@oracle.com
From: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Date: Tue, 14 May 2013 10:26:20 -0400
Message-ID: <20130514142620.37841.9591.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 4580a92d44 "NFS: Use server-recommended security flavor by
default (NFSv3)" introduced a behavior regression for NFS mounts
done via a legacy binary mount(2) call.

Darrick J. Wong <darrick.wong@oracle.com> reports:

> I have a kvm-based testing setup that netboots VMs over NFS, the
> client end of which seems to have broken somehow in 3.10-rc1.  The
> server's exports file looks like this:
>
> /storage/mtr/x64	192.168.122.0/24(ro,sync,no_root_squash,no_subtree_check)
>
> On the client end (inside the VM), the initrd runs the following
> command to try to mount the rootfs over NFS:
>
> # mount -o nolock -o ro -o retrans=10 192.168.122.1:/storage/mtr/x64/ /root
>
> (Note: This is the busybox mount command.)
>
> The mount fails with -EINVAL.

Ensure that a default security flavor is specified for legacy binary
mounts, since they do not invoke nfs_select_flavor() in the kernel.

Reported-by: Darrick J. Wong <darrick.wong@oracle.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/super.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index a366107..2d7525f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1942,6 +1942,7 @@ static int nfs23_validate_mount_data(void *options,
 		args->namlen		= data->namlen;
 		args->bsize		= data->bsize;
 
+		args->auth_flavors[0] = RPC_AUTH_UNIX;
 		if (data->flags & NFS_MOUNT_SECFLAVOUR)
 			args->auth_flavors[0] = data->pseudoflavor;
 		if (!args->nfs_server.hostname)
@@ -2637,6 +2638,7 @@ static int nfs4_validate_mount_data(void *options,
 			goto out_no_address;
 		args->nfs_server.port = ntohs(((struct sockaddr_in *)sap)->sin_port);
 
+		args->auth_flavors[0] = RPC_AUTH_UNIX;
 		if (data->auth_flavourlen) {
 			if (data->auth_flavourlen > 1)
 				goto out_inval_auth;

