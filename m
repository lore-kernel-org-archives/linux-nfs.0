From: Daniel Forrest <forrest@lmcg.wisc.edu>
Subject: [PATCH] lockd hangs during host lookup garbage collection
Date: Mon, 30 Dec 2002 14:00:05 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200212302000.gBUK05m29558@leinie.lmcg.wisc.edu>
Reply-To: Daniel Forrest <forrest@lmcg.wisc.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.lmcg.wisc.edu ([144.92.101.145])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18T656-00037F-00
	for <nfs@lists.sourceforge.net>; Mon, 30 Dec 2002 12:00:12 -0800
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

I'm hoping someone here can shepherd this into the source tree...

A deadlock occurs under the following sequence:

->nlmsvc_lock				calls down(&file->f_sema)
 ->nlmsvc_create_block
  ->nlmclnt_lookup_host
   ->nlm_lookup_host			may do garbage collection
    ->nlm_gc_hosts
     ->nlmsvc_mark_resources
      ->nlm_traverse_files		action = NLM_ACT_MARK
       ->nlm_inspect_file		loops over all files
        ->nlmsvc_traverse_blocks	calls down(&file->f_sema)

Under heavy load (i.e. >32 client machines locking/unlocking the same
NFS mounted file repeatedly) this happens within seconds.

I discussed this with Trond quite a while ago, but the question became
one of why f_sema is being used at all.  I don't know the answer to
that question.  Until someone else removes f_sema, the following patch
will avoid the problem.

This is a patch against 2.5.53, but it should also apply to any 2.4 or
2.5 tree since the code is virtually identical.  Please apply.

Dan

--- fs/lockd/svclock.c.ORIG	Mon Dec 23 23:19:52 2002
+++ fs/lockd/svclock.c	Mon Dec 30 13:42:10 2002
@@ -176,8 +176,14 @@
 	struct nlm_rqst		*call;
 
 	/* Create host handle for callback */
+	/* We must up the semaphore in case the host lookup does
+	 * garbage collection (which calls nlmsvc_traverse_blocks),
+	 * but this shouldn't be a problem because nlmsvc_lock has
+	 * to retry the lock after this anyway */
+	up(&file->f_sema);
 	host = nlmclnt_lookup_host(&rqstp->rq_addr,
 				rqstp->rq_prot, rqstp->rq_vers);
+	down(&file->f_sema);
 	if (host == NULL)
 		return NULL;
 


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
