Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:32926 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758287AbbGHKFS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jul 2015 06:05:18 -0400
Received: by wiwl6 with SMTP id l6so339555957wiw.0
        for <linux-nfs@vger.kernel.org>; Wed, 08 Jul 2015 03:05:17 -0700 (PDT)
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
To: "'Christoph Hellwig'" <hch@infradead.org>
References: <559A340E.9000000@dev.mellanox.co.il>
 <001601d0b7f9$3e1d6d40$ba5847c0$@opengridcomputing.com>
 <559AAA22.1000608@dev.mellanox.co.il> <20150707090001.GB11736@infradead.org>
 <559B9891.8060907@dev.mellanox.co.il>
 <000b01d0b8bd$f2bfcc10$d83f6430$@opengridcomputing.com>
 <20150707161751.GA623@obsidianresearch.com>
 <559BFE03.4020709@dev.mellanox.co.il>
 <20150707213628.GA5661@obsidianresearch.com>
 <559CD174.4040901@dev.mellanox.co.il> <20150708081320.GB24203@infradead.org>
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Steve Wise <swise@opengridcomputing.com>, dledford@redhat.com,
        sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org,
        Oren Duer <oren@mellanox.com>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <559CF5E8.6080000@dev.mellanox.co.il>
Date: Wed, 8 Jul 2015 13:05:28 +0300
MIME-Version: 1.0
In-Reply-To: <20150708081320.GB24203@infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/8/2015 11:13 AM, 'Christoph Hellwig' wrote:
> On Wed, Jul 08, 2015 at 10:29:56AM +0300, Sagi Grimberg wrote:
>> I don't necessarily agree. The API we'd want is a single API at all
>> the call sites to all types of MRs. We have different QP types, and
>> still we don't have an allocation API for each and every one.
>> I honestly don't see why we have that for MRs.
>>
>> If we can converge to a single API for MR allocation we can just get it
>> right once.
>
> That sounds even better in the long run, but sorting out one problem at
> a time seems like the easier way forward.
>

If we agree to consolidate on a single MR allocation API, I don't see
how this wrapper is moving us forward. But if you guys prefer to have it
than I don't have a hard objection.

Sagi.
