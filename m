From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [RFC,PATCH 7/15] knfsd: create RDMA transport in nfssvc
Date: Wed, 23 May 2007 11:00:39 -0400
Message-ID: <EXNANE01WtIIZS2TRqf00000a5e@exnane01.hq.netapp.com>
References: <1179510331.23385.120.camel@trinity.ogc.int>
	<18001.17544.798341.277657@notabene.brown>
	<1179762597.23385.231.camel@trinity.ogc.int>
	<18002.35837.867422.793900@notabene.brown>
	<1179849582.9389.64.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>, Greg Banks <gnb@sgi.com>
To: Neil Brown <neilb@suse.de>,
	Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqsL5-0007qc-RA
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 08:01:26 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HqsL5-0001R9-8h
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 08:01:26 -0700
In-Reply-To: <1179849582.9389.64.camel@trinity.ogc.int>
References: <1179510331.23385.120.camel@trinity.ogc.int>
	<18001.17544.798341.277657@notabene.brown>
	<1179762597.23385.231.camel@trinity.ogc.int>
	<18002.35837.867422.793900@notabene.brown>
	<1179849582.9389.64.camel@trinity.ogc.int>
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

Sorry, I've been travelling until this morning. Replies to port 2050 questions
and other transport issues below.

At 11:59 AM 5/22/2007, Tom Tucker wrote:
>On Tue, 2007-05-22 at 16:21 +1000, Neil Brown wrote:
>> I now understand the point of port 2050 I think.  RDMA adds to the
>> protocol.  As well as all the bytes of the RPC request, there is

I don't want to confuse things again, but I do want to add something about
the "protocol" question. As I mentioned before, the notion of an RPC transport
is actually two things, an API and a set of protocol semantics, e.g. sockets/TCP,
which we somewhat conflate into a single designator.

In the case of RDMA, the underlying protocol is actually not important. The
RDMA semantics are well-defined for any transport (you can read about
the RPC/RDMA protocol assumptions in the internet draft). Basically, the
RDMA abstraction hides the protocol almost completely.

[RDMA requirements are on page 3 ff]
<http://www.ietf.org/internet-drafts/draft-ietf-nfsv4-rpcrdma-05.txt>

The exception, which turns out to be not much of an exception at all,
is the addressing. The reason it's not an issue is the Infiniband connection
manager, which magically allows IP addresses (IPv4 currently) to be passed
to connect. As a result, there's no need for an RDMA protocol selector,
the IP connect routing handles hardware selection and hides any notion
that IB or iWARP is handling the connection. This is a Good Thing, it makes
RPC totally RDMA-implementation agnostic.

As for why port 2050 exists, it's because the server needs to know whether
to expect RPC/TCP framing or RPC/RDMA on an incoming connection over
iWARP. Over Infiniband there's no ambiguity since connections are always
in RDMA mode, but over iWARP there is an optional "step-up" negotiation.
We need a new port to know whether the negotiation has been bypassed.
There is discussion of this in the nfsdirect Internet Draft.

[Port discussion on page 6 ff]
<http://www.ietf.org/internet-drafts/draft-ietf-nfsv4-nfsdirect-05.txt>

>For the purpose of transport selection, we just need a unique id. I was
>simply pointing out that IP protocol numbers don't uniquely identify
>transports for RDMA.

I'll pile on here. This is important, it goes to the heart of how we "name" RPC
transports. Currently, the client switch uses a protocol id (UDP=17, TCP=6),
and this number is the de facto name of the transport. The address family
of the server's address also comes into play.

For now, we've simply stolen either 255 or 256 to register the RDMA transport
(we changed the numbers at one point IIRC). This may be okay, or maybe not.
Personally, I'd prefer a string-based transport naming, but numbers are fine
too, as long as everyone agrees.

>> When reading from a file you get one line per active transport:
>> ipv4 tcp 0.0.0.0 2049
>> ipv4 udp 0.0.0.0 2049
>> 
>> What would we read for RDMA?
>
>I think this makes sense:
>
>ipv4 rdma 0.0.0.0 2050
>ipv6 rdma 0.0.0.0 2050

Like that - strings. The normal TCP transport would be "ipv4-tcp" for
instance.

For RDMA however, the "ipv4" is only significant to the RDMA connection
manager. It serves only to describe the format of the following address.
So while it makes sense, it sort of doesn't matter.

By the way, "ipv6 rdma 0.0.0.0 2050" doesn't make sense, because "0.0.0.0"
isn't an ipv6 address.


>>   You say that it uses TCP.
>
>It currently uses TCP or IB, but could ultimately use SCTP, etc...

It makes absolutely no difference whether TCP is used as the RDMA transport,
from the perspoective of the upper layer. The semantics would be identical
if SCTP were used. So, I would not include "tcp" in the rdma transport selector
at all.

Tom.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
