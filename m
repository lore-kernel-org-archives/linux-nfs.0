From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 01/25] SUNRPC: avoid choosing an IPMI port for RPC
	traffic
Date: Wed, 9 Aug 2006 16:04:04 +0100
Message-ID: <20060809150404.GA9984@infradead.org>
References: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
	<20060809145849.3914.57196.stgit@picasso.dsl.sfldmi.ameritech.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GApbT-0000bS-7r
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:04:15 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GApbP-0002jw-6c
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:04:15 -0700
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <20060809145849.3914.57196.stgit@picasso.dsl.sfldmi.ameritech.net>
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

On Wed, Aug 09, 2006 at 10:58:51AM -0400, Chuck Lever wrote:
> Some hardware uses port 664 for its hardware-based IPMI listener.  Teach
> the RPC client to avoid using that port by raising the default minimum port
> number to 665.
> 
> Test plan:
> Find a mainboard known to use port 664 for IPMI; enable IPMI; mount NFS
> servers in a tight loop.

I think this should go into 2.6.18.


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
