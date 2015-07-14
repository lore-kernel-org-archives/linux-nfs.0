Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:33450 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752069AbbGNNVw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jul 2015 09:21:52 -0400
Received: by widic2 with SMTP id ic2so38102558wid.0
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jul 2015 06:21:51 -0700 (PDT)
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
To: Tom Talpey <tom@talpey.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
References: <559CD174.4040901@dev.mellanox.co.il>
 <20150708081320.GB24203@infradead.org> <559CF5E8.6080000@dev.mellanox.co.il>
 <20150708102035.GA28421@infradead.org> <559D0498.9050809@dev.mellanox.co.il>
 <1828884A29C6694DAF28B7E6B8A82373A8FFD4C0@ORSMSX109.amr.corp.intel.com>
 <559E34F8.4080507@dev.mellanox.co.il>
 <2189DB0A-DD00-4818-AC17-020FCE42D39B@oracle.com>
 <20150710193409.GA9815@infradead.org> <55A21BF4.7090601@dev.mellanox.co.il>
 <20150713165007.GD23832@obsidianresearch.com>
 <55A4C2FA.9060707@dev.mellanox.co.il> <55A4FF93.4090406@talpey.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        "Hefty, Sean" <sean.hefty@intel.com>,
        Steve Wise <swise@opengridcomputing.com>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "sagig@mellanox.com" <sagig@mellanox.com>,
        "ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
        "roid@mellanox.com" <roid@mellanox.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "eli@mellanox.com" <eli@mellanox.com>,
        "target-devel@vger.kernel.org" <target-devel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Oren Duer <oren@mellanox.com>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <55A50CEA.1090504@dev.mellanox.co.il>
Date: Tue, 14 Jul 2015 16:21:46 +0300
MIME-Version: 1.0
In-Reply-To: <55A4FF93.4090406@talpey.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/14/2015 3:24 PM, Tom Talpey wrote:
> On 7/14/2015 4:06 AM, Sagi Grimberg wrote:
>> All protocols cares about transferring data and sending messages, so
>> it's not a good enough reason for a poor registration method choice.
>> This just emphasizes why we need to converge to a single method.
>
> In my opinion, we already have it.
>
> For local registrations, ib_reg_phys_mr()/ib_get_dma_mr(). These are not
> quite equivalent, btw.
>
> For remote registrations, ib_post_send(FRMR).
>
> Unfortunately, there exist ancient adapters in-tree that don't support
> FRMR, and some ULPs have attempted to work on them. That's why the
> situation is confusing.
>

Exactly. This is why I'd prefer not to make an effort to have a unified
API that maintains any form of (confusing) fallback policy.
