Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f179.google.com ([209.85.223.179]:64377 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751506AbaERRun (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 18 May 2014 13:50:43 -0400
Received: by mail-ie0-f179.google.com with SMTP id rd18so1228721iec.10
        for <linux-nfs@vger.kernel.org>; Sun, 18 May 2014 10:50:42 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Fix a module reference issue in rpcsec_gss
Date: Sun, 18 May 2014 13:50:40 -0400
Message-Id: <1400435440-4518-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We're not taking a reference in the case where _gss_mech_get_by_pseudoflavor
loops without finding the correct rpcsec_gss flavour, so why are we
releasing it?

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/auth_gss/gss_mech_switch.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
index 27ce26240932..92d5ab99fbf3 100644
--- a/net/sunrpc/auth_gss/gss_mech_switch.c
+++ b/net/sunrpc/auth_gss/gss_mech_switch.c
@@ -218,10 +218,8 @@ static struct gss_api_mech *_gss_mech_get_by_pseudoflavor(u32 pseudoflavor)
 
 	spin_lock(&registered_mechs_lock);
 	list_for_each_entry(pos, &registered_mechs, gm_list) {
-		if (!mech_supports_pseudoflavor(pos, pseudoflavor)) {
-			module_put(pos->gm_owner);
+		if (!mech_supports_pseudoflavor(pos, pseudoflavor))
 			continue;
-		}
 		if (try_module_get(pos->gm_owner))
 			gm = pos;
 		break;
-- 
1.9.0

