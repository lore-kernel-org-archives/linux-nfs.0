Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:34504 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752776AbbC0RN2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 13:13:28 -0400
Received: by oigz129 with SMTP id z129so36629441oig.1
        for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 10:13:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150327164756.GA27862@phlsvsds.ph.intel.com>
References: <551579CA.4030901@profitbricks.com>
	<55157B43.6060507@profitbricks.com>
	<20150327164756.GA27862@phlsvsds.ph.intel.com>
Date: Fri, 27 Mar 2015 18:13:27 +0100
Message-ID: <CAJuTgQWgWrNuNaCdNg0g_eHsaOPNUgM4qD=F56HZWeDeN0KWOQ@mail.gmail.com>
Subject: Re: [RFC PATCH 06/11] IB/Verbs: Use management helper has_sa() and
 cap_sa(), for sa-check
From: Yun Wang <yun.wang@profitbricks.com>
To: "ira.weiny" <ira.weiny@intel.com>
Cc: Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org,
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
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 27, 2015 at 5:47 PM, ira.weiny <ira.weiny@intel.com> wrote:
> On Fri, Mar 27, 2015 at 04:46:11PM +0100, Michael Wang wrote:
>>
>> Introduce helper has_sa() and cap_sa() to help us check if an IB device
>> or it's port support Subnet Administrator.
>
> I think these 2 should be combined.  The question is if a port requires the use
> of the SA depending on the network it is connected to.
>
> Aren't some dual port Mellanox cards capable of doing IB on 1 port and Eth on
> the other?  Do they show up as 2 devices?

I'm not sure about this... but sounds like your opinion is same to
Jason on ipoib stuff, I'll do more investigation on that part, if it's
just for optimization, then we should be able to eliminate has_xx()
stuff :-) after all, init/exit is not a hot path.

>
> Regardless I think we should define the SA access on a per port basis.
>
>>
>> Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
>> Cc: Doug Ledford <dledford@redhat.com>
>> Cc: Ira Weiny <ira.weiny@intel.com>
>> Cc: Sean Hefty <sean.hefty@intel.com>
>> Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
>> ---
>>  drivers/infiniband/core/sa_query.c | 12 ++++++------
>>  include/rdma/ib_verbs.h            | 28 ++++++++++++++++++++++++++++
>>  2 files changed, 34 insertions(+), 6 deletions(-)
>>
>> diff --git a/drivers/infiniband/core/sa_query.c b/drivers/infiniband/core/sa_query.c
>> index d95d25f..89c27da 100644
>> --- a/drivers/infiniband/core/sa_query.c
>> +++ b/drivers/infiniband/core/sa_query.c
>> @@ -450,7 +450,7 @@ static void ib_sa_event(struct ib_event_handler *handler, struct ib_event *event
>>          struct ib_sa_port *port =
>>              &sa_dev->port[event->element.port_num - sa_dev->start_port];
>>
>> -        if (!rdma_port_ll_is_ib(handler->device, port->port_num))
>> +        if (!cap_sa(handler->device, port->port_num))
>>              return;
>>
>>          spin_lock_irqsave(&port->ah_lock, flags);
>> @@ -1154,7 +1154,7 @@ static void ib_sa_add_one(struct ib_device *device)
>>      struct ib_sa_device *sa_dev;
>>      int s, e, i;
>>
>> -    if (!rdma_transport_is_ib(device))
>> +    if (!has_sa(device))
>
> The logic here should be:
>
> if (no ports of this device need sa access)
>         return;
>
> So why not eliminate this check and allow the cap_sa(s) to handle the support?

I'll check if we could merge this part to the following iteration :-)

Regards,
Michael Wang

>
> -- Ira
>
>>          return;
>>
>>      if (device->node_type == RDMA_NODE_IB_SWITCH)
>> @@ -1175,7 +1175,7 @@ static void ib_sa_add_one(struct ib_device *device)
>>
>>      for (i = 0; i <= e - s; ++i) {
>>          spin_lock_init(&sa_dev->port[i].ah_lock);
>> -        if (!rdma_port_ll_is_ib(device, i + 1))
>> +        if (!cap_sa(device, i + 1))
>>              continue;
>>
>>          sa_dev->port[i].sm_ah    = NULL;
>> @@ -1205,14 +1205,14 @@ static void ib_sa_add_one(struct ib_device *device)
>>          goto err;
>>
>>      for (i = 0; i <= e - s; ++i)
>> -        if (rdma_port_ll_is_ib(device, i + 1))
>> +        if (cap_sa(device, i + 1))
>>              update_sm_ah(&sa_dev->port[i].update_task);
>>
>>      return;
>>
>>  err:
>>      while (--i >= 0)
>> -        if (rdma_port_ll_is_ib(device, i + 1))
>> +        if (cap_sa(device, i + 1))
>>              ib_unregister_mad_agent(sa_dev->port[i].agent);
>>
>>      kfree(sa_dev);
>> @@ -1233,7 +1233,7 @@ static void ib_sa_remove_one(struct ib_device *device)
>>      flush_workqueue(ib_wq);
>>
>>      for (i = 0; i <= sa_dev->end_port - sa_dev->start_port; ++i) {
>> -        if (rdma_port_ll_is_ib(device, i + 1)) {
>> +        if (cap_sa(device, i + 1)) {
>>              ib_unregister_mad_agent(sa_dev->port[i].agent);
>>              if (sa_dev->port[i].sm_ah)
>>                  kref_put(&sa_dev->port[i].sm_ah->ref, free_sm_ah);
>> diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
>> index c0a63f8..fa8ffa3 100644
>> --- a/include/rdma/ib_verbs.h
>> +++ b/include/rdma/ib_verbs.h
>> @@ -1810,6 +1810,19 @@ static inline int has_cm(struct ib_device *device)
>>  }
>>
>>  /**
>> + * has_sa - Check if a device support Subnet Administrator.
>> + *
>> + * @device: Device to be checked
>> + *
>> + * Return 0 when a device has none port to support
>> + * Subnet Administrator.
>> + */
>> +static inline int has_sa(struct ib_device *device)
>> +{
>> +    return rdma_transport_is_ib(device);
>> +}
>> +
>> +/**
>>   * cap_smi - Check if the port of device has the capability
>>   * Subnet Management Interface.
>>   *
>> @@ -1824,6 +1837,21 @@ static inline int cap_smi(struct ib_device *device, u8 port_num)
>>      return rdma_port_ll_is_ib(device, port_num);
>>  }
>>
>> +/**
>> + * cap_sa - Check if the port of device has the capability
>> + * Subnet Administrator.
>> + *
>> + * @device: Device to be checked
>> + * @port_num: Port number of the device
>> + *
>> + * Return 0 when port of the device don't support
>> + * Subnet Administrator.
>> + */
>> +static inline int cap_sa(struct ib_device *device, u8 port_num)
>> +{
>> +    return rdma_port_ll_is_ib(device, port_num);
>> +}
>> +
>>  int ib_query_gid(struct ib_device *device,
>>           u8 port_num, int index, union ib_gid *gid);
>>
>> --
>> 2.1.0
>>
