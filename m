Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64364 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755200Ab0IFDiS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 5 Sep 2010 23:38:18 -0400
Message-ID: <4C846223.5050609@cn.fujitsu.com>
Date: Mon, 06 Sep 2010 11:38:11 +0800
From: Bian Naimeng <biannm@cn.fujitsu.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2]gss:spkm3 miss returning error to caller when import security
 context
References: <4C846162.40305@cn.fujitsu.com>
In-Reply-To: <4C846162.40305@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

spkm3 miss returning error to up layer when import security context, 
it may be return ok though it has failed to import security context.

Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>


---
 net/sunrpc/auth_gss/gss_spkm3_mech.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_spkm3_mech.c b/net/sunrpc/auth_gss/gss_spkm3_mech.c
index dc3f1f5..adade3d 100644
--- a/net/sunrpc/auth_gss/gss_spkm3_mech.c
+++ b/net/sunrpc/auth_gss/gss_spkm3_mech.c
@@ -100,6 +100,7 @@ gss_import_sec_context_spkm3(const void *p, size_t len,
 	if (version != 1) {
 		dprintk("RPC:       unknown spkm3 token format: "
 				"obsolete nfs-utils?\n");
+		p = ERR_PTR(-EINVAL);
 		goto out_err_free_ctx;
 	}
 
@@ -135,8 +136,10 @@ gss_import_sec_context_spkm3(const void *p, size_t len,
 	if (IS_ERR(p))
 		goto out_err_free_intg_alg;
 
-	if (p != end)
+	if (p != end) {
+		p = ERR_PTR(-EFAULT);
 		goto out_err_free_intg_key;
+	}
 
 	ctx_id->internal_ctx_id = ctx;
 
-- 
1.7.0


-- 
Regards
Bian Naimeng

