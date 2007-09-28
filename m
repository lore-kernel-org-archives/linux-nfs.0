From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC,
	PATCH 25/33] svc: Move the sockaddr information to svc_xprt
Date: Fri, 28 Sep 2007 14:36:20 +1000
Message-ID: <18172.33988.315021.626126@notabene.brown>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
	<20070927050227.12677.32560.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, gnb@sgi.com
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ib7aT-0006zw-34
	for nfs@lists.sourceforge.net; Thu, 27 Sep 2007 21:36:25 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ib7aX-0008El-Mi
	for nfs@lists.sourceforge.net; Thu, 27 Sep 2007 21:36:30 -0700
In-Reply-To: message from Tom Tucker on Thursday September 27
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

On Thursday September 27, tom@opengridcomputing.com wrote:
> 
> Move the IP address fields to the svc_xprt structure. Note that this 
> assumes that _all_ RPC transports must have IP based 4-tuples. This 
> seems reasonable given the tight coupling with the portmapper etc...
> Thoughts?

I don't think NFSv4 requires portmapper (or rpcbind) ... does it?

"Everything uses IP addresses" sounds a lot like "Everything is a
socket".  I would have supported the latter strongly until RDMA came
along.  Now I'm even less sure about the former.

How much cost would there be in leaving the address in the
per-transport data?

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
