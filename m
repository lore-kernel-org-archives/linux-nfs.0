Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6793 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756794Ab2ECPrn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 May 2012 11:47:43 -0400
From: Steve Dickson <steved@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] auth_gss: the list of pseudoflavors not being parsed correctly
Date: Thu,  3 May 2012 11:47:08 -0400
Message-Id: <1336060028-555-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

gss_mech_list_pseudoflavors() parses a list of registered mechanisms.
On that list contains a list of pseudo flavors which was not being
parsed correctly, causing only the first pseudo flavor to be found.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 net/sunrpc/auth_gss/gss_mech_switch.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
index ca8cad8..782bfe1 100644
--- a/net/sunrpc/auth_gss/gss_mech_switch.c
+++ b/net/sunrpc/auth_gss/gss_mech_switch.c
@@ -242,12 +242,13 @@ EXPORT_SYMBOL_GPL(gss_mech_get_by_pseudoflavor);
 int gss_mech_list_pseudoflavors(rpc_authflavor_t *array_ptr)
 {
 	struct gss_api_mech *pos = NULL;
-	int i = 0;
+	int j, i = 0;
 
 	spin_lock(&registered_mechs_lock);
 	list_for_each_entry(pos, &registered_mechs, gm_list) {
-		array_ptr[i] = pos->gm_pfs->pseudoflavor;
-		i++;
+		for (j=0; j < pos->gm_pf_num; j++) {
+			array_ptr[i++] = pos->gm_pfs[j].pseudoflavor;
+		}
 	}
 	spin_unlock(&registered_mechs_lock);
 	return i;
-- 
1.7.7.6

