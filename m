Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:38879 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752213AbbCZQ6Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Mar 2015 12:58:24 -0400
Received: by wibgn9 with SMTP id gn9so94413850wib.1
        for <linux-nfs@vger.kernel.org>; Thu, 26 Mar 2015 09:58:23 -0700 (PDT)
Message-ID: <55143AAC.8040206@profitbricks.com>
Date: Thu, 26 Mar 2015 17:58:20 +0100
From: Michael Wang <yun.wang@profitbricks.com>
MIME-Version: 1.0
To: Doug Ledford <dledford@redhat.com>
CC: linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>,
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
References: <5512CFB0.1050108@profitbricks.com>	 <1427378940.21101.100.camel@redhat.com> <55142DFD.2060100@profitbricks.com> <1427387258.21101.124.camel@redhat.com>
In-Reply-To: <1427387258.21101.124.camel@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/26/2015 05:27 PM, Doug Ledford wrote:
> On Thu, 2015-03-26 at 17:04 +0100, Michael Wang wrote:
>> [snip]
>>
>> Few more questions here is:
>> 1. when to setup? (maybe inside ib_register_device() before doing client->add() callback?)
> I don't think "we" can set it up here.  The driver's have to set it up.
> After all, the mlx4 driver will have to decide for itself what the port
> transport is and tell us, we can't tell it.
>> 2. how to setup? (still infer from the transport and link layer like we currently do?)
> Find each point in each driver where they currently set the link layer
> and transport fields today, and replace that with setting the new
> transport bitmask instead.

Forgive me but I'm not very familiar with the process of such changing...

So shall we do this for all the vendors? or provide a transition method
and asking them to do this later by themselves?

The questions is just wondering how the transition method could be, but
if we have to do the changes for vendor, that sounds like a tough job...

>
>> 3. in case if a device has ports with different link layer type (please correct
>>     me if this will never happen), then only one bitmask may not be enough to
>>     present the transport of all the ports? (maybe create a bitmask per port?)
> [snip]
>
> That preserves the user space ABI and all user programs keep working,
> while we update to an internal representation that makes more sense for
> how things have evolved.

I get your point :-) to reassemble the information in old style, maybe
we can temporarily reserve the old mechanism, and do reform for
the user space in another separate patch set, also cleanup the old
stuff too.

Regards,
Michael Wang

>
>> Regards,
>> Michael Wang
>>
>>> If we do this, then the only thing we have to fix up to preserve ABI
>>> with user space is to make sure that any time we export an ibv_device
>>> struct and any time we import the same, we convert from our new internal
>>> representation to the old representation that user space expects.  And
>>> we also need to make a few changes in the sysfs code to display the
>>> properties as things expect.  But, that would allow us to fix up what I
>>> see as a problem right now, which is that we hide the information we
>>> need to know what sort of device we are working on in two different
>>> fields: the transport and the link layer.  Instead, just use one field
>>> with enough variants that we can store all of the relevant information
>>> we need in that one field.  This has the benefit that any comparisons
>>> that happen in hot paths will now always be a single bitwise comparison
>>> and will no longer need to hit two separate variables for two separate
>>> compares.
>>>
>>>
>>>
>

