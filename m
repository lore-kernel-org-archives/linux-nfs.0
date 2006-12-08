From: NeilBrown <neilb@suse.de>
Subject: [PATCH 000 of 13] knfsd: Preparation for IPv6 support
Date: Fri, 8 Dec 2006 23:01:47 +1100
Message-ID: <20061208225655.17970.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GseQ9-00065B-6f
	for nfs@lists.sourceforge.net; Fri, 08 Dec 2006 04:01:41 -0800
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GseQ9-0004qS-9A
	for nfs@lists.sourceforge.net; Fri, 08 Dec 2006 04:01:42 -0800
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

Following are 13 patches for nfsd/sunrpc that are suitabble for
2.6.20.  They are from Chuck Lever and generalise some dependancies on
IPv4 to prepare the way for IPv6.  There is still a lot of work to do
before we can actually use IPv6 to talk to NFSD, but this removes some
barriers.

Thanks,
NeilBrown

 [PATCH 001 of 13] knfsd: SUNRPC: update internal API: separate pmap register and temp sockets
 [PATCH 002 of 13] knfsd: SUNRPC: allow creating an RPC service without registering with portmapper
 [PATCH 003 of 13] knfsd: SUNRPC: Cache remote peer's address in svc_sock.
 [PATCH 004 of 13] knfsd: SUNRPC: Don't set msg_name and msg_namelen when calling sock_recvmsg
 [PATCH 005 of 13] knfsd: SUNRPC: Use sockaddr_storage to store address in svc_deferred_req
 [PATCH 006 of 13] knfsd: SUNRPC: Add a function to format the address in an svc_rqst for printing
 [PATCH 007 of 13] knfsd: SUNRPC: Provide room in svc_rqst for larger addresses
 [PATCH 008 of 13] knfsd: SUNRPC: Make rq_daddr field address-version independent
 [PATCH 009 of 13] knfsd: SUNRPC: teach svc_sendto() to deal with IPv6 addresses
 [PATCH 010 of 13] knfsd: SUNRPC: add a "generic" function to see if the peer uses a secure port
 [PATCH 011 of 13] knfsd: SUNRPC: Support IPv6 addresses in svc_tcp_accept
 [PATCH 012 of 13] knfsd: SUNRPC: support IPv6 addresses in RPC server's UDP receive path
 [PATCH 013 of 13] knfsd: SUNRPC: fix up svc_create_socket() to take a sockaddr struct + length

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
