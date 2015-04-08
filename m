Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:33605 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751486AbbDHIlc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Apr 2015 04:41:32 -0400
Received: by wiax7 with SMTP id x7so27845999wia.0
        for <linux-nfs@vger.kernel.org>; Wed, 08 Apr 2015 01:41:31 -0700 (PDT)
Message-ID: <5524E9B8.3000709@profitbricks.com>
Date: Wed, 08 Apr 2015 10:41:28 +0200
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
Subject: Re: [PATCH v2 02/17] IB/Verbs: Implement raw management helpers
References: <5523CCD5.6030401@profitbricks.com> <5523CDA7.8090902@profitbricks.com> <1828884A29C6694DAF28B7E6B8A82373A8FBE403@ORSMSX109.amr.corp.intel.com>
In-Reply-To: <1828884A29C6694DAF28B7E6B8A82373A8FBE403@ORSMSX109.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 04/07/2015 11:25 PM, Hefty, Sean wrote:
>> +static inline int rdma_transport_ib(struct ib_device *device, u8
>> port_num)
>> +{
>> +	return device->query_transport(device, port_num)
>> +			== RDMA_TRANSPORT_IB;
>> +}
>> +
>> +static inline int rdma_transport_iboe(struct ib_device *device, u8
>> port_num)
>> +{
>> +	return device->query_transport(device, port_num)
>> +			== RDMA_TRANSPORT_IBOE;
>> +}
> 
> We need to do something with the function names to make their use more obvious.  Both IB and IBoE have transport IB.  I think Jason suggested rdma_tech_ib / rdma_tech_iboe.
> 
> Regarding transport types, I believe that usnic supports 2 different transports.  Although usnic isn't used by anything else in the core layer, we should probably be able to handle a device that supports multiple protocols.  I'm not sure what the 'transport' should be for iWarp, since iWarp is layered over TCP.  But that may just mean that the term transport isn't great.

Agree, it do confusing folks, I will use tech instead in next version :-)

Regards,
Michael Wang

> 
> - Sean
> 
