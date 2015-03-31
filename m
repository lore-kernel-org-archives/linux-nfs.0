Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa08-04.prod.phx3.secureserver.net ([173.201.193.105]:39585
	"EHLO p3plsmtpa08-04.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753154AbbCaODx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Mar 2015 10:03:53 -0400
Message-ID: <551AA78D.4040502@talpey.com>
Date: Tue, 31 Mar 2015 09:56:29 -0400
From: Tom Talpey <tom@talpey.com>
MIME-Version: 1.0
To: Michael Wang <yun.wang@profitbricks.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
CC: "ira.weiny" <ira.weiny@intel.com>, Roland Dreier <roland@kernel.org>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>, linux-rdma@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "David S. Miller" <davem@davemloft.net>,
        Or Gerlitz <ogerlitz@mellanox.com>, Moni Shoua <monis@mellanox.com>,
        PJ Waskiewicz <pj.waskiewicz@solidfire.com>,
        Tatyana Nikolova <Tatyana.E.Nikolova@intel.com>,
        Yan Burman <yanb@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Bart Van Assche <bvanassche@acm.org>,
        Yann Droneaud <ydroneaud@opteya.com>,
        Colin Ian King <colin.king@canonical.com>,
        Majd Dibbiny <majd@mellanox.com>, Jiri Kosina <jkosina@suse.cz>,
        Matan Barak <matanb@mellanox.com>, Alex Estrin <alex.estrin@intel.com>,
        Doug Ledford <dledford@redhat.com>, Eric Dumazet <edumazet@google.com>,
        Erez Shitrit <erezsh@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>,
        Haggai Eran <haggaie@mellanox.com>,
        Shachar Raindel <raindel@mellanox.com>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>,
        Steve Wise <swise@opengridcomputing.com>, Tom Tucker <tom@ogc.us>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC PATCH 08/11] IB/Verbs: Use management helper has_iwarp()
 for, iwarp-check
References: <551579CA.4030901@profitbricks.com> <55157B98.1060103@profitbricks.com> <20150327161319.GB28412@obsidianresearch.com> <20150327171631.GC27862@phlsvsds.ph.intel.com> <20150327172912.GA28901@obsidianresearch.com> <55196754.5010600@profitbricks.com> <20150330223528.GB27728@obsidianresearch.com> <551A4F24.6090405@profitbricks.com> <551A82D3.70806@talpey.com> <551A87D3.2070306@profitbricks.com>
In-Reply-To: <551A87D3.2070306@profitbricks.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 3/31/2015 7:41 AM, Michael Wang wrote:
> Hi, Tom
>
> Thanks for the comments :-)
>
> On 03/31/2015 01:19 PM, Tom Talpey wrote:

[oops - repeating my reply with full cc's]

>> [snip]
>>
>>>
>>> Actually I'm thinking about Doug's idea to use rdma_transport_is_XX()
>>> instead of the current basic helper, thus may be use rdma_transport_is_iwarp()
>>> in here could be better, since it's actually a feature of iwarp tech
>>> that RDMA Read only support one scatter-gather entry.
>>
>> No, you should expose an attribute to surface the maximum length of
>> the remote gather list, which varies by adapter as well as protocol.
>> The fact that iWARP is different from IB is not relevant, and conflates
>> unrelated properties.
>
> To be confirmed, so your point is that the max-read-sges will be different
> even the transport is the same IWRAP, and that depends on the capability
> of adapter, correct?

Yes, in fact the iWARP protocol does not preclude multiple read SGEs,
even though most iWARP implementations have chosen to support just one.

Even for multi-SGE-capable adapters, there is a limit of SGL size, based
on the adapter's work request format and other factors. So my argument
is that upper layers can and should query that, not make a blanket
decision based on protocol type.

>
> I currently only find this one place where infer max-read-sges from
> transport type, it looks more like a special case to me rather than a generic
> method we could exposed... and also  not very related with IB management
> helper concept IMHO.

It is most certainly not a special case, but you could decide to
introduce it in many ways. I'm not commenting on that.

My main concern is that you do not introduce a new and clumsy "is iWARP"
rule as an adapter-specific API requirement to expose the RDMA Read SGE
behavior. That's what your initial message seemed to imply?


