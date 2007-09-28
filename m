From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,
	PATCH 25/33] svc: Move the sockaddr information to	svc_xprt
Date: Fri, 28 Sep 2007 11:44:50 -0500
Message-ID: <1190997890.10604.58.camel@trinity.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
	<20070927050227.12677.32560.stgit@dell3.ogc.int>
	<18172.33988.315021.626126@notabene.brown>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, gnb@sgi.com
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IbIyd-0007i2-OF
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 09:46:07 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IbIyg-0006Qw-LD
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 09:46:12 -0700
In-Reply-To: <18172.33988.315021.626126@notabene.brown>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, 2007-09-28 at 14:36 +1000, Neil Brown wrote:
> On Thursday September 27, tom@opengridcomputing.com wrote:
> > 
> > Move the IP address fields to the svc_xprt structure. Note that this 
> > assumes that _all_ RPC transports must have IP based 4-tuples. This 
> > seems reasonable given the tight coupling with the portmapper etc...
> > Thoughts?
> 
> I don't think NFSv4 requires portmapper (or rpcbind) ... does it?
> 
> "Everything uses IP addresses" sounds a lot like "Everything is a
> socket".  I would have supported the latter strongly until RDMA came
> along.  Now I'm even less sure about the former.
> 
> How much cost would there be in leaving the address in the
> per-transport data?

Very little. The original patchset had it in the per-transport data.

> 
> NeilBrown


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
