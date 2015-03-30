Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:33735 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753256AbbC3QmR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2015 12:42:17 -0400
Received: by wgbgs4 with SMTP id gs4so90723114wgb.0
        for <linux-nfs@vger.kernel.org>; Mon, 30 Mar 2015 09:42:16 -0700 (PDT)
Message-ID: <55197CDB.3040105@profitbricks.com>
Date: Mon, 30 Mar 2015 18:42:03 +0200
From: Michael Wang <yun.wang@profitbricks.com>
MIME-Version: 1.0
To: Doug Ledford <dledford@redhat.com>
CC: Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        Ira Weiny <ira.weiny@intel.com>, linux-rdma@vger.kernel.org,
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
        Eric Dumazet <edumazet@google.com>, Erez Shitrit <erezsh@mellanox.com>,
        Sagi Grimberg <sagig@mellanox.com>, Haggai Eran <haggaie@mellanox.com>,
        Shachar Raindel <raindel@mellanox.com>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>,
        Steve Wise <swise@opengridcomputing.com>, Tom Tucker <tom@ogc.us>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC PATCH 06/11] IB/Verbs: Use management helper has_sa() and
 cap_sa(), for sa-check
References: <551579CA.4030901@profitbricks.com>	 <55157B43.6060507@profitbricks.com> <1427732191.21101.201.camel@redhat.com>
In-Reply-To: <1427732191.21101.201.camel@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/30/2015 06:16 PM, Doug Ledford wrote:
> On Fri, 2015-03-27 at 16:46 +0100, Michael Wang wrote:
>> Introduce helper has_sa() and cap_sa() to help us check if an IB device
>> or it's port support Subnet Administrator.
> There's no functional reason to have both rdma_transport_is_ib and
> rdma_port_ll_is_ib, just use one.  Then there is also no reason for both
> has_sa and cap_sa.  Just use one.
The has_sa() will be eliminated :-)

rdma_transport_is_ib and rdma_port_ll_is_ib is actually just rough helper
to save some code, we can get rid of them when we no longer need them, but
currently device driver still using them a lot, I'm not sure if the new
mechanism could take cover all these cases...

Regards,
Michael Wang 


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
>

