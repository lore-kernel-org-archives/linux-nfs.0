Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:36499 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751767AbbDIIF3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Apr 2015 04:05:29 -0400
Received: by wizk4 with SMTP id k4so82610670wiz.1
        for <linux-nfs@vger.kernel.org>; Thu, 09 Apr 2015 01:05:27 -0700 (PDT)
Message-ID: <552632C4.3070202@profitbricks.com>
Date: Thu, 09 Apr 2015 10:05:24 +0200
From: Michael Wang <yun.wang@profitbricks.com>
MIME-Version: 1.0
To: "Hefty, Sean" <sean.hefty@intel.com>, Roland Dreier <roland@kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: Hal Rosenstock <hal.rosenstock@gmail.com>,
        Tom Tucker <tom@opengridcomputing.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Hoang-Nam Nguyen <hnguyen@de.ibm.com>,
        Christoph Raisch <raisch@de.ibm.com>,
        infinipath <infinipath@intel.com>, Eli Cohen <eli@mellanox.com>,
        "Latif, Faisal" <faisal.latif@intel.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
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
Subject: Re: [PATCH v2 13/17] IB/Verbs: Reform cma/ucma with management helpers
References: <5523CCD5.6030401@profitbricks.com> <5523CF74.8020004@profitbricks.com> <1828884A29C6694DAF28B7E6B8A82373A8FBE42B@ORSMSX109.amr.corp.intel.com> <5524F6BD.30105@profitbricks.com> <1828884A29C6694DAF28B7E6B8A82373A8FBF037@ORSMSX109.amr.corp.intel.com>
In-Reply-To: <1828884A29C6694DAF28B7E6B8A82373A8FBF037@ORSMSX109.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/08/2015 07:02 PM, Hefty, Sean wrote:
[snip]
>>
>> The wrapper make sense, but do we have the guarantee that IBoE port won't
>> be used for AF_IB address? I just can't locate the place we filtered it
>> out...
> 
> I can't think of a reason why IBoE wouldn't work with AF_IB, but I'm not sure if anyone has tested it.  The original check would have let IBoE through.  When I suggested checking for IB transport, I meant the actual transport protocol, which would have included both IB and IBoE.

Got it :-)

> 
>>>> @@ -700,8 +700,7 @@ static int cma_ib_init_qp_attr(struct
[snip]
> 
>>>>  	id_priv->id.route.addr.dev_addr.dev_type =
>>>> -		(rdma_port_get_link_layer(cma_dev->device, p) ==
>>>> IB_LINK_LAYER_INFINIBAND) ?
>>>> +		(rdma_transport_ib(cma_dev->device, p)) ?
>>>>  		ARPHRD_INFINIBAND : ARPHRD_ETHER;
>>>
>>> This wants the link layer, or maybe use cap_ipoib.
>>
>> Is this related with ipoib only?
> 
> ARPHDR_INFINIBAND is related to ipoib.  In your next update, maybe go with tech_ib.  I don't know the status of ipoib over iboe.

Will be in next version :-)

Regards,
Michael Wang

> 
