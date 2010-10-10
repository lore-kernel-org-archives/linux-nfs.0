Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30726 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755816Ab0JOGRk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Oct 2010 02:17:40 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 04/12] RFC: nfs: change stateid to be a union
Date: Sun, 10 Oct 2010 11:22:45 -0400
Message-Id: <1286724173-8493-5-git-send-email-iisaman@netapp.com>
In-Reply-To: <1286724173-8493-1-git-send-email-iisaman@netapp.com>
References: <1286724173-8493-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Alexandros Batsakis <batsakis@netapp.com>

In NFSv4.1 the stateid consists of the other and seqid fields. For layout
processing we need to numerically compare the seqid value of layout stateids.
To do so, introduce a union to nfs4_stateid to switch between opaque(16 bytes)
and opaque(12 bytes) / __be32

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/callback_proc.c |    8 ++++----
 include/linux/nfs4.h   |   15 +++++++++++++--
 2 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 930d10f..2950fca 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -118,11 +118,11 @@ int nfs41_validate_delegation_stateid(struct nfs_delegation *delegation, const n
 	if (delegation == NULL)
 		return 0;
 
-	/* seqid is 4-bytes long */
-	if (((u32 *) &stateid->data)[0] != 0)
+	if (stateid->stateid.seqid != 0)
 		return 0;
-	if (memcmp(&delegation->stateid.data[4], &stateid->data[4],
-		   sizeof(stateid->data)-4))
+	if (memcmp(&delegation->stateid.stateid.other,
+		   &stateid->stateid.other,
+		   NFS4_STATEID_OTHER_SIZE))
 		return 0;
 
 	return 1;
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 6c0406e..34da324 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -17,7 +17,9 @@
 
 #define NFS4_BITMAP_SIZE	2
 #define NFS4_VERIFIER_SIZE	8
-#define NFS4_STATEID_SIZE	16
+#define NFS4_STATEID_SEQID_SIZE 4
+#define NFS4_STATEID_OTHER_SIZE 12
+#define NFS4_STATEID_SIZE	(NFS4_STATEID_SEQID_SIZE + NFS4_STATEID_OTHER_SIZE)
 #define NFS4_FHSIZE		128
 #define NFS4_MAXPATHLEN		PATH_MAX
 #define NFS4_MAXNAMLEN		NAME_MAX
@@ -167,7 +169,16 @@ struct nfs4_acl {
 };
 
 typedef struct { char data[NFS4_VERIFIER_SIZE]; } nfs4_verifier;
-typedef struct { char data[NFS4_STATEID_SIZE]; } nfs4_stateid;
+
+struct nfs41_stateid {
+	__be32 seqid;
+	char other[NFS4_STATEID_OTHER_SIZE];
+} __attribute__ ((packed));
+
+typedef union {
+	char data[NFS4_STATEID_SIZE];
+	struct nfs41_stateid stateid;
+} nfs4_stateid;
 
 enum nfs_opnum4 {
 	OP_ACCESS = 3,
-- 
1.7.2.1

