From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/10] lockd: Use "unsigned short" for lockd_up() "proto"
	argument
Date: Wed, 17 Sep 2008 11:18:26 -0500
Message-ID: <20080917161826.4963.44632.stgit@ellison.1015granger.net>
References: <20080917161337.4963.74674.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:19510 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752942AbYIQQXu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Sep 2008 12:23:50 -0400
In-Reply-To: <20080917161337.4963.74674.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.  Use conventional data type for transport argument to the
lockd_up() function.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/svc.c             |    5 ++---
 include/linux/lockd/bind.h |    2 +-
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 1553fec..311cf5e 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -207,7 +207,7 @@ lockd(void *vrqstp)
  * If nlm_udpport or nlm_tcpport were set as module
  * options, make those sockets unconditionally
  */
-static int make_socks(struct svc_serv *serv, int proto)
+static int make_socks(struct svc_serv *serv, const unsigned short proto)
 {
 	static int warned;
 	struct svc_xprt *xprt;
@@ -241,8 +241,7 @@ static int make_socks(struct svc_serv *serv, int proto)
 /*
  * Bring up the lockd process if it's not already up.
  */
-int
-lockd_up(int proto) /* Maybe add a 'family' option when IPv6 is supported ?? */
+int lockd_up(const unsigned short proto)
 {
 	struct svc_serv *serv;
 	int		error = 0;
diff --git a/include/linux/lockd/bind.h b/include/linux/lockd/bind.h
index 3d25bcd..8aeba6f 100644
--- a/include/linux/lockd/bind.h
+++ b/include/linux/lockd/bind.h
@@ -53,7 +53,7 @@ extern void	nlmclnt_done(struct nlm_host *host);
 
 extern int	nlmclnt_proc(struct nlm_host *host, int cmd,
 					struct file_lock *fl);
-extern int	lockd_up(int proto);
+extern int	lockd_up(const unsigned short proto);
 extern void	lockd_down(void);
 
 unsigned long get_nfs_grace_period(void);

