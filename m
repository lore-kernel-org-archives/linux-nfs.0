From: dumas@centre-cired.fr (Patrice DUMAS - DOCT)
Subject: [PATCH] lockd granted_res may delete an allocated lock
Date: Wed, 24 Jul 2002 12:25:10 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020724122510.C27792@hermes.centre-cired.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="XMCwj5IQnwKtuyBG"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17XJYP-0001VE-00
	for <nfs@lists.sourceforge.net>; Wed, 24 Jul 2002 03:39:37 -0700
Received: from hermes.centre-cired.fr ([193.51.120.92])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id MAA06885
          for <nfs@lists.sourceforge.net>; Wed, 24 Jul 2002 12:37:12 +0100 (WEST)
Received: (from dumas@localhost)
	by hermes.centre-cired.fr (8.11.6/8.11.6) id g6OAPA927878
	for nfs@lists.sourceforge.net; Wed, 24 Jul 2002 12:25:10 +0200
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


--XMCwj5IQnwKtuyBG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

This patch is usefull in case GRANTED_RES are accepted. In 
that case, a race condition may theoretically happen, triggering
possibly client thinking falsely it holds a lock. Here is the
scenario:

a client asks for a blocking lock. The server can't give it,
and sends NLM_LCK_BLOCKED. After a while the server can grant
the lock and send a GRANTED_MSG. The client get the call, but
for any reason cannot get the lock and respond with a GRANTED_RES
with status NLM_LCK_DENIED. This call gets lost. The server then
retries a GRANTED_MSG, but for any reason it fails to send
the GRANTED_MSG and thus is still in call (and in_call is set for 
this block).

Now the client asks one more time for the lock
and the server responds with NLM_LCK_GRANTED because the client
allready holds the lock. As in_call is set, the block isn't removed.
Now imagine that the GRANTED_RES with NLM_LCK_DENIED reaches
the server. In nlmsvc_grant_reply the server will do 
nlmsvc_delete_block(block, 1) and thus remove the lock. The client still
thinks he holds the lock.

To avoid that, in the patch, in case b_done is set, nlmsvc_grant_reply
returns without doing anything.

Pat


--XMCwj5IQnwKtuyBG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="linux-2.4.18-honor_block2.diff"

Only in ./fs/lockd/: .depend
diff -u --recursive ../linux-2.4.18.trond_patch/fs/lockd/svclock.c ./fs/lockd/svclock.c
--- ../linux-2.4.18.trond_patch/fs/lockd/svclock.c	Fri May 24 19:57:43 2002
+++ ./fs/lockd/svclock.c	Fri Jul 26 12:29:42 2002
@@ -621,21 +621,29 @@
 	file->f_count++;
 	down(&file->f_sema);
 	if ((block = nlmsvc_find_block(cookie)) != NULL) {
-		if (status == NLM_LCK_DENIED_GRACE_PERIOD) {
-			/* Try again in a couple of seconds */
-			nlmsvc_insert_block(block, 10 * HZ);
-			block = NULL;
-		} else {
-			/* Lock is now held by client, or has been rejected.
-			 * In both cases, the block should be removed. */
-			file->f_count++;
+		if (block->b_done) {
 			up(&file->f_sema);
-			if (status == NLM_LCK_GRANTED)
-				nlmsvc_delete_block(block, 0);
-			else
-				nlmsvc_delete_block(block, 1);
+			nlm_release_file(file);
+			return;
+		}
+		else {
+			if (status == NLM_LCK_DENIED_GRACE_PERIOD) {
+				/* Try again in a couple of seconds */
+				nlmsvc_insert_block(block, 10 * HZ);
+				block = NULL;
+			} else {
+				/* Lock is now held by client, or has been rejected.
+				 * In both cases, the block should be removed. */
+				file->f_count++;
+				up(&file->f_sema);
+				if (status == NLM_LCK_GRANTED)
+					nlmsvc_delete_block(block, 0);
+				else
+					nlmsvc_delete_block(block, 1);
+			}
 		}
 	}
+	
 	if (!block)
 		up(&file->f_sema);
 	nlm_release_file(file);

--XMCwj5IQnwKtuyBG--


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
