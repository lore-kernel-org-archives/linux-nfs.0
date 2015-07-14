Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:37977 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830AbbGNHiC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jul 2015 03:38:02 -0400
Date: Tue, 14 Jul 2015 00:37:56 -0700
From: "'Christoph Hellwig'" <hch@infradead.org>
To: Tom Talpey <tom@talpey.com>
Cc: "'Christoph Hellwig'" <hch@infradead.org>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Steve Wise <swise@opengridcomputing.com>, dledford@redhat.com,
        sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org,
        Oren Duer <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Message-ID: <20150714073756.GB7630@infradead.org>
References: <559BFE03.4020709@dev.mellanox.co.il>
 <20150707213628.GA5661@obsidianresearch.com>
 <559CD174.4040901@dev.mellanox.co.il>
 <20150708190842.GB11740@obsidianresearch.com>
 <559D983D.6000804@talpey.com>
 <20150708233604.GA20765@obsidianresearch.com>
 <559E54AB.2010905@dev.mellanox.co.il>
 <20150709170142.GA21921@obsidianresearch.com>
 <20150711102538.GB14741@infradead.org>
 <55A4134C.2040301@talpey.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55A4134C.2040301@talpey.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 13, 2015 at 03:36:44PM -0400, Tom Talpey wrote:
> On 7/11/2015 6:25 AM, 'Christoph Hellwig' wrote:
> >I think what we need to support for now is FRMR as the primary target,
> >and FMR as a secondar[y].
> 
> FMR is a *very* bad choice, for several reasons.
> 
> 1) It's not supported by very many devices, in fact it might even
> be thought to be obsolete.

It's support by the Mellanox adapters, which might be a minority of
the drivers, but at least in the field I've been in the aboslute
majority of the deployed hardware.

It's the default in the SRP initiator and iSER initiators, and the
primary fallback in the NFS client if FRs aren't available.

I don't claim to be an expert on memory registrations models, as they
are horribly, horrible documents (baiscally not at all in the source
tree), so my knowledge is from looking at and using implementations as
well as this useful writeup from the NFS folks:

http://wiki.linux-nfs.org/wiki/index.php/NfsRdmaClient/MemRegModes

Which misses or downplays an important restriction of PHYS
registrations: They dont allow coalescing non-contiguous memory
into a single maping, which makes them totally unsuitable for iSER
which only allows a single rkey/offset/len pair and requires
additional RDMA READ/WRITE roundtrips and larger S/G lists for other
protocols.

Based on looking at the consumers and the above table I think FMR
are still the better fallback for devices that don't support FR,
but supporting PHYS MRs is easy enough that adding it to a common
layer seems easy enough if some cares enough to regularly test it.
