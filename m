Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa11-09.prod.phx3.secureserver.net ([68.178.252.110]:55180
	"EHLO p3plsmtpa11-09.prod.phx3.secureserver.ne"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751740AbbGNMMj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jul 2015 08:12:39 -0400
Message-ID: <55A4FCB2.8090909@talpey.com>
Date: Tue, 14 Jul 2015 08:12:34 -0400
From: Tom Talpey <tom@talpey.com>
MIME-Version: 1.0
To: Sagi Grimberg <sagig@dev.mellanox.co.il>,
        "'Christoph Hellwig'" <hch@infradead.org>
CC: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Steve Wise <swise@opengridcomputing.com>, dledford@redhat.com,
        sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org,
        Oren Duer <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
References: <559BFE03.4020709@dev.mellanox.co.il> <20150707213628.GA5661@obsidianresearch.com> <559CD174.4040901@dev.mellanox.co.il> <20150708190842.GB11740@obsidianresearch.com> <559D983D.6000804@talpey.com> <20150708233604.GA20765@obsidianresearch.com> <559E54AB.2010905@dev.mellanox.co.il> <20150709170142.GA21921@obsidianresearch.com> <20150711102538.GB14741@infradead.org> <55A4134C.2040301@talpey.com> <20150714073756.GB7630@infradead.org> <55A4D4C6.6040907@dev.mellanox.co.il>
In-Reply-To: <55A4D4C6.6040907@dev.mellanox.co.il>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/14/2015 5:22 AM, Sagi Grimberg wrote:
> On 7/14/2015 10:37 AM, 'Christoph Hellwig' wrote:
>> On Mon, Jul 13, 2015 at 03:36:44PM -0400, Tom Talpey wrote:
>>> On 7/11/2015 6:25 AM, 'Christoph Hellwig' wrote:
>>>> I think what we need to support for now is FRMR as the primary target,
>>>> and FMR as a secondar[y].
>>>
>>> FMR is a *very* bad choice, for several reasons.
>>>
>>> 1) It's not supported by very many devices, in fact it might even
>>> be thought to be obsolete.
>>
>> It's support by the Mellanox adapters,
>
> *Older* Mellanox adapters. mlx5 (and future drivers I assume) will
> no longer support FMRs.

Right, but drop the word "will". Mlx5 (the current ConnectX-4) doesn't
support FMR. It's only supported by mlx4 and mthca drivers.

>> Based on looking at the consumers and the above table I think FMR
>> are still the better fallback for devices that don't support FR,
>
> It's better if you want it fast.

Do you guys think FMR is actually "fast"? Because it's not. Measure it.
It might have been marginally faster than other schemes in like, 2007,
and only when the mempool was there to leave the registrations open.
Don't go back there.

Tom.
