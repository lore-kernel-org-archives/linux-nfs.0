From: dumas@centre-cired.fr (Patrice DUMAS - DOCT)
Subject: 2 feature requests for lockd
Date: Wed, 12 Jun 2002 16:26:43 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020612162643.F10338@hermes.centre-cired.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17I98P-00053t-00
	for <nfs@lists.sourceforge.net>; Wed, 12 Jun 2002 07:30:05 -0700
Received: from hermes.centre-cired.fr ([193.51.120.92])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id QAA04447
          for <nfs@lists.sourceforge.net>; Wed, 12 Jun 2002 16:28:30 +0100 (WEST)
Received: (from dumas@localhost)
	by hermes.centre-cired.fr (8.11.6/8.11.6) id g5CEQiE10938
	for nfs@lists.sourceforge.net; Wed, 12 Jun 2002 16:26:44 +0200
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

Hi,

I still have 2 requests concerning lockd. Could you please tell me if these
features will be accepted, because if not I won't go on to code it, as I
don't want to do the patches if they will never be accepted.


1) client side:
have a nlm_prog or lockprog as option for mount, which says which rpc
program number to use with lockd.

2) server side:
Monitor the caller_name instead of the rpc peer.

These 2 thinks are needed by sec_rpc (at least I think so) to have lockd
tunneling with more than one server, and working statd.

Pat

_______________________________________________________________

Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
