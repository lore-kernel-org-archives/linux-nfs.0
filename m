From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] Prevent deadlock in svc_defer
Date: Wed, 4 Aug 2004 09:07:27 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040804070727.GA4471@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="9jxsPFA5p3P2qPhR"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BsFs2-0004Ty-D9
	for nfs@lists.sourceforge.net; Wed, 04 Aug 2004 00:07:30 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BsFs1-00052m-MO
	for nfs@lists.sourceforge.net; Wed, 04 Aug 2004 00:07:30 -0700
Received: from hermes.suse.de (hermes-ext.suse.de [195.135.221.8])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by Cantor.suse.de (Postfix) with ESMTP id 63EE19C5AA5
	for <nfs@lists.sourceforge.net>; Wed,  4 Aug 2004 09:07:27 +0200 (CEST)
To: nfs@lists.sourceforge.net
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


--9jxsPFA5p3P2qPhR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

The svc_defer stuff introduced into svcsock.c recently is using spin_lock
rather than spin_lock_bh when grabbing sv_lock. This can cause deadlocks
as shown in this abridged stack dump:

0xc00000000fff76d0  0xc00000000020f8a0  .__spin_yield +0x44
0xc00000000fff76d0  0xc00000000020fa2c (lr) ._raw_spin_lock +0x58
0xc00000000fff7750  0xc00000000020fa2c  ._raw_spin_lock +0x58
0xc00000000fff77d0  0xc000000000374558  .svc_sock_enqueue +0x80
0xc00000000fff7860  0xc000000000375678  .svc_tcp_data_ready +0x5c
[...]
0xc00000000fff7b20  0xc000000000303c38  .ip_local_deliver +0xf4
[...]
0xc00000000fff7e50  0xc0000000002dba00  .net_rx_action +0x150
0xc00000000fff7f00  0xc000000000064638  .__do_softirq +0xa8
0xc00000000fff7f90  0xc000000000017530  .call_do_softirq +0x14
0xc0000003c0b17520  0xc000000000011f30  .do_softirq +0x90
0xc0000003c0b175b0  0xc000000000012ec8  .do_IRQ +0x10c
0xc0000003c0b17640  0xc00000000000b034  HardwareInterrupt_entry +0x14
--- Exception: 500: (Hardware Interrupt) at ._raw_spin_lock +0x28
0xc0000003c0b17930  0xc00000000020f9fc  ._raw_spin_lock +0x28
0xc0000003c0b17930  0xc00000000037591c (lr) .svc_revisit +0x64
0xc0000003c0b179b0  0xc00000000037591c  .svc_revisit +0x64
0xc0000003c0b17a60  0xc00000000037cb2c  .cache_revisit_request +0x18c
0xc0000003c0b17b00  0xc00000000037ea80  .cache_check +0x2b4
0xc0000003c0b17bc0  0xd0000000008d5ab0  .fh_verify +0x634

The attached patch should fix this problem.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 

--9jxsPFA5p3P2qPhR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=nfsd-cache-revisit-deadlock

Index: linux-2.6.5/net/sunrpc/svcsock.c
===================================================================
--- linux-2.6.5.orig/net/sunrpc/svcsock.c	2004-08-04 08:58:54.000000000 +0200
+++ linux-2.6.5/net/sunrpc/svcsock.c	2004-08-04 09:04:12.000000000 +0200
@@ -1505,9 +1505,9 @@
 	dprintk("revisit queued\n");
 	svsk = dr->svsk;
 	dr->svsk = NULL;
-	spin_lock(&serv->sv_lock);
+	spin_lock_bh(&serv->sv_lock);
 	list_add(&dr->handle.recent, &svsk->sk_deferred);
-	spin_unlock(&serv->sv_lock);
+	spin_unlock_bh(&serv->sv_lock);
 	set_bit(SK_DEFERRED, &svsk->sk_flags);
 	svc_sock_enqueue(svsk);
 	svc_sock_put(svsk);
@@ -1538,10 +1538,10 @@
 		dr->argslen = rqstp->rq_arg.len >> 2;
 		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base-skip, dr->argslen<<2);
 	}
-	spin_lock(&rqstp->rq_server->sv_lock);
+	spin_lock_bh(&rqstp->rq_server->sv_lock);
 	rqstp->rq_sock->sk_inuse++;
 	dr->svsk = rqstp->rq_sock;
-	spin_unlock(&rqstp->rq_server->sv_lock);
+	spin_unlock_bh(&rqstp->rq_server->sv_lock);
 
 	dr->handle.revisit = svc_revisit;
 	return &dr->handle;
@@ -1571,7 +1571,7 @@
 	
 	if (!test_bit(SK_DEFERRED, &svsk->sk_flags))
 		return NULL;
-	spin_lock(&serv->sv_lock);
+	spin_lock_bh(&serv->sv_lock);
 	clear_bit(SK_DEFERRED, &svsk->sk_flags);
 	if (!list_empty(&svsk->sk_deferred)) {
 		dr = list_entry(svsk->sk_deferred.next,
@@ -1580,6 +1580,6 @@
 		list_del_init(&dr->handle.recent);
 		set_bit(SK_DEFERRED, &svsk->sk_flags);
 	}
-	spin_unlock(&serv->sv_lock);
+	spin_unlock_bh(&serv->sv_lock);
 	return dr;
 }

--9jxsPFA5p3P2qPhR--


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
