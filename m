From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC,PATCH 7/15] knfsd: create RDMA transport in nfssvc
Date: Tue, 22 May 2007 16:21:49 +1000
Message-ID: <18002.35837.867422.793900@notabene.brown>
References: <1179510331.23385.120.camel@trinity.ogc.int>
	<18001.17544.798341.277657@notabene.brown>
	<1179762597.23385.231.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Tom Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>, Greg Banks <gnb@sgi.com>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqNkw-0006si-OA
	for nfs@lists.sourceforge.net; Mon, 21 May 2007 23:22:02 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HqNky-0001W8-Ug
	for nfs@lists.sourceforge.net; Mon, 21 May 2007 23:22:05 -0700
In-Reply-To: message from Tom Tucker on Monday May 21
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


I must sat that I am hitting acronym-overload hear.
RDMA  IB iWARP OFA-API SQ-CQ  SQ-WR sge  max_qp_rd_atom ....

But to the topic of registering the RDMA listening point....

I now understand the point of port 2050 I think.  RDMA adds to the
protocol.  As well as all the bytes of the RPC request, there is
information about different ..uhm... regions (?) of the message.
This is like a scatter-gather list?
It lets you put the "write" data correctly aligned into a page,
so that we could eventually use the 'splice' technology to achieve
zero-copy write.

But we still have this concept of a different transport to handle
properly. 

A bit of an aside: You mention that with "IB", IP is not used, so there
is no number.  I assume you mean no IP address of the client?  In that
situation, how do we identify the client for authorisation purposes?

More on-topic, we need to consider how this interacts with 
   /proc/fs/nfsd/portlist 

This file can be written to and read from.
When writing, you write a decimal number of a file descriptor.
That fd should be a socket on which to expect incoming requests -
either a UDP socket or a TCP socket that is listening.
How can we extend that to RDMA?  What sort of handle does user-space
use for talking over one of these DDP interfaces?
We could arrange that writing e.g.
    RDMA TCP 2050
did what you want, but I would much rather avoid that sort of stuff.

When reading from a file you get one line per active transport:
ipv4 tcp 0.0.0.0 2049
ipv4 udp 0.0.0.0 2049

What would we read for RDMA?  You say that it uses TCP.  Can it use
UDP instead?  Might it make sense to listen on only one interface?
Is there an IPv6 version of RDMA??

It seems like a real pity that it couldn't get shoe-horned into a
socket interface.
It would seem that the msg_control part of sendmsg/recvmsg would be
ideal for managing the details of data placement.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
