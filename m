From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 3 of 6 - lockd fails to purge blocked NLM_LOCKs
Date: Thu, 04 Sep 2003 16:25:55 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19unZ5-0004VF-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19unZJ-00027b-00
	for <nfs@lists.sourceforge.net>; Wed, 03 Sep 2003 23:26:09 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 19unZI-0002Hj-Qt
	for nfs@lists.sourceforge.net; Wed, 03 Sep 2003 23:26:09 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <marcelo.tosatti@cyclades.com.br>)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Thu, 4 Sep 2003 16:25:55 +1000
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com.br>
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


From: Mark Hemment <markhe@veritas.com>

  When stopping server-side NFS, or deleting a client (NFSCTL_DELCLIENT),
lockd fails to purge blocked lockd requests.

  The call path is;
	exp_freeclient()
	nfsd_lockd_unexport()
	nlmsvc_invalidate_client()

  Where nlmsvc_invalidate_client(), looks up the host with;
	host = nlm_lookup_host(clnt, NULL, 0, 0)
ie. the host-lookup keys off the client's "svc_client" (memory) address
    from NFSD's "clients" list.

  This "host" value is passed through;
	nlmsvc_free_host_resources()
	nlm_traverse_files()
	nlm_inspect_file()
and into nlmsvc_traverse_blocks(), where blocked locks are tested for
with;
	nlmsvc_traverse_blocks(host, ....)
	{
		...
		if (host == NULL || host == block->b_host)
			nlmsvc_delete_block(block, 1);
		...
	}

  However, where the block entries are created in nlmsvc_create_block();
	host = nlmclnt_lookup_host(&rqstp->rq_addr,
			rqstp->rq_prot, rqstp->rq_vers);
	...
	block->b_host   = host;

this host-lookup (nlmclnt_lookup_host()) is keyed off the client's network
address.

  So, back in nlmsvc_traverse_blocks() the test;
	host == block->b_host
is checking different values; "host" found via "svc_client"s memory
address and "b_host" found/created via the client's network address.

  The bug/confusion probably originates as "nlm_hosts[]" is overload with
two different types of entries.

  nlmsvc_create_block() still needs to create an entry in nlm_hosts[] for
the sending of the 'NLM_GRANTED', but it already stores a reference to
that entry in "call->a_host".
  Solution is to use the value in "call->a_host" for the
nlm_rebind_host(), and to set "b_host" with the host value found via an
nlmsvc_lookup_host().

diff ./fs/lockd/svclock.c~current~ ./fs/lockd/svclock.c
--- ./fs/lockd/svclock.c~current~	2003-09-04 11:32:13.000000000 +1000
+++ ./fs/lockd/svclock.c	2003-09-04 11:45:19.000000000 +1000
@@ -188,6 +188,11 @@ nlmsvc_create_block(struct svc_rqst *rqs
 	locks_init_lock(&block->b_call.a_args.lock.fl);
 	locks_init_lock(&block->b_call.a_res.lock.fl);
 
+	block->b_host = nlmsvc_lookup_host(rqstp);
+	if (block->b_host == NULL) {
+		goto failed_free;
+	}
+
 	if (!nlmclnt_setgrantargs(&block->b_call, lock))
 		goto failed_free;
 
@@ -199,7 +204,6 @@ nlmsvc_create_block(struct svc_rqst *rqs
 
 	/* Create and initialize the block */
 	block->b_daemon = rqstp->rq_server;
-	block->b_host   = host;
 	block->b_file   = file;
 
 	/* Add to file's list of blocks */
@@ -265,8 +269,7 @@ nlmsvc_delete_block(struct nlm_block *bl
 		}
 	}
 
-	if (block->b_host)
-		nlm_release_host(block->b_host);
+	nlm_release_host(block->b_host);
 	nlmclnt_freegrantargs(&block->b_call);
 	kfree(block);
 }
@@ -515,7 +518,7 @@ nlmsvc_grant_blocked(struct nlm_block *b
 	 * Just retry the grant callback, possibly refreshing the RPC
 	 * binding */
 	if (block->b_granted) {
-		nlm_rebind_host(block->b_host);
+		nlm_rebind_host(block->b_call.a_host);
 		goto callback;
 	}
 


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
