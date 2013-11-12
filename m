Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e39.co.us.ibm.com ([32.97.110.160]:36850 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756722Ab3KLWo0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Nov 2013 17:44:26 -0500
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Tue, 12 Nov 2013 15:44:26 -0700
In-Reply-To: <5282929E.60207@gmail.com>
References: <1384283048-7699-1-git-send-email-bjschuma@netapp.com> <5282929E.60207@gmail.com>
To: Anna Schumaker <schumaker.anna@gmail.com>
Cc: bfields@fieldses.org, Anna Schumaker <bjschuma@netapp.com>,
        linux-nfs@vger.kernel.org, linux-nfs-owner@vger.kernel.org
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/3] NFSD: Update error codes
From: Marc Eshel <eshel@us.ibm.com>
Message-ID: <OF7E555129.8213C5FE-ON88257C21.007BF318-88257C21.007CE9CA@us.ibm.com>
Date: Tue, 12 Nov 2013 14:44:21 -0800
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

where do you see this change?, the last version 20 don't show it.
Thanks, Marc.



From:   Anna Schumaker <schumaker.anna@gmail.com>
To:     Anna Schumaker <bjschuma@netapp.com>, bfields@fieldses.org, 
linux-nfs@vger.kernel.org, 
Date:   11/12/2013 12:50 PM
Subject:        [PATCH v2 1/3] NFSD: Update error codes
Sent by:        linux-nfs-owner@vger.kernel.org



Recent NFS v4.2 drafts have removed NFS4ERR_METADATA_NOTSUPP and
reassigned the error code to NFS4ERR_UNION_NOTSUPP.

Signed-off-by: Anna Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/nfsd.h       | 2 +-
 include/linux/nfs4.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 30f34ab..4fe49e9 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -244,7 +244,7 @@ void        nfsd_lockd_shutdown(void);
 #define nfserr_deleg_revoked        cpu_to_be32(NFS4ERR_DELEG_REVOKED)
 #define nfserr_partner_notsupp cpu_to_be32(NFS4ERR_PARTNER_NOTSUPP)
 #define nfserr_partner_no_auth cpu_to_be32(NFS4ERR_PARTNER_NO_AUTH)
-#define nfserr_metadata_notsupp cpu_to_be32(NFS4ERR_METADATA_NOTSUPP)
+#define nfserr_union_notsupp        cpu_to_be32(NFS4ERR_UNION_NOTSUPP)
 #define nfserr_offload_denied        cpu_to_be32(NFS4ERR_OFFLOAD_DENIED)
 #define nfserr_wrong_lfs        cpu_to_be32(NFS4ERR_WRONG_LFS)
 #define nfserr_badlabel        cpu_to_be32(NFS4ERR_BADLABEL)
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 9577769..6d79deb 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -235,7 +235,7 @@ enum nfsstat4 {
     /* nfs42 */
     NFS4ERR_PARTNER_NOTSUPP    = 10088,
     NFS4ERR_PARTNER_NO_AUTH    = 10089,
-    NFS4ERR_METADATA_NOTSUPP = 10090,
+    NFS4ERR_UNION_NOTSUPP = 10090,
     NFS4ERR_OFFLOAD_DENIED = 10091,
     NFS4ERR_WRONG_LFS = 10092,
     NFS4ERR_BADLABEL = 10093,
-- 
1.8.4.2

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html



