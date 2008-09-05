From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/19] nfs-utils: remove unused function rpc_logcall()
Date: Fri, 05 Sep 2008 17:07:53 -0400
Message-ID: <20080905210752.10001.92405.stgit@manray.1015granger.net>
References: <20080905210054.10001.8518.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:47097 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752103AbYIEVIz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2008 17:08:55 -0400
In-Reply-To: <20080905210054.10001.8518.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Eliminate rpc_logcall(), which has no callers.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/rpcmisc.h |    1 -
 support/nfs/rpcmisc.c     |   60 ---------------------------------------------
 2 files changed, 0 insertions(+), 61 deletions(-)

diff --git a/support/include/rpcmisc.h b/support/include/rpcmisc.h
index a2b2b5a..665df8e 100644
--- a/support/include/rpcmisc.h
+++ b/support/include/rpcmisc.h
@@ -50,7 +50,6 @@ void		rpc_svcrun(void);
 void		rpc_dispatch(struct svc_req *rq, SVCXPRT *xprt,
 				struct rpc_dtable *dtable, int nvers,
 				void *argp, void *resp);
-void		rpc_logcall(struct svc_req *, char *xname, char *args);
 
 extern int	_rpcpmstart;
 extern int	_rpcfdtype;
diff --git a/support/nfs/rpcmisc.c b/support/nfs/rpcmisc.c
index fcc6433..bd1a2db 100644
--- a/support/nfs/rpcmisc.c
+++ b/support/nfs/rpcmisc.c
@@ -215,63 +215,3 @@ int makesock(int port, int proto)
 	}
 	return (s);
 }
-
-
-/* Log an incoming call. */
-void
-rpc_logcall(struct svc_req *rqstp, char *xname, char *arg)
-{
-	char		buff[1024];
-	int		buflen=sizeof(buff);
-	int		len;
-	char		*sp;
-	int		i;
-
-	if (!xlog_enabled(D_CALL))
-		return;
-
-	sp = buff;
-	switch (rqstp->rq_cred.oa_flavor) {
-	case AUTH_NULL:
-		sprintf(sp, "NULL");
-		break;
-	case AUTH_UNIX: {
-		struct authunix_parms *unix_cred;
-		time_t time;
-		struct tm *tm;
-
-		unix_cred = (struct authunix_parms *) rqstp->rq_clntcred;
-		time = unix_cred->aup_time;
-		tm = localtime(&time);
-		snprintf(sp, buflen, "UNIX %d/%d/%d %02d:%02d:%02d %s %d.%d",
-			tm->tm_year, tm->tm_mon + 1, tm->tm_mday,
-			tm->tm_hour, tm->tm_min, tm->tm_sec,
-			unix_cred->aup_machname,
-			unix_cred->aup_uid,
-			unix_cred->aup_gid);
-		sp[buflen-1] = 0;
-		len = strlen(sp);
-		sp += buflen;
-		buflen -= len;
-		if ((int) unix_cred->aup_len > 0) {
-			snprintf(sp, buflen, "+%d", unix_cred->aup_gids[0]);
-			sp[buflen-1] = 0;
-			len = strlen(sp);
-			sp += buflen;
-			buflen -= len;
-			for (i = 1; i < unix_cred->aup_len; i++) {
-				snprintf(sp, buflen, ",%d", 
-					unix_cred->aup_gids[i]);
-				sp[buflen-1] = 0;
-				len = strlen(sp);
-				sp += buflen;
-				buflen -= len;
-			}
-		}
-		}
-		break;
-	default:
-		sprintf(sp, "CRED %d", rqstp->rq_cred.oa_flavor);
-	}
-	xlog(D_CALL, "%s [%s]\n\t%s\n", xname, buff, arg);
-}

