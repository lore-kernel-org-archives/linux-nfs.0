From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC PATCH 1/3] NLM lock failover - lock release
Date: Fri, 30 Jun 2006 00:38:29 -0400
Message-ID: <1151642309.5714.13.camel@lade.trondhjem.org>
References: <44A417E7.5090500@redhat.com>
	<1151622397.6405.5.camel@lade.trondhjem.org>
	<1151639830.5642.23.camel@localhost.localdomain>
	<17572.42316.253063.636685@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, Lon Hohberger <lhh@redhat.com>,
	nfs@lists.sourceforge.net, Wendy Cheng <wcheng@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FwAmM-0006Xb-AV
	for nfs@lists.sourceforge.net; Thu, 29 Jun 2006 21:38:54 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FwAmI-0005ms-VO
	for nfs@lists.sourceforge.net; Thu, 29 Jun 2006 21:38:54 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17572.42316.253063.636685@cse.unsw.edu.au>
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

On Fri, 2006-06-30 at 14:15 +1000, Neil Brown wrote:

> The socket can only be bound to INADDR_ANY for UDP, and in that case
> we already set rq_daddr correctly.

As I understand it, Wendy is considering the case of a multi-homed
server. She wants to record the IP address on which we received the
datagram so that she knows which locks to invalidate in the case of a
migration of that particular IP address onto another server.

My point is that she won't get that information if the socket is bound
to INADDR_ANY, as would be the case for a UDP socket.

Cheers,
  Trond


Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
