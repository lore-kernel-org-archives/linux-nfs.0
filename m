Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:37564 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbbCaHjT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Mar 2015 03:39:19 -0400
Received: by wiaa2 with SMTP id a2so14757066wia.0
        for <linux-nfs@vger.kernel.org>; Tue, 31 Mar 2015 00:39:18 -0700 (PDT)
Message-ID: <551A4F24.6090405@profitbricks.com>
Date: Tue, 31 Mar 2015 09:39:16 +0200
From: Michael Wang <yun.wang@profitbricks.com>
MIME-Version: 1.0
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
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
References: <551579CA.4030901@profitbricks.com> <55157B98.1060103@profitbricks.com> <20150327161319.GB28412@obsidianresearch.com> <20150327171631.GC27862@phlsvsds.ph.intel.com> <20150327172912.GA28901@obsidianresearch.com> <55196754.5010600@profitbricks.com> <20150330223528.GB27728@obsidianresearch.com>
In-Reply-To: <20150330223528.GB27728@obsidianresearch.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/31/2015 12:35 AM, Jason Gunthorpe wrote:
> On Mon, Mar 30, 2015 at 05:10:12PM +0200, Michael Wang wrote:
>> I found that actually we don't have to touch this one which
>> only used by HW driver currently.
> I'm having a hard time understanding this, the code in question was in
>
> net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>
> Which is the NFS ULP, not a device driver.

I'm not familiar with this part too :-P but yes, it looks like an ulp
to support NFS.

Actually I'm thinking about Doug's idea to use rdma_transport_is_XX()
instead of the current basic helper, thus may be use rdma_transport_is_iwarp()
in here could be better, since it's actually a feature of iwarp tech
that RDMA Read only support one scatter-gather entry.

But I need more investigation on that idea, there are some part
especially inside device driver I'm not very clear, things could be more
easier if the semantic there is compatible with Doug's proposal ;-)

Regards,
Michael Wang

>
> Regards,
> Jason

