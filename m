Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:49618 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753544AbbGWTDF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jul 2015 15:03:05 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Hefty, Sean'" <sean.hefty@intel.com>,
        "'Christoph Hellwig'" <hch@infradead.org>
Cc: "'Sagi Grimberg'" <sagig@dev.mellanox.co.il>,
        "'Steve Wise'" <swise@ogc.us>,
        "'Jason Gunthorpe'" <jgunthorpe@obsidianresearch.com>,
        "'Tom Talpey'" <tom@talpey.com>,
        "'Doug Ledford'" <dledford@redhat.com>, <sagig@mellanox.com>,
        <ogerlitz@mellanox.com>, <roid@mellanox.com>,
        <linux-rdma@vger.kernel.org>, <eli@mellanox.com>,
        <target-devel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <trond.myklebust@primarydata.com>, <bfields@fieldses.org>,
        "'Oren Duer'" <oren@mellanox.com>
References: <20150708190842.GB11740@obsidianresearch.com> <20150708203205.GA21847@infradead.org> <20150709000337.GE16812@obsidianresearch.com> <559EF332.7060103@redhat.com> <20150709225306.GA30741@obsidianresearch.com> <559FC710.1050307@talpey.com> <20150710161108.GA19042@obsidianresearch.com> <CCB6E837-88FF-4DBB-976D-4CF56396A1A1@ogc.us> <55A24571.60902@dev.mellanox.co.il> <00e201d0be6a$e49bc910$add35b30$@opengridcomputing.com> <20150714194512.GA25887@infradead.org> <00f901d0be6f$70c96b00$525c4100$@opengridcomputing.com> <1828884A29C6694DAF28B7E6B8A82373A901C9A5@ORSMSX109.amr.corp.intel.com>
In-Reply-To: <1828884A29C6694DAF28B7E6B8A82373A901C9A5@ORSMSX109.amr.corp.intel.com>
Subject: RE: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Date: Thu, 23 Jul 2015 14:03:10 -0500
Message-ID: <009e01d0c57a$37d5b9e0$a7812da0$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: Hefty, Sean [mailto:sean.hefty@intel.com]
> Sent: Thursday, July 23, 2015 1:53 PM
> To: Steve Wise; 'Christoph Hellwig'
> Cc: 'Sagi Grimberg'; 'Steve Wise'; 'Jason Gunthorpe'; 'Tom Talpey'; 'Doug Ledford'; sagig@mellanox.com; ogerlitz@mellanox.com;
> roid@mellanox.com; linux-rdma@vger.kernel.org; eli@mellanox.com; target-devel@vger.kernel.org; linux-nfs@vger.kernel.org;
> trond.myklebust@primarydata.com; bfields@fieldses.org; 'Oren Duer'
> Subject: RE: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
> 
> > There is confusion about lkeys and rkeys with regard to iWARP.  In the
> > iWARP verbs, there is no distinction between an lkey and
> > rkey: they are the same key, called a Steering Tag or STAG.  When you
> > create a MR, the lkey == rkey == STAG for iwarp transports.
> > Somewhat related, but really a different issue, is that SGEs that are the
> > target of a read need REMOTE_WRITE access flags on their
> > STAG for iWARP.
> >
> > Clear as mud? :)
> 
> This may be a nit, but IMO, the use of the term 'rkey' versus 'stag' matters.  They convey different ways of finding a data
buffer.  For
> example, do you locate a buffer using the stag, then verify that the offset + length fits into the target buffer?  

Yes.  HW always uses the stag to locate a record that contains the stag state (valid or invalid), the access flags, the 8b key, the
va_base, length, PBL describing the host pages, etc.  HW validates all that before using the buffer.  NOTE: An stag of 0 is the
special local-dma-lkey which HW treats differently: If the stag is 0, then the address in the SGE is the bus/dma address itself and
no lookup of a MR/PBL/etc is needed.   Stag 0 can ONLY be used by kernel users and MUST never be accepted/used from an ingress
packet and MUST never be emitted on the wire in a READ or WRITE.

> Or do you locate the buffer
> by address, then verify that the key matches?
> 

This is never done.

> Consider if we allow an app to specify the rkey/stag, or reference the buffer using an offset, rather than a virtual address.
> 
> This seems to be part of the difference between an lkey and an rkey.



