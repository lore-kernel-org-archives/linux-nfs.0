Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:34686 "EHLO
	mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533AbcERRzP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 May 2016 13:55:15 -0400
Received: by mail-qk0-f195.google.com with SMTP id i7so5044013qkd.1
        for <linux-nfs@vger.kernel.org>; Wed, 18 May 2016 10:55:14 -0700 (PDT)
From: Paulo Andrade <paulo.cesar.pereira.de.andrade@gmail.com>
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org, Paulo Andrade <pcpa@gnu.org>
Subject: [PATCH] Do not hold clnt_fd_lock mutex during connect
Date: Wed, 18 May 2016 14:54:51 -0300
Message-Id: <1463594091-1289-1-git-send-email-pcpa@gnu.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  An user  reports  that  their  application  connects to  multiple  servers
through a rpc interface using  libtirpc. When one of  the servers misbehaves
(goes down  ungracefully or  has a  delay of  a few  seconds in  the traffic
flow), it was observed that the traffic from the  client to other servers is
decreased by  the  traffic  anomaly  of  the failing  server,  i.e.  traffic
decreases or goes to 0 in all the servers.

  When investigated further, specifically into the behavior  of the libtirpc
at the  time of  the issue,  it  was observed  that all  of the  application
threads specifically interacting with  libtirpc were locked into  one single
lock inside  the  libtirpc library.  This  was a  race  condition which  had
resulted in a deadlock and hence the resultant dip/stoppage of traffic.

  As an experiment, the user removed the libtirpc from the application build
and used the  standard glibc  library for rpc  communication. In  that case,
everything worked perfectly even  in the time  of the issue of  server nodes
misbehaving.

Signed-off-by: Paulo Andrade <pcpa@gnu.org>
---
 src/clnt_vc.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/src/clnt_vc.c b/src/clnt_vc.c
index a72f9f7..2396f34 100644
--- a/src/clnt_vc.c
+++ b/src/clnt_vc.c
@@ -229,27 +229,23 @@ clnt_vc_create(fd, raddr, prog, vers, sendsz, recvsz)
 	} else
 		assert(vc_cv != (cond_t *) NULL);
 
-	/*
-	 * XXX - fvdl connecting while holding a mutex?
-	 */
+	mutex_unlock(&clnt_fd_lock);
+
 	slen = sizeof ss;
 	if (getpeername(fd, (struct sockaddr *)&ss, &slen) < 0) {
 		if (errno != ENOTCONN) {
 			rpc_createerr.cf_stat = RPC_SYSTEMERROR;
 			rpc_createerr.cf_error.re_errno = errno;
-			mutex_unlock(&clnt_fd_lock);
 			thr_sigsetmask(SIG_SETMASK, &(mask), NULL);
 			goto err;
 		}
 		if (connect(fd, (struct sockaddr *)raddr->buf, raddr->len) < 0){
 			rpc_createerr.cf_stat = RPC_SYSTEMERROR;
 			rpc_createerr.cf_error.re_errno = errno;
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

