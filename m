Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58268 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726151AbeIGWn6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Sep 2018 18:43:58 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 02/13] auth_gss.c: buffer_size_warning
Date: Fri,  7 Sep 2018 14:01:40 -0400
Message-Id: <20180907180151.178872-3-steved@redhat.com>
In-Reply-To: <20180907180151.178872-1-steved@redhat.com>
References: <20180907180151.178872-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Calling strncpy with a maximum size argument of 128 bytes on
destination array "options_ret->actual_mechanism" of size 128
bytes might leave the destination string unterminated

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/auth_gss.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/src/auth_gss.c b/src/auth_gss.c
index 289bd5b..7d08262 100644
--- a/src/auth_gss.c
+++ b/src/auth_gss.c
@@ -593,7 +593,7 @@ _rpc_gss_refresh(AUTH *auth, rpc_gss_options_ret_t *options_ret)
 			if (rpc_gss_oid_to_mech(actual_mech_type, &mechanism)) {
 				strncpy(options_ret->actual_mechanism,
 					mechanism,
-					sizeof(options_ret->actual_mechanism));
+					(sizeof(options_ret->actual_mechanism)-1));
 			}
 
 			gd->established = TRUE;
-- 
2.17.1
