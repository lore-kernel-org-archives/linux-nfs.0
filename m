Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from planck.uvm.edu ([132.198.104.181]:55058 "EHLO planck.uvm.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751400Ab1GTNas (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jul 2011 09:30:48 -0400
From: Benjamin Coddington <bcodding@uvm.edu>
Date: Wed, 20 Jul 2011 09:20:20 -0400
Subject: [PATCH] gssd: Fix typo in debug string
To: linux-nfs@vger.kernel.org
Message-Id: <20110720132306.A21B063D40BF@planck.uvm.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

---
 utils/gssd/context_lucid.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/gssd/context_lucid.c b/utils/gssd/context_lucid.c
index b8d4734..3e695ab 100644
--- a/utils/gssd/context_lucid.c
+++ b/utils/gssd/context_lucid.c
@@ -305,7 +305,7 @@ serialize_krb5_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf, int32_t *endtime)
 
 	maj_stat = gss_free_lucid_sec_context(&min_stat, ctx, return_ctx);
 	if (maj_stat != GSS_S_COMPLETE) {
-		pgsserr("gss_export_lucid_sec_context",
+		pgsserr("gss_free_lucid_sec_context",
 			maj_stat, min_stat, &krb5oid);
 		printerr(0, "WARN: failed to free lucid sec context\n");
 	}
-- 
1.7.5

