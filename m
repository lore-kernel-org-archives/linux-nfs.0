Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44933 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933389Ab2EPMso (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 May 2012 08:48:44 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 10/11] nfsd4: stricter cred comparison for setclientid/exchange_id
Date: Wed, 16 May 2012 08:48:38 -0400
Message-Id: <1337172519-17335-11-git-send-email-bfields@redhat.com>
In-Reply-To: <1337172519-17335-1-git-send-email-bfields@redhat.com>
References: <1337172519-17335-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The typical setclientid or exchange_id will probably be performed with a
credential that maps to either root or nobody, so comparing just uid's
is unlikely to be useful.  So, use everything else we can get our hands
on.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 625ec80..f6d2a55 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1164,11 +1164,31 @@ same_clid(clientid_t *cl1, clientid_t *cl2)
 	return (cl1->cl_boot == cl2->cl_boot) && (cl1->cl_id == cl2->cl_id);
 }
 
+static bool groups_equal(struct group_info *g1, struct group_info *g2)
+{
+	int i;
+
+	if (g1->ngroups != g2->ngroups)
+		return false;
+	for (i=0; i<g1->ngroups; i++)
+		if (GROUP_AT(g1, i) != GROUP_AT(g2, i))
+			return false;
+	return true;
+}
+
 /* XXX what about NGROUP */
 static int
 same_creds(struct svc_cred *cr1, struct svc_cred *cr2)
 {
-	return cr1->cr_uid == cr2->cr_uid;
+	if ((cr1->cr_uid != cr2->cr_uid)
+		|| (cr1->cr_gid != cr2->cr_gid)
+		|| !groups_equal(cr1->cr_group_info, cr2->cr_group_info))
+		return false;
+	if (cr1->cr_principal == cr2->cr_principal)
+		return true;
+	if (!cr1->cr_principal || !cr2->cr_principal)
+		return false;
+	return 0 == strcmp(cr1->cr_principal, cr1->cr_principal);
 }
 
 static void gen_clid(struct nfs4_client *clp)
-- 
1.7.9.5

