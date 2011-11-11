Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e5.ny.us.ibm.com ([32.97.182.145]:42684 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754017Ab1KKXGO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Nov 2011 18:06:14 -0500
Received: from /spool/local
	by e5.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <treinish@linux.vnet.ibm.com>;
	Fri, 11 Nov 2011 18:06:11 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pABN5qAf339792
	for <linux-nfs@vger.kernel.org>; Fri, 11 Nov 2011 18:05:53 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pABN5o0Q008886
	for <linux-nfs@vger.kernel.org>; Fri, 11 Nov 2011 16:05:51 -0700
From: Matthew Treinish <treinish@linux.vnet.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: treinish@linux.vnet.ibm.com
Subject: [PATCH/RFC] Hard code testing on server <ONLY FOR TESTING>
Date: Fri, 11 Nov 2011 18:04:33 -0500
Message-Id: <1321052673-22171-9-git-send-email-treinish@linux.vnet.ibm.com>
In-Reply-To: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
References: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This should only be used for testing volatile file handle support

Force STALE errors to be FHEXPIRED and have server say it uses FH_VOLATILE_ANY. 

To force an expired change the fsid to 0 from another value in /etc/exports on
the server and then restart the server. This would normally force all the
handles to be stale, which forces FHEXPIRED to be returned for all putfh
operations.

Signed-off-by: Matthew Treinish <treinish@linux.vnet.ibm.com>

---
 fs/nfsd/nfs4xdr.c |    2 +-
 fs/nfsd/nfsd.h    |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index c8bf405..9d4a768 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1963,7 +1963,7 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 		if ((buflen -= 4) < 0)
 			goto out_resource;
 		if (exp->ex_flags & NFSEXP_NOSUBTREECHECK)
-			WRITE32(NFS4_FH_PERSISTENT);
+			WRITE32(NFS4_FH_PERSISTENT|NFS4_FH_VOLATILE_ANY);
 		else
 			WRITE32(NFS4_FH_PERSISTENT|NFS4_FH_VOL_RENAME);
 	}
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 7ecfa24..959652c 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -124,7 +124,7 @@ void		nfsd_lockd_shutdown(void);
 #define	nfserr_nametoolong	cpu_to_be32(NFSERR_NAMETOOLONG)
 #define	nfserr_notempty		cpu_to_be32(NFSERR_NOTEMPTY)
 #define	nfserr_dquot		cpu_to_be32(NFSERR_DQUOT)
-#define	nfserr_stale		cpu_to_be32(NFSERR_STALE)
+#define	nfserr_stale		cpu_to_be32(NFS4ERR_FHEXPIRED)
 #define	nfserr_remote		cpu_to_be32(NFSERR_REMOTE)
 #define	nfserr_wflush		cpu_to_be32(NFSERR_WFLUSH)
 #define	nfserr_badhandle	cpu_to_be32(NFSERR_BADHANDLE)
-- 
1.7.4.4

