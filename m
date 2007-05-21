From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 11/15] knfsd: RDMA transport core
Date: Mon, 21 May 2007 10:58:36 -0500
Message-ID: <1179763116.23385.240.camel@trinity.ogc.int>
References: <1179510352.23385.123.camel@trinity.ogc.int>
	<18001.17958.145762.704892@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Tom Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>, Greg Banks <gnb@sgi.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqAHQ-0006tS-9Z
	for nfs@lists.sourceforge.net; Mon, 21 May 2007 08:58:40 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HqAHT-0004Wj-3J
	for nfs@lists.sourceforge.net; Mon, 21 May 2007 08:58:43 -0700
In-Reply-To: <18001.17958.145762.704892@notabene.brown>
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

On Mon, 2007-05-21 at 17:11 +1000, Neil Brown wrote:
> On Friday May 18, tom@opengridcomputing.com wrote:
> > 
> > This file implements the core transport data management and I/O
> > path. The I/O path for RDMA involves receiving callbacks on interrupt 
> > context. Since all the svc transport locks are _bh locks we enqueue the 
> > transport on a list, schedule a tasklet to dequeue data indications from 
> > the RDMA completion queue. The tasklet in turn takes _bh locks to 
> > enqueue receive data indications on a list for the transport. The 
> > svc_rdma_recvfrom transport function dequeues data from this list in an 
> > NFSD thread context.
> 
> Cannot we simply change the usage of ->sp_lock to always disable
> interrupts?
> That would make this much simpler.  How much would it cost?

I don't think they are particularly expensive to acquire, but they add
incremental interrupt latency to the system. My impression is that the
general guidance from Linus et al is to avoid them if not absolutely
necessary. Trond's comments I think reflected this viewpoint as well,
but perhaps I'm just solving a problem that doesn't exist.

> 
> Alternatively, why can the network layer deliver these notification in
> "bh" context, but the ib layer wants to deliver them in irq context?
> Does doing it in irq context have lower latency or something?
> 

Yes, latency was certainly the design criteria in OFA. In practice, I
think we're talking nanoseconds (i.e. interrupt handler vs. tasklet),
however, when you're working with minimum latencies in the 2.8us range,
nanoseconds become statistically significant.

For our purposes, I don't think the latency is an issue. 

> NeilBrown


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
