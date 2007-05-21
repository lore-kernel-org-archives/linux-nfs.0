From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC,PATCH 11/15] knfsd: RDMA transport core
Date: Mon, 21 May 2007 17:11:34 +1000
Message-ID: <18001.17958.145762.704892@notabene.brown>
References: <1179510352.23385.123.camel@trinity.ogc.int>
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
	id 1Hq23U-0004As-DY
	for nfs@lists.sourceforge.net; Mon, 21 May 2007 00:11:44 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hq23W-0002lm-No
	for nfs@lists.sourceforge.net; Mon, 21 May 2007 00:11:47 -0700
In-Reply-To: message from Tom Tucker on Friday May 18
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

On Friday May 18, tom@opengridcomputing.com wrote:
> 
> This file implements the core transport data management and I/O
> path. The I/O path for RDMA involves receiving callbacks on interrupt 
> context. Since all the svc transport locks are _bh locks we enqueue the 
> transport on a list, schedule a tasklet to dequeue data indications from 
> the RDMA completion queue. The tasklet in turn takes _bh locks to 
> enqueue receive data indications on a list for the transport. The 
> svc_rdma_recvfrom transport function dequeues data from this list in an 
> NFSD thread context.

Cannot we simply change the usage of ->sp_lock to always disable
interrupts?
That would make this much simpler.  How much would it cost?

Alternatively, why can the network layer deliver these notification in
"bh" context, but the ib layer wants to deliver them in irq context?
Does doing it in irq context have lower latency or something?

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
