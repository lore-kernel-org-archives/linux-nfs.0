Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:32905 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067AbbGNJWU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jul 2015 05:22:20 -0400
Received: by widic2 with SMTP id ic2so32950354wid.0
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jul 2015 02:22:19 -0700 (PDT)
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
To: "'Christoph Hellwig'" <hch@infradead.org>, Tom Talpey <tom@talpey.com>
References: <559BFE03.4020709@dev.mellanox.co.il>
 <20150707213628.GA5661@obsidianresearch.com>
 <559CD174.4040901@dev.mellanox.co.il>
 <20150708190842.GB11740@obsidianresearch.com> <559D983D.6000804@talpey.com>
 <20150708233604.GA20765@obsidianresearch.com>
 <559E54AB.2010905@dev.mellanox.co.il>
 <20150709170142.GA21921@obsidianresearch.com>
 <20150711102538.GB14741@infradead.org> <55A4134C.2040301@talpey.com>
 <20150714073756.GB7630@infradead.org>
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Steve Wise <swise@opengridcomputing.com>, dledford@redhat.com,
        sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org,
        Oren Duer <oren@mellanox.com>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <55A4D4C6.6040907@dev.mellanox.co.il>
Date: Tue, 14 Jul 2015 12:22:14 +0300
MIME-Version: 1.0
In-Reply-To: <20150714073756.GB7630@infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/14/2015 10:37 AM, 'Christoph Hellwig' wrote:
> On Mon, Jul 13, 2015 at 03:36:44PM -0400, Tom Talpey wrote:
>> On 7/11/2015 6:25 AM, 'Christoph Hellwig' wrote:
>>> I think what we need to support for now is FRMR as the primary target,
>>> and FMR as a secondar[y].
>>
>> FMR is a *very* bad choice, for several reasons.
>>
>> 1) It's not supported by very many devices, in fact it might even
>> be thought to be obsolete.
>
> It's support by the Mellanox adapters,

*Older* Mellanox adapters. mlx5 (and future drivers I assume) will
no longer support FMRs.

> which might be a minority of
> the drivers, but at least in the field I've been in the aboslute
> majority of the deployed hardware.
>
> It's the default in the SRP initiator and iSER initiators, and the
> primary fallback in the NFS client if FRs aren't available.

We should gradually move away from that.

>
> I don't claim to be an expert on memory registrations models, as they
> are horribly, horrible documents (baiscally not at all in the source
> tree), so my knowledge is from looking at and using implementations as
> well as this useful writeup from the NFS folks:
>
> http://wiki.linux-nfs.org/wiki/index.php/NfsRdmaClient/MemRegModes
>
> Which misses or downplays an important restriction of PHYS
> registrations: They dont allow coalescing non-contiguous memory
> into a single maping, which makes them totally unsuitable for iSER
> which only allows a single rkey/offset/len pair and requires
> additional RDMA READ/WRITE roundtrips and larger S/G lists for other
> protocols.

I'm willing to add a proper memory_registration.txt under
Documentation/infiniband/ which would capture the items that
were brought up here.

>
> Based on looking at the consumers and the above table I think FMR
> are still the better fallback for devices that don't support FR,

It's better if you want it fast. I can't stress it enough, but IMO, the
fallback should *not* be in the API, but rather in the ULP.
Ideally, at some point it won't need to fall back, and we can remove
the API.

> but supporting PHYS MRs is easy enough that adding it to a common
> layer seems easy enough if some cares enough to regularly test it.
>

Someone needs a good reason to use it.
