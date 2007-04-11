From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: cel's patches under development
Date: Wed, 11 Apr 2007 08:32:32 -0400
Message-ID: <EXNANE01hkeTxtfkdpc00000864@exnane01.hq.netapp.com>
References: <460852BB.4080503@oracle.com>
	<200704110841.21291.olaf.kirch@oracle.com>
	<EXNANE01OF9vJZTuG5w00000863@exnane01.hq.netapp.com>
	<200704111402.50435.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Olaf Kirch <olaf.kirch@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hbbzr-0006bL-Fk
	for nfs@lists.sourceforge.net; Wed, 11 Apr 2007 05:32:23 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hbbzt-00050Z-Ra
	for nfs@lists.sourceforge.net; Wed, 11 Apr 2007 05:32:26 -0700
In-Reply-To: <200704111402.50435.olaf.kirch@oracle.com>
References: <460852BB.4080503@oracle.com>
	<200704110841.21291.olaf.kirch@oracle.com>
	<EXNANE01OF9vJZTuG5w00000863@exnane01.hq.netapp.com>
	<200704111402.50435.olaf.kirch@oracle.com>
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

At 08:02 AM 4/11/2007, Olaf Kirch wrote:
>> are cumbersome and don't lend themselves to dynamic loading. Also,
>> RDMA isn't a new protocol family, so it doesn't lend itself to an
>> IPv4/IPv6 and UDP/TCP kind of switch.
>
>How is it integrated on the client side? Wouldn't this be another
>transport in terms of Chuck's transport switch? If so, it would just
>provide a function for creating an RDMA specific rpc_data object
>that does the right thing.

Sure, it's switched, though frankly it's imperfect since the switch
selects based on address family / protocol naming just like others.
But once we hack^H^H^H^Hwork around that it just jumps to the
rdma transport setup.

>> The RDMA code turns out to not need this, because the xdr iov's
>> have a clear encoding for pagelists (head->pages[]->tail).
>
>But that means yet another non-obvious user of xdr_buf that makes
>it even harder to rewrite that whole code :-) Wouldn't it be better
>to make it explicit "here is a bunch of pages that I want you to
>put the bulk data into"?

Yep, and I agree. Not sure about the "non-obvious" thing though, it
seems like a direct application of the structure to me.

What I really want is some kind of upper layer hint that follows the xdr
buffer, perhaps as explicit as "this is a read or write", or at least "this is
bulk data". Basically, something from xdr_inline_pages/xdr_encode_pages
that indicates the purpose. How it's accounted for and represented in
iovecs isn't as much of a concern.

I think a second part of your proposal is that there'd be a new callout
to set up these buffers for i/o prior to send marshalling. For RDMA we
basically do that in the transport switch send routine, where we insert
the per-transport headers (RDMA chunk headers, TCP just inserts its
record marker). I'm stil thinking about whether there's some advantage
to a separate callout.

Tom.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
