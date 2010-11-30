Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45636 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751168Ab0K3Onj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Nov 2010 09:43:39 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 4/5] NFSv4: Propagate the error NFS4ERR_BADOWNER to nfs4_do_setattr
Date: Tue, 30 Nov 2010 09:43:30 -0500
Message-Id: <1291128211-7961-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1291128211-7961-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1291128211-7961-1-git-send-email-Trond.Myklebust@netapp.com>
 <1291128211-7961-2-git-send-email-Trond.Myklebust@netapp.com>
 <1291128211-7961-3-git-send-email-Trond.Myklebust@netapp.com>
 <1291128211-7961-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This will be required in order to switch uid/gid mapping back on if the
admin has tried to disable it.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c |    2 ++
 fs/nfs/nfs4xdr.c  |    1 -
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 89b0430..e40ab0b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -83,6 +83,8 @@ static int nfs4_map_errors(int err)
 	switch (err) {
 	case -NFS4ERR_RESOURCE:
 		return -EREMOTEIO;
+	case -NFS4ERR_BADOWNER:
+		return -EINVAL;
 	default:
 		dprintk("%s could not handle NFSv4 error %d\n",
 				__func__, -err);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 0be0277..c52e991 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -6254,7 +6254,6 @@ static struct {
 	{ NFS4ERR_DQUOT,	-EDQUOT		},
 	{ NFS4ERR_STALE,	-ESTALE		},
 	{ NFS4ERR_BADHANDLE,	-EBADHANDLE	},
-	{ NFS4ERR_BADOWNER,	-EINVAL		},
 	{ NFS4ERR_BADNAME,	-EINVAL		},
 	{ NFS4ERR_BAD_COOKIE,	-EBADCOOKIE	},
 	{ NFS4ERR_NOTSUPP,	-ENOTSUPP	},
-- 
1.7.3.2

