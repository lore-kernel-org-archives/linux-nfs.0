Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f67.google.com ([209.85.192.67]:36620 "EHLO
	mail-qg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751646AbcESPff (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 May 2016 11:35:35 -0400
Received: by mail-qg0-f67.google.com with SMTP id z70so2520847qge.3
        for <linux-nfs@vger.kernel.org>; Thu, 19 May 2016 08:35:34 -0700 (PDT)
From: Paulo Andrade <paulo.cesar.pereira.de.andrade@gmail.com>
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org, Paulo Andrade <pcpa@gnu.org>
Subject: [PATCH 1/3] Make it clear rpc_createerr is thread safe
Date: Thu, 19 May 2016 12:35:08 -0300
Message-Id: <1463672110-10026-2-git-send-email-pcpa@gnu.org>
In-Reply-To: <1463672110-10026-1-git-send-email-pcpa@gnu.org>
References: <1463593885-1179-1-git-send-email-pcpa@gnu.org>
 <1463672110-10026-1-git-send-email-pcpa@gnu.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  Avoid hidding it under a macro, and also avoid multiple function
calls when accessing structure fields.

Signed-off-by: Paulo Andrade <pcpa@gnu.org>
---
 src/clnt_vc.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/src/clnt_vc.c b/src/clnt_vc.c
index a72f9f7..8af7ddd 100644
--- a/src/clnt_vc.c
+++ b/src/clnt_vc.c
@@ -72,6 +72,8 @@
 #define CMGROUP_MAX    16
 #define SCM_CREDS      0x03            /* process creds (struct cmsgcred) */
 
+#undef rpc_createerr                   /* make it clear it is a thread safe variable */
+
 /*
  * Credentials structure, used to verify the identity of a peer
  * process that has sent us a message. This is allocated by the
@@ -188,10 +190,11 @@ clnt_vc_create(fd, raddr, prog, vers, sendsz, recvsz)
 	cl = (CLIENT *)mem_alloc(sizeof (*cl));
 	ct = (struct ct_data *)mem_alloc(sizeof (*ct));
 	if ((cl == (CLIENT *)NULL) || (ct == (struct ct_data *)NULL)) {
+		struct rpc_createerr *ce = &get_rpc_createerr();
 		(void) syslog(LOG_ERR, clnt_vc_errstr,
 		    clnt_vc_str, __no_mem_str);
-		rpc_createerr.cf_stat = RPC_SYSTEMERROR;
-		rpc_createerr.cf_error.re_errno = errno;
+		ce->cf_stat = RPC_SYSTEMERROR;
+		ce->cf_error.re_errno = errno;
 		goto err;
 	}
 	ct->ct_addr.buf = NULL;
@@ -235,15 +238,17 @@ clnt_vc_create(fd, raddr, prog, vers, sendsz, recvsz)
 	slen = sizeof ss;
 	if (getpeername(fd, (struct sockaddr *)&ss, &slen) < 0) {
 		if (errno != ENOTCONN) {
-			rpc_createerr.cf_stat = RPC_SYSTEMERROR;
-			rpc_createerr.cf_error.re_errno = errno;
+			struct rpc_createerr *ce = &get_rpc_createerr();
+			ce->cf_stat = RPC_SYSTEMERROR;
+			ce->cf_error.re_errno = errno;
 			mutex_unlock(&clnt_fd_lock);
 			thr_sigsetmask(SIG_SETMASK, &(mask), NULL);
 			goto err;
 		}
 		if (connect(fd, (struct sockaddr *)raddr->buf, raddr->len) < 0){
-			rpc_createerr.cf_stat = RPC_SYSTEMERROR;
-			rpc_createerr.cf_error.re_errno = errno;
+			struct rpc_createerr *ce = &get_rpc_createerr();
+			ce->cf_stat = RPC_SYSTEMERROR;
+			ce->cf_error.re_errno = errno;
 			mutex_unlock(&clnt_fd_lock);
 			thr_sigsetmask(SIG_SETMASK, &(mask), NULL);
 			goto err;
-- 
1.8.3.1

