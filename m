From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH] exponential backoff for blocked LOCK call polling
Date: Tue, 26 Oct 2004 20:22:12 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1098786131.21421.484.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-//Y3K4lkqhdxg3LADyR2"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CMO9y-0000vi-6L
	for nfs@lists.sourceforge.net; Tue, 26 Oct 2004 03:02:34 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CMO9v-0007ry-RO
	for nfs@lists.sourceforge.net; Tue, 26 Oct 2004 03:02:34 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--=-//Y3K4lkqhdxg3LADyR2
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

G'day,

The attached patch makes the NLM client do exponential backoff
for the polling used to handle the case that the server has not
sent a GRANTED callback.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


--=-//Y3K4lkqhdxg3LADyR2
Content-Disposition: attachment; filename=gnb-nlm-block-backoff
Content-Type: text/plain; name=gnb-nlm-block-backoff; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Implement exponential backoff for the NLM client LOCK call polling
when the server doesn't send the client a GRANTED callback.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>

Index: linux/fs/lockd/clntlock.c
===================================================================
--- linux.orig/fs/lockd/clntlock.c	Thu Oct 21 17:18:37 2004
+++ linux/fs/lockd/clntlock.c	Thu Oct 21 17:25:03 2004
@@ -45,7 +45,8 @@ static struct nlm_wait *	nlm_blocked;
  * Block on a lock
  */
 int
-nlmclnt_block(struct nlm_host *host, struct file_lock *fl, u32 *statp)
+nlmclnt_block(struct nlm_host *host, struct file_lock *fl, u32 *statp,
+	      int delay)
 {
 	struct nlm_wait	block, **head;
 	int		err;
@@ -64,12 +65,8 @@ nlmclnt_block(struct nlm_host *host, str
 	/* Go to sleep waiting for GRANT callback. Some servers seem
 	 * to lose callbacks, however, so we're going to poll from
 	 * time to time just to make sure.
-	 *
-	 * For now, the retry frequency is pretty high; normally 
-	 * a 1 minute timeout would do. See the comment before
-	 * nlmclnt_lock for an explanation.
 	 */
-	sleep_on_timeout(&block.b_wait, 30*HZ);
+	sleep_on_timeout(&block.b_wait, delay);
 
 	for (head = &nlm_blocked; *head; head = &(*head)->b_next) {
 		if (*head == &block) {
Index: linux/fs/lockd/clntproc.c
===================================================================
--- linux.orig/fs/lockd/clntproc.c	Mon Oct  4 14:35:14 2004
+++ linux/fs/lockd/clntproc.c	Thu Oct 21 17:26:43 2004
@@ -534,12 +534,16 @@ static void nlmclnt_locks_init_private(s
  * This is one of the lovely things about standards in the NFS area:
  * they're so soft and squishy you can't really blame HP for doing this.
  */
+#define NLM_LOCK_RETRY_DELAY_MIN	(110*HZ/100)
+#define NLM_LOCK_RETRY_DELAY_MAX	(64*NLM_LOCK_RETRY_DELAY_MIN)
+
 static int
 nlmclnt_lock(struct nlm_rqst *req, struct file_lock *fl)
 {
 	struct nlm_host	*host = req->a_host;
 	struct nlm_res	*resp = &req->a_res;
 	int		status;
+	int		delay = NLM_LOCK_RETRY_DELAY_MIN;
 
 	if (!host->h_monitored && nsm_monitor(host) < 0) {
 		printk(KERN_NOTICE "lockd: failed to monitor %s\n",
@@ -552,7 +556,13 @@ nlmclnt_lock(struct nlm_rqst *req, struc
 		if ((status = nlmclnt_call(req, NLMPROC_LOCK)) >= 0) {
 			if (resp->status != NLM_LCK_BLOCKED)
 				break;
-			status = nlmclnt_block(host, fl, &resp->status);
+			status = nlmclnt_block(host, fl, &resp->status, delay);
+			/* 
+			 * Use an exponential backoff strategy for best
+			 * compromise between response time and efficiency
+			 */
+			if (delay < NLM_LOCK_RETRY_DELAY_MAX)
+				delay <<= 1;
 		}
 		if (status < 0)
 			goto out;
Index: linux/include/linux/lockd/lockd.h
===================================================================
--- linux.orig/include/linux/lockd/lockd.h	Thu Oct 21 17:08:30 2004
+++ linux/include/linux/lockd/lockd.h	Thu Oct 21 17:23:43 2004
@@ -145,7 +145,7 @@ extern unsigned long		nlmsvc_timeout;
 struct nlm_rqst * nlmclnt_alloc_call(void);
 int		  nlmclnt_call(struct nlm_rqst *, u32);
 int		  nlmclnt_async_call(struct nlm_rqst *, u32, rpc_action);
-int		  nlmclnt_block(struct nlm_host *, struct file_lock *, u32 *);
+int		  nlmclnt_block(struct nlm_host *, struct file_lock *, u32 *, int);
 int		  nlmclnt_cancel(struct nlm_host *, struct file_lock *);
 u32		  nlmclnt_grant(struct nlm_lock *);
 void		  nlmclnt_recovery(struct nlm_host *, u32);

--=-//Y3K4lkqhdxg3LADyR2--



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
