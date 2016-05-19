Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:34242 "EHLO
	mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753433AbcESPff (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 May 2016 11:35:35 -0400
Received: by mail-qk0-f193.google.com with SMTP id i7so7889440qkd.1
        for <linux-nfs@vger.kernel.org>; Thu, 19 May 2016 08:35:35 -0700 (PDT)
From: Paulo Andrade <paulo.cesar.pereira.de.andrade@gmail.com>
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org, Paulo Andrade <pcpa@gnu.org>
Subject: [PATCH 3/3] Do not hold a global mutex during connect
Date: Thu, 19 May 2016 12:35:10 -0300
Message-Id: <1463672110-10026-4-git-send-email-pcpa@gnu.org>
In-Reply-To: <1463672110-10026-1-git-send-email-pcpa@gnu.org>
References: <1463593885-1179-1-git-send-email-pcpa@gnu.org>
 <1463672110-10026-1-git-send-email-pcpa@gnu.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  A multi-threaded application, connecting to multiple rpc servers,
may dead lock if the connect call stalls on a non responsive server.

Signed-off-by: Paulo Andrade <pcpa@gnu.org>
---
 src/clnt_vc.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/src/clnt_vc.c b/src/clnt_vc.c
index 0da18ca..0f018d5 100644
--- a/src/clnt_vc.c
+++ b/src/clnt_vc.c
@@ -233,15 +233,16 @@ clnt_vc_create(fd, raddr, prog, vers, sendsz, recvsz)
 		assert(vc_cv != (cond_t *) NULL);
 
 	/*
-	 * XXX - fvdl connecting while holding a mutex?
+	 * Do not hold mutex during connect
 	 */
+	mutex_unlock(&clnt_fd_lock);
+
 	slen = sizeof ss;
 	if (getpeername(fd, (struct sockaddr *)&ss, &slen) < 0) {
 		if (errno != ENOTCONN) {
 			struct rpc_createerr *ce = &get_rpc_createerr();
 			ce->cf_stat = RPC_SYSTEMERROR;
 			ce->cf_error.re_errno = errno;
-			mutex_unlock(&clnt_fd_lock);
 			thr_sigsetmask(SIG_SETMASK, &(mask), NULL);
 			goto err;
 		}
@@ -249,12 +250,10 @@ clnt_vc_create(fd, raddr, prog, vers, sendsz, recvsz)
 			struct rpc_createerr *ce = &get_rpc_createerr();
 			ce->cf_stat = RPC_SYSTEMERROR;
 			ce->cf_error.re_errno = errno;
-			mutex_unlock(&clnt_fd_lock);
 			thr_sigsetmask(SIG_SETMASK, &(mask), NULL);
 			goto err;
 		}
 	}
-	mutex_unlock(&clnt_fd_lock);
 	if (!__rpc_fd2sockinfo(fd, &si))
 		goto err;
 	thr_sigsetmask(SIG_SETMASK, &(mask), NULL);
-- 
1.8.3.1

