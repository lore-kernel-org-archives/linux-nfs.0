From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/19] sm-notify command: use static function definitions
Date: Fri, 05 Sep 2008 17:07:47 -0400
Message-ID: <20080905210746.10001.93139.stgit@manray.1015granger.net>
References: <20080905210054.10001.8518.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:41647 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752301AbYIEVJG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2008 17:09:06 -0400
In-Reply-To: <20080905210054.10001.8518.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

The sm-notify command is built from a single source file.
Some of its internal functions are appropriately defined as static.

However, some are declared static, but defined as global.  Some are
declared and defined as global.  None of them are used outside of
utils/statd/sm-notify.c.

Make all the internal functions in utils/statd/sm-notify.cstatic.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 8108765..76a378c 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -83,11 +83,11 @@ static void		recv_reply(int);
 static void		backup_hosts(const char *, const char *);
 static void		get_hosts(const char *);
 static void		insert_host(struct nsm_host *);
-struct nsm_host *	find_host(uint32_t);
-void			nsm_log(int fac, const char *fmt, ...);
+static struct nsm_host *find_host(uint32_t);
+static void		nsm_log(int fac, const char *fmt, ...);
 static int		record_pid(void);
 static void		drop_privs(void);
-static void set_kernel_nsm_state(int state);
+static void		set_kernel_nsm_state(int state);
 
 static struct nsm_host *	hosts = NULL;
 
@@ -249,7 +249,7 @@ usage:		fprintf(stderr,
 /*
  * Notify hosts
  */
-void
+static void
 notify(void)
 {
 	struct sockaddr_storage address;
@@ -372,7 +372,7 @@ notify(void)
 /*
  * Send notification to a single host
  */
-int
+static int
 notify_host(int sock, struct nsm_host *host)
 {
 	struct sockaddr_storage address;
@@ -475,7 +475,7 @@ notify_host(int sock, struct nsm_host *host)
 /*
  * Receive reply from remote host
  */
-void
+static void
 recv_reply(int sock)
 {
 	struct nsm_host	*hp;
@@ -634,7 +634,7 @@ get_hosts(const char *dirname)
 /*
  * Insert host into sorted list
  */
-void
+static void
 insert_host(struct nsm_host *host)
 {
 	struct nsm_host	**where, *p;
@@ -662,7 +662,7 @@ insert_host(struct nsm_host *host)
 /*
  * Find host given the XID
  */
-struct nsm_host *
+static struct nsm_host *
 find_host(uint32_t xid)
 {
 	struct nsm_host	**where, *p;
@@ -682,7 +682,7 @@ find_host(uint32_t xid)
 /*
  * Retrieve the current NSM state
  */
-unsigned int
+static unsigned int
 nsm_get_state(int update)
 {
 	char		newfile[PATH_MAX];
@@ -738,7 +738,7 @@ nsm_get_state(int update)
 /*
  * Log a message
  */
-void
+static void
 nsm_log(int fac, const char *fmt, ...)
 {
 	va_list	ap;

