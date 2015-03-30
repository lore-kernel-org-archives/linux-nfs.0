Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:36211 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753259AbbC3Ial (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2015 04:30:41 -0400
Received: by wibg7 with SMTP id g7so93174248wib.1
        for <linux-nfs@vger.kernel.org>; Mon, 30 Mar 2015 01:30:40 -0700 (PDT)
Message-ID: <551909AC.2030304@profitbricks.com>
Date: Mon, 30 Mar 2015 10:30:36 +0200
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
Subject: Re: [RFC PATCH 07/11] IB/Verbs: Use management helper has_mcast()
 and, cap_mcast() for mcast-check
References: <551579CA.4030901@profitbricks.com> <55157B71.6040505@profitbricks.com> <20150327162820.GC28412@obsidianresearch.com> <20150327170508.GB27862@phlsvsds.ph.intel.com> <20150327174727.GB28901@obsidianresearch.com>
In-Reply-To: <20150327174727.GB28901@obsidianresearch.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/27/2015 06:47 PM, Jason Gunthorpe wrote:
> On Fri, Mar 27, 2015 at 01:05:08PM -0400, ira.weiny wrote:
>
>>> But it seems redudent, since mcast_add_one will already not add a port that is
>>> not IB, so mcast_event_handler is not callable. Something to do with
>>> rocee/ib switching?
>> I'm not sure about this either.  This check seems to be necessary only on a
>> per-port level.  It does seem apparent that one can't go from Eth to IB.  What
>> happens if you go from IB to Eth on the port?
> Hmm... I see a mlx4_change_port_types which ultimately calls
> ib_unregister_device, which suggests the port type doesn't change at
> runtime (yay)
Yeah, seems like mlx4 will reinitialize the device when port link layer
changed.

I've take a look at other HW, they directly return a static type or
infer from transport type (I suppose this won't change dynamically).

Thus I also agreed check inside mcast_event_handler() is unnecessary,
maybe we can change that logical to WARN_ON(!cap_mcast()) ?

Regards,
Michael Wang

>
> So maybe these checks really are redundant?
>
> Jason

