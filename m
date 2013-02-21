Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f47.google.com ([74.125.83.47]:49402 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754947Ab3BUSKQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Feb 2013 13:10:16 -0500
From: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
To: netdev@vger.kernel.org
Cc: Trond.Myklebust@netapp.com, bfields@fieldses.org, davem@davemloft.net,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] sunrpc/auth_gss: fix sparse warnings for gss_mech_switch
Date: Thu, 21 Feb 2013 20:10:06 +0200
Message-Id: <1361470206-24116-1-git-send-email-silviupopescu1990@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This fixes the following sparse warnings:
	* net/sunrpc/auth_gss/gss_mech_switch.c:143:21: warning: symbol
'_gss_mech_get_by_name' was not declared. Should it be static?
	* net/sunrpc/auth_gss/gss_mech_switch.c:208:21: warning: symbol
'_gss_mech_get_by_pseudoflavor' was not declared. Should it be static?

Signed-off-by: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
---
 net/sunrpc/auth_gss/gss_mech_switch.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
index b174fcd..f0f4eee 100644
--- a/net/sunrpc/auth_gss/gss_mech_switch.c
+++ b/net/sunrpc/auth_gss/gss_mech_switch.c
@@ -140,7 +140,7 @@ gss_mech_get(struct gss_api_mech *gm)
 
 EXPORT_SYMBOL_GPL(gss_mech_get);
 
-struct gss_api_mech *
+static struct gss_api_mech *
 _gss_mech_get_by_name(const char *name)
 {
 	struct gss_api_mech	*pos, *gm = NULL;
@@ -205,7 +205,7 @@ mech_supports_pseudoflavor(struct gss_api_mech *gm, u32 pseudoflavor)
 	return 0;
 }
 
-struct gss_api_mech *_gss_mech_get_by_pseudoflavor(u32 pseudoflavor)
+static struct gss_api_mech *_gss_mech_get_by_pseudoflavor(u32 pseudoflavor)
 {
 	struct gss_api_mech *gm = NULL, *pos;
 
-- 
1.7.9.5

