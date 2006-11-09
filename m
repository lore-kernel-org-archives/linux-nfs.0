From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH 01/12] SUNRPC: allow creating an RPC service
	without registering with portmapper
Date: Thu, 9 Nov 2006 10:59:33 +0100
Message-ID: <20061109095933.GA24104@suse.de>
References: <20061101180808.14581.98744.stgit@schiele.dsl.sfldmi.ameritech.net>
	<17746.41697.209294.695419@cse.unsw.edu.au>
	<76bd70e30611081955k7060bd58h52c9a6ba76dca6cf@mail.gmail.com>
	<17746.43863.57491.244513@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Chuck Lever <chucklever@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gi6hE-0006BG-Rl
	for nfs@lists.sourceforge.net; Thu, 09 Nov 2006 01:59:44 -0800
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gi6hE-00057L-QU
	for nfs@lists.sourceforge.net; Thu, 09 Nov 2006 01:59:46 -0800
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17746.43863.57491.244513@cse.unsw.edu.au>
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

On Thu, Nov 09, 2006 at 03:15:19PM +1100, Neil Brown wrote:
> So currently 'pmap_register' means two different things and we need to
> split it so that we can mean one (don't register) without meaning the
> other (socket is temporary).

I very much agree with that. I stumbled across this as well
a while ago.

Olaf
-- 
Walks like a duck. Quacks like a duck. Must be a chicken.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
