Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:34219 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751420AbbDHINw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Apr 2015 04:13:52 -0400
Received: by widjs5 with SMTP id js5so27300453wid.1
        for <linux-nfs@vger.kernel.org>; Wed, 08 Apr 2015 01:13:50 -0700 (PDT)
Message-ID: <5524E33B.5050403@profitbricks.com>
Date: Wed, 08 Apr 2015 10:13:47 +0200
From: Michael Wang <yun.wang@profitbricks.com>
MIME-Version: 1.0
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
CC: Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        Tom Tucker <tom@opengridcomputing.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Hoang-Nam Nguyen <hnguyen@de.ibm.com>,
        Christoph Raisch <raisch@de.ibm.com>,
        Mike Marciniszyn <infinipath@intel.com>, Eli Cohen <eli@mellanox.com>,
        Faisal Latif <faisal.latif@intel.com>,
        Upinder Malhi <umalhi@cisco.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        Ira Weiny <ira.weiny@intel.com>,
        PJ Waskiewicz <pj.waskiewicz@solidfire.com>,
        Tatyana Nikolova <Tatyana.E.Nikolova@intel.com>,
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
        Alex Estrin <alex.estrin@intel.com>,
        Doug Ledford <dledford@redhat.com>, Eric Dumazet <edumazet@google.com>,
        Erez Shitrit <erezsh@mellanox.com>, Tom Gundersen <teg@jklm.no>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v2 03/17] IB/Verbs: Use management helper cap_ib_mad()
 for mad-check
References: <5523CCD5.6030401@profitbricks.com> <5523CDDE.4050209@profitbricks.com> <20150407172612.GA15704@obsidianresearch.com>
In-Reply-To: <20150407172612.GA15704@obsidianresearch.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/07/2015 07:26 PM, Jason Gunthorpe wrote:
> On Tue, Apr 07, 2015 at 02:30:22PM +0200, Michael Wang wrote:
> 
>> -	if (rdma_node_get_transport(device->node_type) != RDMA_TRANSPORT_IB)
>> -		return;
>> -
>>  	if (device->node_type == RDMA_NODE_IB_SWITCH) {
>>  		start = 0;
>>  		end   = 0;
>> @@ -3069,6 +3066,9 @@ static void ib_mad_init_device(struct ib_device *device)
>>  	}
>>  
>>  	for (i = start; i <= end; i++) {
>> +		if (!cap_ib_mad(device, i))
>> +			continue;
>> +
> 
> I would prefer to see these changes in control flow as dedicated
> patches, at the top of your patch stack.
> 
> For this kind of work a patch should be mechanical changes only, it is
> easier to review that way.
> 
> Same comment applies throughout.

Make sense :-) I will re-organize the sequence and put them at last.

Regards,
Michael Wang

> 
> Jason
> 
