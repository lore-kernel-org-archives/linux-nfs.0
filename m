Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50130 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751010Ab1ADXXf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 18:23:35 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Simon Kirby <sim@hostway.ca>, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>, stable@kernel.org
Subject: [PATCH 1/4] nfsd4: name->id mapping should fail with BADOWNER not BADNAME
Date: Tue,  4 Jan 2011 18:23:27 -0500
Message-Id: <1294183410-14688-1-git-send-email-bfields@redhat.com>
In-Reply-To: <1294178391.5896.31.camel@heimdal.trondhjem.org>
References: <1294178391.5896.31.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

According to rfc 3530 BADNAME is for strings that represent paths;
BADOWNER is for user/group names that don't map.

And the too-long name should probably be BADOWNER as well; it's
effectively the same as if we couldn't map it.

Cc: stable@kernel.org
Reported-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Reported-by: Simon Kirby <sim@hostway.ca>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4idmap.c |    4 ++--
 fs/nfsd/nfsd.h      |    1 +
 fs/nfsd/nfsproc.c   |    2 +-
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index f0695e8..844960f 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -524,13 +524,13 @@ idmap_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namelen
 	int ret;
 
 	if (namelen + 1 > sizeof(key.name))
-		return -EINVAL;
+		return -ESRCH; /* nfserr_badowner */
 	memcpy(key.name, name, namelen);
 	key.name[namelen] = '\0';
 	strlcpy(key.authname, rqst_authname(rqstp), sizeof(key.authname));
 	ret = idmap_lookup(rqstp, nametoid_lookup, &key, &nametoid_cache, &item);
 	if (ret == -ENOENT)
-		ret = -ESRCH; /* nfserr_badname */
+		ret = -ESRCH; /* nfserr_badowner */
 	if (ret)
 		return ret;
 	*id = item->id;
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 6b641cf..7ecfa24 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -158,6 +158,7 @@ void		nfsd_lockd_shutdown(void);
 #define	nfserr_attrnotsupp	cpu_to_be32(NFSERR_ATTRNOTSUPP)
 #define	nfserr_bad_xdr		cpu_to_be32(NFSERR_BAD_XDR)
 #define	nfserr_openmode		cpu_to_be32(NFSERR_OPENMODE)
+#define	nfserr_badowner		cpu_to_be32(NFSERR_BADOWNER)
 #define	nfserr_locks_held	cpu_to_be32(NFSERR_LOCKS_HELD)
 #define	nfserr_op_illegal	cpu_to_be32(NFSERR_OP_ILLEGAL)
 #define	nfserr_grace		cpu_to_be32(NFSERR_GRACE)
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index fd608a2..8f05dcd 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -738,7 +738,7 @@ nfserrno (int errno)
 		{ nfserr_jukebox, -EAGAIN },
 		{ nfserr_jukebox, -EWOULDBLOCK },
 		{ nfserr_jukebox, -ENOMEM },
-		{ nfserr_badname, -ESRCH },
+		{ nfserr_badowner, -ESRCH },
 		{ nfserr_io, -ETXTBSY },
 		{ nfserr_notsupp, -EOPNOTSUPP },
 		{ nfserr_toosmall, -ETOOSMALL },
-- 
1.7.1

