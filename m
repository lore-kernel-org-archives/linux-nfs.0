Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43503 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753684AbbKXRSW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Nov 2015 12:18:22 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/5] nfsd: helper for dup of possibly NULL string
Date: Tue, 24 Nov 2015 12:18:14 -0500
Message-Id: <1448385497-23737-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1448385497-23737-1-git-send-email-bfields@redhat.com>
References: <1448385497-23737-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Technically the initialization in the NULL case isn't even needed as the
only caller already has target zeroed out, but it seems safer to keep
copy_cred generic.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 21 +++++++++++++++------
 1 file changed, 15 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6b800b5b8fed..db53df069069 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1857,15 +1857,24 @@ static void copy_clid(struct nfs4_client *target, struct nfs4_client *source)
 	target->cl_clientid.cl_id = source->cl_clientid.cl_id; 
 }
 
-static int copy_cred(struct svc_cred *target, struct svc_cred *source)
+int strdup_if_nonnull(char **target, char *source)
 {
-	if (source->cr_principal) {
-		target->cr_principal =
-				kstrdup(source->cr_principal, GFP_KERNEL);
-		if (target->cr_principal == NULL)
+	if (source) {
+		*target = kstrdup(source, GFP_KERNEL);
+		if (!*target)
 			return -ENOMEM;
 	} else
-		target->cr_principal = NULL;
+		*target = NULL;
+	return 0;
+}
+
+static int copy_cred(struct svc_cred *target, struct svc_cred *source)
+{
+	int ret;
+
+	ret = strdup_if_nonnull(&target->cr_principal, source->cr_principal);
+	if (ret)
+		return ret;
 	target->cr_flavor = source->cr_flavor;
 	target->cr_uid = source->cr_uid;
 	target->cr_gid = source->cr_gid;
-- 
2.5.0

