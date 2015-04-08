Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:34924 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753455AbbDHIaB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Apr 2015 04:30:01 -0400
Received: by widdi4 with SMTP id di4so45863916wid.0
        for <linux-nfs@vger.kernel.org>; Wed, 08 Apr 2015 01:30:00 -0700 (PDT)
Message-ID: <5524E705.6040106@profitbricks.com>
Date: Wed, 08 Apr 2015 10:29:57 +0200
From: Michael Wang <yun.wang@profitbricks.com>
MIME-Version: 1.0
To: "Hefty, Sean" <sean.hefty@intel.com>, Roland Dreier <roland@kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
CC: Hal Rosenstock <hal.rosenstock@gmail.com>,
        Tom Tucker <tom@opengridcomputing.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Hoang-Nam Nguyen <hnguyen@de.ibm.com>,
        Christoph Raisch <raisch@de.ibm.com>,
        infinipath <infinipath@intel.com>, Eli Cohen <eli@mellanox.com>,
        "Latif, Faisal" <faisal.latif@intel.com>,
        Upinder Malhi <umalhi@cisco.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        "Weiny, Ira" <ira.weiny@intel.com>,
        PJ Waskiewicz <pj.waskiewicz@solidfire.com>,
        "Nikolova, Tatyana E" <tatyana.e.nikolova@intel.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Haggai Eran <haggaie@mellanox.com>,
        Ilya Nelkenbaum <ilyan@mellanox.com>,
        Yann Droneaud <ydroneaud@opteya.com>,
        Bart Van Assche <bvanassche@acm.org>,
        Shachar Raindel <raindel@mellanox.com>,
        Sagi Grimberg <sagig@mellanox.com>,
        Devesh Sharma <devesh.sharma@emulex.com>,
        Matan Barak <matanb@mellanox.com>, Moni Shoua <monis@mellanox.com>,
        Jiri Kosina <jkosina@suse.cz>,
        Selvin Xavier <selvin.xavier@emulex.com>,
        Mitesh Ahuja <mitesh.ahuja@emulex.com>,
        Li RongQing <roy.qing.li@gmail.com>,
        Rasmus Villemoes <linux@rasmusvillemoes.dk>,
        "Estrin, Alex" <alex.estrin@intel.com>,
        Doug Ledford <dledford@redhat.com>, Eric Dumazet <edumazet@google.com>,
        Erez Shitrit <erezsh@mellanox.com>, Tom Gundersen <teg@jklm.no>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v2 11/17] IB/Verbs: Reform link_layer_show() and ib_uverbs_query_port()
References: <5523CCD5.6030401@profitbricks.com> <5523CF30.7000608@profitbricks.com> <1828884A29C6694DAF28B7E6B8A82373A8FBE2FA@ORSMSX109.amr.corp.intel.com>
In-Reply-To: <1828884A29C6694DAF28B7E6B8A82373A8FBE2FA@ORSMSX109.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/07/2015 08:49 PM, Hefty, Sean wrote:
[snip]
>> @@ -515,8 +515,10 @@ ssize_t ib_uverbs_query_port(struct ib_uverbs_file
>> *file,
>>  	resp.active_width    = attr.active_width;
>>  	resp.active_speed    = attr.active_speed;
>>  	resp.phys_state      = attr.phys_state;
>> -	resp.link_layer      = rdma_port_get_link_layer(file->device-
>>> ib_dev,
>> -							cmd.port_num);
>> +	resp.link_layer      = rdma_transport_ib(file->device->ib_dev,
>> +							cmd.port_num) ?
>> +			       IB_LINK_LAYER_INFINIBAND :
>> +			       IB_LINK_LAYER_ETHERNET;
>>
>>  	if (copy_to_user((void __user *) (unsigned long) cmd.response,
>>  			 &resp, sizeof resp))
> 
> Both of the above check the transport in order to determine the link layer.
> 
> These values are exposed to user space.  Does anyone know what link layer iWarp returns to user space? 

It should be ETH for IWARP according to the old logical :-)

Regards,
Michael Wang

> 
