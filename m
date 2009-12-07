From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 04/35] pnfsd: return pnfs flags on exchange_id
Date: Mon,  7 Dec 2009 11:30:37 +0200
Message-ID: <1260178237-14780-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>,
	Dean Hildebrand <dhildeb@us.ibm.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Set the cl_exchange_flags to be non_pnfs if we do not set
either pnfs or ds (in the plain old nfs41 case).

pnfsd: set EXCHGID4_FLAG_USE_NON_PNFS when !CONFIG_PNFSD:
EXCHGID4_FLAG_USE_NON_PNFS should be set when the server does not support
operations (e.g. LAYOUTGET) or attributes that pertain to pNFS.

[extraced from pnfsd: Initial pNFS server implementation.]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: Fixup nfsd4_set_ex_flags.]
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
[pnfsd: set EXCHGID4_FLAG_USE_NON_PNFS when !CONFIG_PNFSD]
[pnfsd: fix compiler warning in nfsd4_set_ex_flags when CONFIG_PNFSD is not defined]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2923e6c..9ecbc25 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1098,8 +1098,23 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 static void
 nfsd4_set_ex_flags(struct nfs4_client *new, struct nfsd4_exchange_id *clid)
 {
+#if defined(CONFIG_PNFSD)
+	int mds_and_ds = EXCHGID4_FLAG_USE_PNFS_MDS | EXCHGID4_FLAG_USE_PNFS_DS;
+	int mds_or_ds = 0;
+
+	/* Save the client's MDS or DS flags, or set them both.
+	 * XXX We currently do not have a method of determining
+	 * what a server supports prior to receiving a filehandle
+	 * e.g. at exchange id time. */
+	mds_or_ds = clid->flags & mds_and_ds;
+	if (mds_or_ds)
+		new->cl_exchange_flags |= mds_or_ds;
+	else
+		new->cl_exchange_flags |= mds_and_ds;
+#else  /* CONFIG_PNFSD */
 	/* pNFS is not supported */
 	new->cl_exchange_flags |= EXCHGID4_FLAG_USE_NON_PNFS;
+#endif /* CONFIG_PNFSD */
 
 	/* Referrals are supported, Migration is not. */
 	new->cl_exchange_flags |= EXCHGID4_FLAG_SUPP_MOVED_REFER;
-- 
1.6.5.1

