Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:38509 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752758AbbC3QXU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2015 12:23:20 -0400
Received: by wibgn9 with SMTP id gn9so137451599wib.1
        for <linux-nfs@vger.kernel.org>; Mon, 30 Mar 2015 09:23:19 -0700 (PDT)
Message-ID: <55197874.3080807@profitbricks.com>
Date: Mon, 30 Mar 2015 18:23:16 +0200
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
Subject: Re: [RFC PATCH 02/11] IB/Verbs: Use management helper tech_iboe()
 for iboe-check
References: <551579CA.4030901@profitbricks.com>	 <55157A4F.1090301@profitbricks.com> <1427732250.21101.202.camel@redhat.com>
In-Reply-To: <1427732250.21101.202.camel@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/30/2015 06:17 PM, Doug Ledford wrote:
> On Fri, 2015-03-27 at 16:42 +0100, Michael Wang wrote:
>> Introduce helper tech_iboe() to help us check if the port of an IB
>> device is using RoCE/IBoE technology.
> Just use rdma_transport_is_roce() instead.
Sounds good :-) will be in next version.

Regards,
Michael Wang

>
>> Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
>> Cc: Doug Ledford <dledford@redhat.com>
>> Cc: Ira Weiny <ira.weiny@intel.com>
>> Cc: Sean Hefty <sean.hefty@intel.com>
>> Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
>> ---
>>  drivers/infiniband/core/cma.c |  6 ++----
>>  include/rdma/ib_verbs.h       | 16 ++++++++++++++++
>>  2 files changed, 18 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
>> index 668e955..280cfe3 100644
>> --- a/drivers/infiniband/core/cma.c
>> +++ b/drivers/infiniband/core/cma.c
>> @@ -375,8 +375,7 @@ static int cma_acquire_dev(struct rdma_id_private *id_priv,
>>                       listen_id_priv->id.port_num) == dev_ll) {
>>          cma_dev = listen_id_priv->cma_dev;
>>          port = listen_id_priv->id.port_num;
>> -        if (rdma_transport_is_ib(cma_dev->device) &&
>> -            rdma_port_ll_is_eth(cma_dev->device, port))
>> +        if (tech_iboe(cma_dev->device, port))
>>              ret = ib_find_cached_gid(cma_dev->device, &iboe_gid,
>>                           &found_port, NULL);
>>          else
>> @@ -395,8 +394,7 @@ static int cma_acquire_dev(struct rdma_id_private *id_priv,
>>                  listen_id_priv->id.port_num == port)
>>                  continue;
>>              if (rdma_port_get_link_layer(cma_dev->device, port) == dev_ll) {
>> -                if (rdma_transport_is_ib(cma_dev->device) &&
>> -                    rdma_port_ll_is_eth(cma_dev->device, port))
>> +                if (tech_iboe(cma_dev->device, port))
>>                      ret = ib_find_cached_gid(cma_dev->device, &iboe_gid, &found_port, NULL);
>>                  else
>>                      ret = ib_find_cached_gid(cma_dev->device, &gid, &found_port, NULL);
>> diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
>> index 2bf9094..ca6d6bc 100644
>> --- a/include/rdma/ib_verbs.h
>> +++ b/include/rdma/ib_verbs.h
>> @@ -1767,6 +1767,22 @@ static inline int rdma_port_ll_is_eth(struct ib_device *device, u8 port_num)
>>              == IB_LINK_LAYER_ETHERNET;
>>  }
>>  
>> +/**
>> + * tech_iboe - Check if the port of device using technology
>> + * RoCE/IBoE.
>> + *
>> + * @device: Device to be checked
>> + * @port_num: Port number of the device
>> + *
>> + * Return 0 when port of the device is not using technology
>> + * RoCE/IBoE.
>> + */
>> +static inline int tech_iboe(struct ib_device *device, u8 port_num)
>> +{
>> +    return rdma_transport_is_ib(device) &&
>> +            rdma_port_ll_is_eth(device, port_num);
>> +}
>> +
>>  int ib_query_gid(struct ib_device *device,
>>           u8 port_num, int index, union ib_gid *gid);
>>  
>

