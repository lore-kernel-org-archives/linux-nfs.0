From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: [PATCH] lockd: unlock when client rejects GRANTED_MSG
Date: Sun, 1 Jul 2007 16:38:01 +0200
Message-ID: <20070701143801.GA22967@janus>
References: <20070629155226.GA25561@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I50Yr-0002cx-V0
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 07:38:02 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I50Yu-0004lR-TP
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 07:38:05 -0700
In-Reply-To: <20070629155226.GA25561@janus>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


When lockd grants a blocked lock request after a while then the client
response on it should not be ignored: When the client rejects GRANTED_MSG
with GRANTED_RES NLM_LCK_DENIED then lockd on the server must release
the POSIX lock.

Signed-off-by: Frank van Maarseveen <frankvm@frankvm.com>
---

On Fri, Jun 29, 2007 at 05:52:26PM +0200, Frank van Maarseveen wrote:
> Both server and client run 2.6.21.5 and use NFSv3 over UDP.
> 
> The server has a second IP address on eth0. The client mounts from the
> second address. Two instances of attached test program run on the client
> specifying the same lockfile. Basically they repeatedly F_SETLKW for
> an exclusive lock, sleep 0.2s with lock held, unlock, sleep 0.1s. The
> F_SETLKW is aborted by alarm(10) which normally shouldn't happen.
> 
> This works for a minute and then both alarm clocks go off and the file is
> still locked on the server but not on the client. Wireshark NLM traffic:

[snip]

This is basically what happens:

1	Client tries to obtain a lock, server says NLM_BLOCKED and prepares
	to call the client later when the conflicting lock is released.

2	When the conflicting lock is released, the server calls
	nlm_async_call() via which nlm_bind_host() creates a new transport
	with no knowledge about any source IP address to pick.
	A GRANTED_MSG goes out with a source IP address which differs from
	the destination address in the original client request.

3	Client checks IP address in nlmclnt_grant() and rejects it with
	GRANTED_RES NLM_LCK_DENIED.

4	Server ignores the error in nlmsvc_grant_reply(). It always removes
	the block (struct nlm_block) which is correct but forgets to
	remove the POSIX lock itself in case the client rejected the lock.

IMHO #2 is incorrect and #3 is a questionable check (does it buy us
anything?). #4 definately is a bug and is fixed below.

--- a/fs/lockd/svclock.c	2007-05-12 21:28:09.000000000 +0200
+++ b/fs/lockd/svclock.c	2007-07-01 14:51:21.000000000 +0200
@@ -646,20 +646,27 @@
 nlmsvc_grant_reply(struct nlm_cookie *cookie, __be32 status)
 {
 	struct nlm_block	*block;
+	struct nlm_lock		*lock;
+	int			error;
 
 	dprintk("grant_reply: looking for cookie %x, s=%d \n",
 		*(unsigned int *)(cookie->data), status);
 	if (!(block = nlmsvc_find_block(cookie)))
 		return;
 
-	if (block) {
-		if (status == nlm_lck_denied_grace_period) {
-			/* Try again in a couple of seconds */
-			nlmsvc_insert_block(block, 10 * HZ);
-		} else {
-			/* Lock is now held by client, or has been rejected.
-			 * In both cases, the block should be removed. */
-			nlmsvc_unlink_block(block);
+	if (status == nlm_lck_denied_grace_period) {
+		/* Try again in a couple of seconds */
+		nlmsvc_insert_block(block, 10 * HZ);
+	} else {
+		/* Lock is now held by client, or has been rejected.
+		 * In both cases, the block should be removed. */
+		nlmsvc_unlink_block(block);
+
+		if (status == nlm_lck_denied) {
+			lock = &block->b_call->a_args.lock;
+			lock->fl.fl_type = F_UNLCK;
+			error = posix_lock_file(block->b_file->f_file, &lock->fl);
+			dprintk("nlmsvc_grant_reply: posix_lock_file returned %d\n", error);
 		}
 	}
 	nlmsvc_release_block(block);

-- 
Frank

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
