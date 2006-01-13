From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 001 of 3] semaphore to mutex conversion.
Date: Fri, 13 Jan 2006 14:14:27 +1100
Message-ID: <1060113031427.4647@cse.unsw.edu.au>
References: <20060113141059.4573.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExFOd-0001rj-Ll
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 19:14:35 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ExFOb-0002Fv-W7
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 19:14:35 -0800
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
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


From: Ingo Molnar <mingo@elte.hu>

the conversion was generated via scripts, and the result was validated
automatically via a script as well.

build and boot tested.

Signed-off-by: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./include/linux/sunrpc/svcsock.h |    2 +-
 ./net/sunrpc/svcsock.c           |    8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff ./include/linux/sunrpc/svcsock.h~current~ ./include/linux/sunrpc/svcsock.h
--- ./include/linux/sunrpc/svcsock.h~current~	2006-01-13 12:37:33.000000000 +1100
+++ ./include/linux/sunrpc/svcsock.h	2006-01-13 12:37:33.000000000 +1100
@@ -36,7 +36,7 @@ struct svc_sock {
 
 	struct list_head	sk_deferred;	/* deferred requests that need to
 						 * be revisted */
-	struct semaphore        sk_sem;		/* to serialize sending data */
+	struct mutex		sk_mutex;	/* to serialize sending data */
 
 	int			(*sk_recvfrom)(struct svc_rqst *rqstp);
 	int			(*sk_sendto)(struct svc_rqst *rqstp);

diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2006-01-13 12:37:25.000000000 +1100
+++ ./net/sunrpc/svcsock.c	2006-01-13 12:37:33.000000000 +1100
@@ -1296,13 +1296,13 @@ svc_send(struct svc_rqst *rqstp)
 		xb->page_len +
 		xb->tail[0].iov_len;
 
-	/* Grab svsk->sk_sem to serialize outgoing data. */
-	down(&svsk->sk_sem);
+	/* Grab svsk->sk_mutex to serialize outgoing data. */
+	mutex_lock(&svsk->sk_mutex);
 	if (test_bit(SK_DEAD, &svsk->sk_flags))
 		len = -ENOTCONN;
 	else
 		len = svsk->sk_sendto(rqstp);
-	up(&svsk->sk_sem);
+	mutex_unlock(&svsk->sk_mutex);
 	svc_sock_release(rqstp);
 
 	if (len == -ECONNREFUSED || len == -ENOTCONN || len == -EAGAIN)
@@ -1351,7 +1351,7 @@ svc_setup_socket(struct svc_serv *serv, 
 	svsk->sk_lastrecv = get_seconds();
 	INIT_LIST_HEAD(&svsk->sk_deferred);
 	INIT_LIST_HEAD(&svsk->sk_ready);
-	sema_init(&svsk->sk_sem, 1);
+	mutex_init(&svsk->sk_mutex);
 
 	/* Initialize the socket */
 	if (sock->type == SOCK_DGRAM)


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
