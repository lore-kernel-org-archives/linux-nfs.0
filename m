Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37058 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738AbbGNJKl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jul 2015 05:10:41 -0400
Received: by wibud3 with SMTP id ud3so8708328wib.0
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jul 2015 02:10:40 -0700 (PDT)
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Tom Talpey <tom@talpey.com>
References: <559BFE03.4020709@dev.mellanox.co.il>
 <20150707213628.GA5661@obsidianresearch.com>
 <559CD174.4040901@dev.mellanox.co.il>
 <20150708190842.GB11740@obsidianresearch.com> <559D983D.6000804@talpey.com>
 <20150708233604.GA20765@obsidianresearch.com>
 <559E54AB.2010905@dev.mellanox.co.il>
 <20150709170142.GA21921@obsidianresearch.com>
 <20150711102538.GB14741@infradead.org> <55A4134C.2040301@talpey.com>
 <20150713201538.GA11681@obsidianresearch.com>
Cc: "'Christoph Hellwig'" <hch@infradead.org>,
        Steve Wise <swise@opengridcomputing.com>, dledford@redhat.com,
        sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org,
        Oren Duer <oren@mellanox.com>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <55A4D20C.2000904@dev.mellanox.co.il>
Date: Tue, 14 Jul 2015 12:10:36 +0300
MIME-Version: 1.0
In-Reply-To: <20150713201538.GA11681@obsidianresearch.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/13/2015 11:15 PM, Jason Gunthorpe wrote:
> On Mon, Jul 13, 2015 at 03:36:44PM -0400, Tom Talpey wrote:
>> On 7/11/2015 6:25 AM, 'Christoph Hellwig' wrote:
>>> I think what we need to support for now is FRMR as the primary target,
>>> and FMR as a secondar[y].
>>
>> FMR is a *very* bad choice, for several reasons.
>
> If an API can transparently support FMR, then I think it can also
> transparently support ib_get_phys_mr as an alternative, they look
> pretty similar... ?

Having an API that does FRMR/FMR/PHYS_MR is even worse from the ULP
PoV. If you expose an API that might schedule (PHYS_MR) it limits the
context that the caller is allowed to call in.

I'm 100% against an registration API that *might* schedule.
