From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 00/35] SVC Transport Switch
Date: Tue, 02 Oct 2007 11:18:28 -0500
Message-ID: <1191341908.1565.5.camel@trinity.ogc.int>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071002152558.GC21675@fieldses.org>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net, gnb@sgi.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IckTH-0003V9-H4
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 09:19:43 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IckTM-0007Ke-9f
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 09:19:48 -0700
In-Reply-To: <20071002152558.GC21675@fieldses.org>
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

On Tue, 2007-10-02 at 11:25 -0400, J. Bruce Fields wrote:
> On Mon, Oct 01, 2007 at 02:14:26PM -0500, Tom Tucker wrote:
> > This is rev 2 of the new pluggable transport switch for
> > RPC servers. This version includes two new patches: one to add a field
> > for keeping track of a transport specific header that precedes the
> > RPC header for deferral processing, and one that cleans up some 
> > left over references to svc_sock in transport independent code.
> 
> Thanks! I've replaced this in for-mm at

Awesome, thanks.

> 
> 	git://linux-nfs.org/~bfields/linux.git for-mm
> 
> But still haven't taken the time to read through it carefully.
> 
> The review comments seem to mostly be on small stuff.  Are there any
> doubts about the basic approach?
> 

Not architecturally, however I was initially concerned about the size
and scope of the changes. I think we're passed that at this point, so
I'm comfortable with the approach. 

> By the way, are the only three transport classes we can forsee for now
> udp, tcp, and rdma?
> 

Those are the ones that I am directly working on. I don't know of any
others that are imminent.

> --b.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
