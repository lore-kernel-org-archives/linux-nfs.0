Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43304 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751010Ab1AEB6B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 20:58:01 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v4 4/5] NFSv4: Propagate the error NFS4ERR_BADOWNER to nfs4_do_setattr
Date: Tue,  4 Jan 2011 20:57:50 -0500
Message-Id: <1294192671-18864-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1294192671-18864-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1294192671-18864-1-git-send-email-Trond.Myklebust@netapp.com>
 <1294192671-18864-2-git-send-email-Trond.Myklebust@netapp.com>
 <1294192671-18864-3-git-send-email-Trond.Myklebust@netapp.com>
 <1294192671-18864-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This will be required in order to switch uid/gid mapping back on if the
admin has tried to disable it.

Note that we also propagate NFS4ERR_BADNAME at the same time, in order to
work around a Linux server bug.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c |    3 +++
 fs/nfs/nfs4xdr.c  |    2 --
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2aede9c..39a2e3c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -84,6 +84,9 @@ static int nfs4_map_errors(int err)
 	switch (err) {
 	case -NFS4ERR_RESOURCE:
 		return -EREMOTEIO;
+	case -NFS4ERR_BADOWNER:
+	case -NFS4ERR_NAME:
+		return -EINVAL;
 	default:
 		dprintk("%s could not handle NFSv4 error %d\n",
 				__func__, -err);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index bc205ab..1de6b22 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -6174,8 +6174,6 @@ static struct {
 	{ NFS4ERR_DQUOT,	-EDQUOT		},
 	{ NFS4ERR_STALE,	-ESTALE		},
 	{ NFS4ERR_BADHANDLE,	-EBADHANDLE	},
-	{ NFS4ERR_BADOWNER,	-EINVAL		},
-	{ NFS4ERR_BADNAME,	-EINVAL		},
 	{ NFS4ERR_BAD_COOKIE,	-EBADCOOKIE	},
 	{ NFS4ERR_NOTSUPP,	-ENOTSUPP	},
 	{ NFS4ERR_TOOSMALL,	-ETOOSMALL	},
-- 
1.7.3.4

