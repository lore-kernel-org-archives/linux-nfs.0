Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:51635 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753657AbbGWSxV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jul 2015 14:53:21 -0400
From: "Hefty, Sean" <sean.hefty@intel.com>
To: Steve Wise <swise@opengridcomputing.com>,
        "'Christoph Hellwig'" <hch@infradead.org>
CC: "'Sagi Grimberg'" <sagig@dev.mellanox.co.il>,
        "'Steve Wise'" <swise@ogc.us>,
        "'Jason Gunthorpe'" <jgunthorpe@obsidianresearch.com>,
        "'Tom Talpey'" <tom@talpey.com>,
        "'Doug Ledford'" <dledford@redhat.com>,
        "sagig@mellanox.com" <sagig@mellanox.com>,
        "ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
        "roid@mellanox.com" <roid@mellanox.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "eli@mellanox.com" <eli@mellanox.com>,
        "target-devel@vger.kernel.org" <target-devel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "trond.myklebust@primarydata.com" <trond.myklebust@primarydata.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "'Oren Duer'" <oren@mellanox.com>
Subject: RE: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Date: Thu, 23 Jul 2015 18:53:19 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373A901C9A5@ORSMSX109.amr.corp.intel.com>
References: <20150708190842.GB11740@obsidianresearch.com>
 <20150708203205.GA21847@infradead.org>
 <20150709000337.GE16812@obsidianresearch.com> <559EF332.7060103@redhat.com>
 <20150709225306.GA30741@obsidianresearch.com> <559FC710.1050307@talpey.com>
 <20150710161108.GA19042@obsidianresearch.com>
 <CCB6E837-88FF-4DBB-976D-4CF56396A1A1@ogc.us>
 <55A24571.60902@dev.mellanox.co.il>
 <00e201d0be6a$e49bc910$add35b30$@opengridcomputing.com>
 <20150714194512.GA25887@infradead.org>
 <00f901d0be6f$70c96b00$525c4100$@opengridcomputing.com>
In-Reply-To: <00f901d0be6f$70c96b00$525c4100$@opengridcomputing.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> There is confusion about lkeys and rkeys with regard to iWARP.  In the
> iWARP verbs, there is no distinction between an lkey and
> rkey: they are the same key, called a Steering Tag or STAG.  When you
> create a MR, the lkey == rkey == STAG for iwarp transports.
> Somewhat related, but really a different issue, is that SGEs that are the
> target of a read need REMOTE_WRITE access flags on their
> STAG for iWARP.
> 
> Clear as mud? :)

This may be a nit, but IMO, the use of the term 'rkey' versus 'stag' matters.  They convey different ways of finding a data buffer.  For example, do you locate a buffer using the stag, then verify that the offset + length fits into the target buffer?  Or do you locate the buffer by address, then verify that the key matches?

Consider if we allow an app to specify the rkey/stag, or reference the buffer using an offset, rather than a virtual address.

This seems to be part of the difference between an lkey and an rkey. 
