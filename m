From: Mark Hemment <markhe@veritas.com>
Subject: lockd fails to purge blocked NLM_LOCKs
Date: Fri, 1 Aug 2003 12:32:35 +0100 (BST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0308011225280.1062-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from brooklyn-bridge.emea.veritas.com ([62.172.234.2] helo=localhost.localdomain)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19iY8l-0006Kw-00
	for <nfs@lists.sourceforge.net>; Fri, 01 Aug 2003 04:32:08 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
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

  Patch against 2.4.21-pre9 attached.

Mark


diff -urN linux-2.4.21-pre9/fs/lockd/svclock.c lockd-block/fs/lockd/svclock.c
--- linux-2.4.21-pre9/fs/lockd/svclock.c	2003-07-31 20:49:28.000000000 +0100
+++ lockd-block/fs/lockd/svclock.c	2003-08-01 12:06:04.000000000 +0100
@@ -188,6 +188,11 @@
 	locks_init_lock(&block->b_call.a_args.lock.fl);
 	locks_init_lock(&block->b_call.a_res.lock.fl);

+	block->b_host = nlmsvc_lookup_host(rqstp);
+	if (block->b_host == NULL) {
+		goto failed_free;
+	}
+
 	if (!nlmclnt_setgrantargs(&block->b_call, lock))
 		goto failed_free;

@@ -199,7 +204,6 @@

 	/* Create and initialize the block */
 	block->b_daemon = rqstp->rq_server;
-	block->b_host   = host;
 	block->b_file   = file;

 	/* Add to file's list of blocks */
@@ -265,8 +269,7 @@
 		}
 	}

-	if (block->b_host)
-		nlm_release_host(block->b_host);
+	nlm_release_host(block->b_host);
 	nlmclnt_freegrantargs(&block->b_call);
 	kfree(block);
 }
@@ -515,7 +518,7 @@
 	 * Just retry the grant callback, possibly refreshing the RPC
 	 * binding */
 	if (block->b_granted) {
-		nlm_rebind_host(block->b_host);
+		nlm_rebind_host(block->b_call.a_host);
 		goto callback;
 	}





-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
