Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:56031 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752038AbbGNPkg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jul 2015 11:40:36 -0400
Date: Tue, 14 Jul 2015 08:40:31 -0700
From: "'Christoph Hellwig'" <hch@infradead.org>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Cc: "'Christoph Hellwig'" <hch@infradead.org>, Tom Talpey <tom@talpey.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Steve Wise <swise@opengridcomputing.com>, dledford@redhat.com,
        sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org,
        Oren Duer <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Message-ID: <20150714154031.GD11026@infradead.org>
References: <559CD174.4040901@dev.mellanox.co.il>
 <20150708190842.GB11740@obsidianresearch.com>
 <559D983D.6000804@talpey.com>
 <20150708233604.GA20765@obsidianresearch.com>
 <559E54AB.2010905@dev.mellanox.co.il>
 <20150709170142.GA21921@obsidianresearch.com>
 <20150711102538.GB14741@infradead.org>
 <55A4134C.2040301@talpey.com>
 <20150714073756.GB7630@infradead.org>
 <55A4D4C6.6040907@dev.mellanox.co.il>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55A4D4C6.6040907@dev.mellanox.co.il>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 14, 2015 at 12:22:14PM +0300, Sagi Grimberg wrote:
> It's better if you want it fast. I can't stress it enough, but IMO, the
> fallback should *not* be in the API, but rather in the ULP.
> Ideally, at some point it won't need to fall back, and we can remove
> the API.

But if all driver need to impement the same dispatch between
FR/FMR/ALLPHYS and having similar fast path hacks something is wrong.

Maybe we should start but just implementing the helper you suggest in
separae FR/FMR/ALLPHYS handlers while phasing out hacks like use
ALLPHYS for single segment registrations or if other registrations
fail.  And as a second step we can decide if their are similar enough
to consolidate them, or if we should simply kick out FMR and/or ALLPHYS
and thus not support any in-kernel consumers for old HCAs.

n the meantime let's kick off the now aready unuses memwindow in-kernel
API (I fear the userlevel one will have to stay forever) and the
about to be unused by proper in-kernel code PHYS MRs.
