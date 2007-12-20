From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 7/8] lockd: Eliminate harmless mixed sign comparison in
	nlmdbg_cookie2a()
Date: Thu, 20 Dec 2007 14:55:11 -0500
Message-ID: <20071220195511.3280.36969.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:47070 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754057AbXLTTzZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Dec 2007 14:55:25 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The cookie->len field is unsigned, so the loop index variable in
nlmdbg_cookie2a() should also be unsigned.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/xdr.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/lockd/xdr.c b/fs/lockd/xdr.c
index 633653b..3e459e1 100644
--- a/fs/lockd/xdr.c
+++ b/fs/lockd/xdr.c
@@ -612,8 +612,7 @@ const char *nlmdbg_cookie2a(const struct nlm_cookie *cookie)
 	 * called with BKL held.
 	 */
 	static char buf[2*NLM_MAXCOOKIELEN+1];
-	int i;
-	int len = sizeof(buf);
+	unsigned int i, len = sizeof(buf);
 	char *p = buf;
 
 	len--;	/* allow for trailing \0 */

