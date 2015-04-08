Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:34857 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751572AbbDHI2P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Apr 2015 04:28:15 -0400
Received: by widdi4 with SMTP id di4so45813517wid.0
        for <linux-nfs@vger.kernel.org>; Wed, 08 Apr 2015 01:28:14 -0700 (PDT)
Message-ID: <5524E69A.6050400@profitbricks.com>
Date: Wed, 08 Apr 2015 10:28:10 +0200
From: Michael Wang <yun.wang@profitbricks.com>
MIME-Version: 1.0
To: Steve Wise <swise@opengridcomputing.com>,
        "'Jason Gunthorpe'" <jgunthorpe@obsidianresearch.com>
CC: "'Roland Dreier'" <roland@kernel.org>,
        "'Sean Hefty'" <sean.hefty@intel.com>, linux-rdma@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, "'Hal Rosenstock'" <hal.rosenstock@gmail.com>,
        "'Tom Tucker'" <tom@opengridcomputing.com>,
        "'Hoang-Nam Nguyen'" <hnguyen@de.ibm.com>,
        "'Christoph Raisch'" <raisch@de.ibm.com>,
        "'Mike Marciniszyn'" <infinipath@intel.com>,
        "'Eli Cohen'" <eli@mellanox.com>,
        "'Faisal Latif'" <faisal.latif@intel.com>,
        "'Upinder Malhi'" <umalhi@cisco.com>,
        "'Trond Myklebust'" <trond.myklebust@primarydata.com>,
        "'J. Bruce Fields'" <bfields@fieldses.org>,
        "'David S. Miller'" <davem@davemloft.net>,
        "'Ira Weiny'" <ira.weiny@intel.com>,
        "'PJ Waskiewicz'" <pj.waskiewicz@solidfire.com>,
        "'Tatyana Nikolova'" <Tatyana.E.Nikolova@intel.com>,
        "'Or Gerlitz'" <ogerlitz@mellanox.com>,
        "'Jack Morgenstein'" <jackm@dev.mellanox.co.il>,
        "'Haggai Eran'" <haggaie@mellanox.com>,
        "'Ilya Nelkenbaum'" <ilyan@mellanox.com>,
        "'Yann Droneaud'" <ydroneaud@opteya.com>,
        "'Bart Van Assche'" <bvanassche@acm.org>,
        "'Shachar Raindel'" <raindel@mellanox.com>,
        "'Sagi Grimberg'" <sagig@mellanox.com>,
        "'Devesh Sharma'" <devesh.sharma@emulex.com>,
        "'Matan Barak'" <matanb@mellanox.com>,
        "'Moni Shoua'" <monis@mellanox.com>, "'Jiri Kosina'" <jkosina@suse.cz>,
        "'Selvin Xavier'" <selvin.xavier@emulex.com>,
        "'Mitesh Ahuja'" <mitesh.ahuja@emulex.com>,
        "'Li RongQing'" <roy.qing.li@gmail.com>,
        "'Rasmus Villemoes'" <linux@rasmusvillemoes.dk>,
        "'Alex Estrin'" <alex.estrin@intel.com>,
        "'Doug Ledford'" <dledford@redhat.com>,
        "'Eric Dumazet'" <edumazet@google.com>,
        "'Erez Shitrit'" <erezsh@mellanox.com>,
        "'Tom Gundersen'" <teg@jklm.no>,
        "'Chuck Lever'" <chuck.lever@oracle.com>
Subject: Re: [PATCH v2 10/17] IB/Verbs: Adopt management helpers for IB helpers
References: <5523CCD5.6030401@profitbricks.com> <5523CF0A.5090206@profitbricks.com> <20150407201259.GA17147@obsidianresearch.com> <008401d0716f$bc41c5c0$34c55140$@opengridcomputing.com>
In-Reply-To: <008401d0716f$bc41c5c0$34c55140$@opengridcomputing.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, Steve

Thanks for the comment :-)

On 04/07/2015 10:16 PM, Steve Wise wrote:
[snip]
>>>
>>> -	force_grh = rdma_port_get_link_layer(device, port_num) == IB_LINK_LAYER_ETHERNET;
>>> +	force_grh = !rdma_transport_ib(device, port_num);
>>
>> Maybe these tests should be called cap_mandatory_grh - but I'm not
>> really sure how iWarp uses the GRH fields in the AH...
>>
> 
> iWARP runs on top of TCP...this SA code is all IB-specific.  The reason it was checking for ETHERNET, I think, is for RoCE.    So
> this change is totally incorrect,  I think,  because RoCE is an IB transport, but it runs on ETHERNET.

I guess it's the name 'transport' which confusing folks... actually (!rdma_transport_ib)
including RoCE/IBoE, but yes, here it's for IBoE only, so let's change it to
rdma_transport_iboe ;-)

Regards,
Michael Wang

> 
> Steve.
> 
> 
> 
