Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:33285 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753523AbbC0JwO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 05:52:14 -0400
Received: by wgbgs4 with SMTP id gs4so2269561wgb.0
        for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 02:52:13 -0700 (PDT)
Message-ID: <5515284A.3030106@profitbricks.com>
Date: Fri, 27 Mar 2015 10:52:10 +0100
From: Michael Wang <yun.wang@profitbricks.com>
MIME-Version: 1.0
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
CC: Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, Roland Dreier <roland@kernel.org>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        Ira Weiny <ira.weiny@intel.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        Moni Shoua <monis@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>,
        Tatyana Nikolova <Tatyana.E.Nikolova@intel.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Yan Burman <yanb@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Bart Van Assche <bvanassche@acm.org>,
        Yann Droneaud <ydroneaud@opteya.com>,
        Colin Ian King <colin.king@canonical.com>,
        Jiri Kosina <jkosina@suse.cz>, Matan Barak <matanb@mellanox.com>,
        Majd Dibbiny <majd@mellanox.com>,
        Dan Carpenter <dan.carpenter@oracle.com>, Mel Gorman <mgorman@suse.de>,
        Alex Estrin <alex.estrin@intel.com>,
        Eric Dumazet <edumazet@google.com>, Erez Shitrit <erezsh@mellanox.com>,
        Sagi Grimberg <sagig@mellanox.com>, Haggai Eran <haggaie@mellanox.com>,
        Shachar Raindel <raindel@mellanox.com>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>, Tom Tucker <tom@ogc.us>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/2 RESEND] IB/Verbs: Use helpers to refine the checking
 on transport and link layer
References: <5512CFB0.1050108@profitbricks.com> <1427378940.21101.100.camel@redhat.com> <55142DFD.2060100@profitbricks.com> <1427387258.21101.124.camel@redhat.com> <55143AAC.8040206@profitbricks.com> <20150326211334.GA3359@obsidianresearch.com>
In-Reply-To: <20150326211334.GA3359@obsidianresearch.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, Jason

Thanks for the reply :-)

On 03/26/2015 10:13 PM, Jason Gunthorpe wrote:
> On Thu, Mar 26, 2015 at 05:58:20PM +0100, Michael Wang wrote:
>
>> The questions is just wondering how the transition method could be, but
>> if we have to do the changes for vendor, that sounds like a tough job...
> I would see changing how the information is represented in the struct
> as a follow on issue. The first patch should go through and replace
> all direct access to the link layer/transport/etc with an
> appropriately narrow is_XX() test like Doug was suggesting.

Sounds like a good plan, I'd like to change the second patch to
introduce these new helpers, later when we come to a good
solution, rework should be far more easier.

>
> That means looking at each code site and determining what it needs,
> making a is_XX for it and a kdoc describing exactly what is needed for
> the test to return true.

Basically I found there are three kind of check in current
implementation:

1. check transport type of device only
    I'd like to use helper has_XX(device)
    which means some port of the device has XX capability.

2. check link layer of device's port only
    I'd like to use helper cap_XX(device, port)
    which means the port has XX capability

3. check both the transport type and link layer
    I'd like to use helper tech_XX(device, port)
    which means the port of that device using technology
    ib, iwrap, iboe(roce) ...

>
> The follow on patch can then rework the is_XX and drop the link
> layer/transport stuff..
>
> Some ideas for is_XX:
>   IB compatible SA
>   QP0 SMP mechanism
>   IB SMP format
>   OPA SMP format
>   QP1 GMP mechanism
>   IB compatible CM
>   GID addressing
>   IP/IPv6 addressing
>   Ethernet VLAN
>   ...

Let's discuss and figure out the right name in the thread of
v2 patch set, I guess there will be a lot to be correct :-P

Regards,
Michael Wang

>
> Jason

