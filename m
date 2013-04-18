Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:31509 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753922Ab3DRSs2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Apr 2013 14:48:28 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] svc_getargs(): Should not be freeing arg pointers on failures
Date: Thu, 18 Apr 2013 14:48:18 -0400
Message-Id: <1366310898-9206-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit 82cc2e61 (SVCAUTH_WRAP/SVCAUTH_UNWRAP) introduce a regression
that causes callers of svc_getargs() to crash when svc_freeargs() frees
args points that are allocated on the stack.

svc_getargs() should let the callers do the freeing and not make any
assumptions on the type of memory passed in.

Also see:
    https://bugzilla.redhat.com/show_bug.cgi?id=948378
and
    CVE-2013-1950 EMBARGOED rpcbind: invalid pointer free leads to crash

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/svc_dg.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/src/svc_dg.c b/src/svc_dg.c
index b1ac462..6e00191 100644
--- a/src/svc_dg.c
+++ b/src/svc_dg.c
@@ -284,7 +284,6 @@ svc_dg_getargs(xprt, xdr_args, args_ptr)
 {
 	if (! SVCAUTH_UNWRAP(xprt->xp_auth, &(su_data(xprt)->su_xdrs),
 			     xdr_args, args_ptr)) {
-		(void)svc_freeargs(xprt, xdr_args, args_ptr);
 		return FALSE;
 	}
 	return TRUE;
-- 
1.8.1.4

