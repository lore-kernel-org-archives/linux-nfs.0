Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:36196 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752247AbbGNT6U (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jul 2015 15:58:20 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Christoph Hellwig'" <hch@infradead.org>
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
References: <20150708190842.GB11740@obsidianresearch.com> <20150708203205.GA21847@infradead.org> <20150709000337.GE16812@obsidianresearch.com> <559EF332.7060103@redhat.com> <20150709225306.GA30741@obsidianresearch.com> <559FC710.1050307@talpey.com> <20150710161108.GA19042@obsidianresearch.com> <CCB6E837-88FF-4DBB-976D-4CF56396A1A1@ogc.us> <55A24571.60902@dev.mellanox.co.il> <00e201d0be6a$e49bc910$add35b30$@opengridcomputing.com> <20150714194512.GA25887@infradead.org>
In-Reply-To: <20150714194512.GA25887@infradead.org>
Subject: RE: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Date: Tue, 14 Jul 2015 14:58:23 -0500
Message-ID: <00f901d0be6f$70c96b00$525c4100$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: 'Christoph Hellwig' [mailto:hch@infradead.org]
> Sent: Tuesday, July 14, 2015 2:45 PM
> To: Steve Wise
> Cc: 'Sagi Grimberg'; 'Steve Wise'; 'Jason Gunthorpe'; 'Tom Talpey'; 'Doug Ledford'; 'Christoph Hellwig'; sagig@mellanox.com;
> ogerlitz@mellanox.com; roid@mellanox.com; linux-rdma@vger.kernel.org; eli@mellanox.com; target-devel@vger.kernel.org; linux-
> nfs@vger.kernel.org; trond.myklebust@primarydata.com; bfields@fieldses.org; 'Oren Duer'
> Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
> 
> On Tue, Jul 14, 2015 at 02:25:50PM -0500, Steve Wise wrote:
> > if (device_supports_fastreg && device_supports_signature)
> >         use FRMR
> > else
> >         use DMAMR
> >
> > Shouldn't we just recode it this way?
> >
> > if (device_supports_fastreg)
> >         use FRMR
> > else
> >         use DMAMR
> 
> How does IB_DEVICE_LOCAL_DMA_LKEY (and ->local_dma_lkey) play into
> this?  Seems like that should be the preferred option if supported.
>

The local_dma_lkey can be used in any rdma sge that requires an lkey.  It is supported for kernel-mode only.  So if you're only ever
going to use the lkey for IO, you really don't need a DMA_MR at all, unless you want to somehow partition up your work load by
protection domain.  But I claim for lkeys, the PD doesn't really protect anything since the remote peers can't use it anyway.  

> Interestingly enough various iWarp driver seem to support this option,
> what's the story behind that?  The (to me surprising) conclusion on
> the list was that iWarp would always need a memory regireations that
> also allows remove writes even for lkeys, but from looking at the
> users of IB_DEVICE_LOCAL_DMA_LKEY / local_dma_lkey that seem to
> prefer that over creating a MR.

There is confusion about lkeys and rkeys with regard to iWARP.  In the iWARP verbs, there is no distinction between an lkey and
rkey: they are the same key, called a Steering Tag or STAG.  When you create a MR, the lkey == rkey == STAG for iwarp transports.
Somewhat related, but really a different issue, is that SGEs that are the target of a read need REMOTE_WRITE access flags on their
STAG for iWARP. 

Clear as mud? :)


