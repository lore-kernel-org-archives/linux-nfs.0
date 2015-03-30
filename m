Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:36306 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752736AbbC3PKQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2015 11:10:16 -0400
Received: by wgra20 with SMTP id a20so177890551wgr.3
        for <linux-nfs@vger.kernel.org>; Mon, 30 Mar 2015 08:10:15 -0700 (PDT)
Message-ID: <55196754.5010600@profitbricks.com>
Date: Mon, 30 Mar 2015 17:10:12 +0200
From: Michael Wang <yun.wang@profitbricks.com>
MIME-Version: 1.0
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        "ira.weiny" <ira.weiny@intel.com>
CC: Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>,
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
References: <551579CA.4030901@profitbricks.com> <55157B98.1060103@profitbricks.com> <20150327161319.GB28412@obsidianresearch.com> <20150327171631.GC27862@phlsvsds.ph.intel.com> <20150327172912.GA28901@obsidianresearch.com>
In-Reply-To: <20150327172912.GA28901@obsidianresearch.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/27/2015 06:29 PM, Jason Gunthorpe wrote:
> On Fri, Mar 27, 2015 at 01:16:31PM -0400, ira.weiny wrote:
>> [snip]
> http://www.spinics.net/lists/linux-rdma/msg22565.html
>
> ''Unlike IB, the iWARP protocol only allows 1 target/sink SGE in an
> rdma read''
>
> It is one of those annoying verbs is different on iWarp things.
>
> So the max sge in the query_verbs must only apply to send/rdma write
> on iWarp?
I found that actually we don't have to touch this one which
only used by HW driver currently.

I think we can leave these scenes there in device driver, since
vendor could have different way to classify the usage of transfer
and link layer.

Our purpose is to introduce IB core management approach, which
may not be applicable on device level, maybe we can just pass them :-)

Regards,
Michael Wang


>
> Jason

