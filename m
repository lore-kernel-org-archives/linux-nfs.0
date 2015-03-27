Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:34092 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751325AbbC0QPq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 12:15:46 -0400
Received: by wibg7 with SMTP id g7so42899714wib.1
        for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 09:15:45 -0700 (PDT)
Message-ID: <5515822E.2020207@profitbricks.com>
Date: Fri, 27 Mar 2015 17:15:42 +0100
From: Michael Wang <yun.wang@profitbricks.com>
MIME-Version: 1.0
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
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
        Doug Ledford <dledford@redhat.com>, Eric Dumazet <edumazet@google.com>,
        Erez Shitrit <erezsh@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>,
        Haggai Eran <haggaie@mellanox.com>,
        Shachar Raindel <raindel@mellanox.com>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>,
        Steve Wise <swise@opengridcomputing.com>, Tom Tucker <tom@ogc.us>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC PATCH 09/11] IB/Verbs: Use management helper has_ipoib()
 and, cap_ipoib() for ipoib-check
References: <551579CA.4030901@profitbricks.com> <55157BC6.70400@profitbricks.com> <20150327160616.GA28412@obsidianresearch.com>
In-Reply-To: <20150327160616.GA28412@obsidianresearch.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/27/2015 05:06 PM, Jason Gunthorpe wrote:
> On Fri, Mar 27, 2015 at 04:48:22PM +0100, Michael Wang wrote:
>
>> diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
>> index 3341754..fcd7558 100644
>> +++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
>> @@ -1655,7 +1655,7 @@ static void ipoib_add_one(struct ib_device *device)
>>      struct ipoib_dev_priv *priv;
>>      int s, e, p;
>>  
>> -    if (!rdma_transport_is_ib(device))
>> +    if (!has_ipoib(device))
>>          return;
> This is a good example of a test that doesn't really make sense, IPoIB
> is certainly a port specific attribute.
According to my understanding, seems like the logical is:

    if 'device have no port need ipoib initialization'
            return
>
>>      dev_list = kmalloc(sizeof *dev_list, GFP_KERNEL);
>> @@ -1673,7 +1673,7 @@ static void ipoib_add_one(struct ib_device *device)
>>      }
>>  
>>      for (p = s; p <= e; ++p) {
>> -        if (!rdma_port_ll_is_ib(device, p))
>> +        if (!cap_ipoib(device, p))
>>              continue;
> And down here we test every port.
>
> The routine should just test every port and do nothing if no ports
> need IPoIB.
And here since there are some initial work to do, it iterate all the
port to find out which one need to be initialized.

>
>>          dev = ipoib_add_port("ib%d", device, p);
>>          if (!IS_ERR(dev)) {
>> @@ -1690,7 +1690,7 @@ static void ipoib_remove_one(struct ib_device *device)
>>      struct ipoib_dev_priv *priv, *tmp;
>>      struct list_head *dev_list;
>>  
>> -    if (!rdma_transport_is_ib(device))
>> +    if (!has_ipoib(device))
>>          return;
> This test should be made redundant by having ib_get_client_data return
> null if ipoib_add_one didn't do anything. Maybe that already happens?
Here if we have done nothing when add a device, then nothing
need to be cleanup when remove it.

I'm not sure if it's a good idea, but seems like the idea is use twice
check on different level to save some cycles?

Regards,
Michael Wang
>
> Jason

