From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 7/15] knfsd: create RDMA transport in nfssvc
Date: Tue, 22 May 2007 10:59:42 -0500
Message-ID: <1179849582.9389.64.camel@trinity.ogc.int>
References: <1179510331.23385.120.camel@trinity.ogc.int>
	<18001.17544.798341.277657@notabene.brown>
	<1179762597.23385.231.camel@trinity.ogc.int>
	<18002.35837.867422.793900@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Tom Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>, Greg Banks <gnb@sgi.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqW32-0000bC-RS
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 08:13:17 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HqW35-0002H7-EN
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 08:13:19 -0700
In-Reply-To: <18002.35837.867422.793900@notabene.brown>
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

On Tue, 2007-05-22 at 16:21 +1000, Neil Brown wrote:
> I must sat that I am hitting acronym-overload hear.
> RDMA  IB iWARP OFA-API SQ-CQ  SQ-WR sge  max_qp_rd_atom ....
> 

Yes, it's a bit daunting.

> But to the topic of registering the RDMA listening point....
> 
> I now understand the point of port 2050 I think.  RDMA adds to the
> protocol.  As well as all the bytes of the RPC request, there is
> information about different ..uhm... regions (?) of the message.

Yes, they call them "chunks" and the RPCRDMA header contains a
"chunk-list". The chunk-list (built by the client and used by the
server) tells the transport where in the XDR to place data.

> This is like a scatter-gather list?

Yes, three in fact: one for reading data from the client's memory and
placing it in the request (read-list), one for writing data into the
client's memory as part of the REPLY (write-list), one for the REPLY
header itself (reply-list).

> It lets you put the "write" data correctly aligned into a page,
> so that we could eventually use the 'splice' technology to achieve
> zero-copy write.
> 
Yes.

> But we still have this concept of a different transport to handle
> properly. 
> 
> A bit of an aside: You mention that with "IB", IP is not used, so there
> is no number.  I assume you mean no IP address of the client?  In that
> situation, how do we identify the client for authorisation purposes?

The RDMA CMA (connection management agent) has a "sockets-like" API for
transport independent connection management. This API uses IP addresses
and port numbers for both IB and iWARP. To implement this on IB, IPoIB
and IP addresses are used for connection management, but not for data.
So for the purposes of authorization, it all works the same for all
transports. 

For the purpose of transport selection, we just need a unique id. I was
simply pointing out that IP protocol numbers don't uniquely identify
transports for RDMA.

> More on-topic, we need to consider how this interacts with 
>    /proc/fs/nfsd/portlist 

> This file can be written to and read from.
> When writing, you write a decimal number of a file descriptor.
> That fd should be a socket on which to expect incoming requests -
> either a UDP socket or a TCP socket that is listening.
> How can we extend that to RDMA?  What sort of handle does user-space
> use for talking over one of these DDP interfaces?
> We could arrange that writing e.g.
>     RDMA TCP 2050
> did what you want, but I would much rather avoid that sort of stuff.
> 
> When reading from a file you get one line per active transport:
> ipv4 tcp 0.0.0.0 2049
> ipv4 udp 0.0.0.0 2049
> 
> What would we read for RDMA?

I think this makes sense:

ipv4 rdma 0.0.0.0 2050
ipv6 rdma 0.0.0.0 2050

>   You say that it uses TCP.

It currently uses TCP or IB, but could ultimately use SCTP, etc...

>   Can it use
> UDP instead? 

No.

>  Might it make sense to listen on only one interface?

This has been discussed, but it runs against this "converged NIC" or
"universal NIC" idea that there is one NIC, one interface and one IP
address that solves ALL your problems. They even eat acronyms :-)

> Is there an IPv6 version of RDMA??

Eventually.

> 
> It seems like a real pity that it couldn't get shoe-horned into a
> socket interface.

I think it is a matter of the application of sufficient force ;-)  In
fairness, the I/O model is very different and the buffer management is
very-very different. This coupled with the extreme performance pressures
put on these transports led to the creation of a new API. Just getting
enough abstraction to combine iWARP and IB into a single API took a lot
of convincing.

> It would seem that the msg_control part of sendmsg/recvmsg would be
> ideal for managing the details of data placement.
> 

Er, probably not enough (or too much) there, but connection management
-- absolutely.

> NeilBrown


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
