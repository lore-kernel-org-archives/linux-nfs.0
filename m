From: NeilBrown <neilb@suse.de>
Subject: [PATCH 000 of 14] knfsd: Assorted nfsd patches for 2.6.20 -
	prepare for IPv6 and more
Date: Wed, 13 Dec 2006 10:58:34 +1100
Message-ID: <20061213105528.21128.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GuHVt-0002Qz-Qt
	for nfs@lists.sourceforge.net; Tue, 12 Dec 2006 15:58:23 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GuHVv-0004eL-24
	for nfs@lists.sourceforge.net; Tue, 12 Dec 2006 15:58:23 -0800
To: Andrew Morton <akpm@osdl.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Following are 14 patches for knfsd that are suitable for inclusion in 2.6.20.
First 13 are from Chuck Lever and make preparations for IPv6 support (I think we've
get them right this time).

Last is from Peter Staubach and fixes and issue with exclusive create
interacting badly with some ACLs.

Thanks,
NeilBrown


 [PATCH 001 of 14] knfsd: SUNRPC: update internal API: separate pmap register and temp sockets
 [PATCH 002 of 14] knfsd: SUNRPC: allow creating an RPC service without registering with portmapper
 [PATCH 003 of 14] knfsd: SUNRPC: Cache remote peer's address in svc_sock.
 [PATCH 004 of 14] knfsd: SUNRPC: Don't set msg_name and msg_namelen when calling sock_recvmsg
 [PATCH 005 of 14] knfsd: SUNRPC: Use sockaddr_storage to store address in svc_deferred_req
 [PATCH 006 of 14] knfsd: SUNRPC: Add a function to format the address in an svc_rqst for printing
 [PATCH 007 of 14] knfsd: SUNRPC: Provide room in svc_rqst for larger addresses
 [PATCH 008 of 14] knfsd: SUNRPC: Make rq_daddr field address-version independent
 [PATCH 009 of 14] knfsd: SUNRPC: teach svc_sendto() to deal with IPv6 addresses
 [PATCH 010 of 14] knfsd: SUNRPC: add a "generic" function to see if the peer uses a secure port
 [PATCH 011 of 14] knfsd: SUNRPC: Support IPv6 addresses in svc_tcp_accept
 [PATCH 012 of 14] knfsd: SUNRPC: support IPv6 addresses in RPC server's UDP receive path
 [PATCH 013 of 14] knfsd: SUNRPC: fix up svc_create_socket() to take a sockaddr struct + length
 [PATCH 014 of 14] knfsd: Don't mess with the 'mode' when storing a exclusive-create cookie.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
