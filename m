Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f68.google.com ([209.85.192.68]:35787 "EHLO
	mail-qg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754091AbcESPfc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 May 2016 11:35:32 -0400
Received: by mail-qg0-f68.google.com with SMTP id b14so7169521qge.2
        for <linux-nfs@vger.kernel.org>; Thu, 19 May 2016 08:35:32 -0700 (PDT)
From: Paulo Andrade <paulo.cesar.pereira.de.andrade@gmail.com>
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org, Paulo Andrade <pcpa@gnu.org>
Subject: [PATCH 2/3] Record errno value before calling syslog
Date: Thu, 19 May 2016 12:35:09 -0300
Message-Id: <1463672110-10026-3-git-send-email-pcpa@gnu.org>
In-Reply-To: <1463672110-10026-1-git-send-email-pcpa@gnu.org>
References: <1463593885-1179-1-git-send-email-pcpa@gnu.org>
 <1463672110-10026-1-git-send-email-pcpa@gnu.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  Unlikely to change, but stay in the safe side.

Signed-off-by: Paulo Andrade <pcpa@gnu.org>
---
 src/clnt_vc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/src/clnt_vc.c b/src/clnt_vc.c
index 8af7ddd..0da18ca 100644
--- a/src/clnt_vc.c
+++ b/src/clnt_vc.c
@@ -191,10 +191,10 @@ clnt_vc_create(fd, raddr, prog, vers, sendsz, recvsz)
 	ct = (struct ct_data *)mem_alloc(sizeof (*ct));
 	if ((cl == (CLIENT *)NULL) || (ct == (struct ct_data *)NULL)) {
 		struct rpc_createerr *ce = &get_rpc_createerr();
-		(void) syslog(LOG_ERR, clnt_vc_errstr,
-		    clnt_vc_str, __no_mem_str);
 		ce->cf_stat = RPC_SYSTEMERROR;
 		ce->cf_error.re_errno = errno;
+		(void) syslog(LOG_ERR, clnt_vc_errstr,
+		    clnt_vc_str, __no_mem_str);
 		goto err;
 	}
 	ct->ct_addr.buf = NULL;
-- 
1.8.3.1

