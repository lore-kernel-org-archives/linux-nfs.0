Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:35064 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752833AbbDHIYN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Apr 2015 04:24:13 -0400
Received: by widdi4 with SMTP id di4so45698036wid.0
        for <linux-nfs@vger.kernel.org>; Wed, 08 Apr 2015 01:24:12 -0700 (PDT)
Message-ID: <5524E5A9.2090803@profitbricks.com>
Date: Wed, 08 Apr 2015 10:24:09 +0200
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
Subject: Re: [PATCH v2 10/17] IB/Verbs: Adopt management helpers for IB helpers
References: <5523CCD5.6030401@profitbricks.com> <5523CF0A.5090206@profitbricks.com> <1828884A29C6694DAF28B7E6B8A82373A8FBE2A5@ORSMSX109.amr.corp.intel.com>
In-Reply-To: <1828884A29C6694DAF28B7E6B8A82373A8FBE2A5@ORSMSX109.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/07/2015 08:40 PM, Hefty, Sean wrote:
[snip]
>> @@ -200,11 +200,9 @@ int ib_init_ah_from_wc(struct ib_device *device, u8
>> port_num, struct ib_wc *wc,
>>  	u32 flow_class;
>>  	u16 gid_index;
>>  	int ret;
>> -	int is_eth = (rdma_port_get_link_layer(device, port_num) ==
>> -			IB_LINK_LAYER_ETHERNET);
>>
>>  	memset(ah_attr, 0, sizeof *ah_attr);
>> -	if (is_eth) {
>> +	if (!rdma_transport_ib(device, port_num)) {
>>  		if (!(wc->wc_flags & IB_WC_GRH))
>>  			return -EPROTOTYPE;
>>
>> @@ -873,7 +871,7 @@ int ib_resolve_eth_l2_attrs(struct ib_qp *qp,
>>  	union ib_gid  sgid;
>>
>>  	if ((*qp_attr_mask & IB_QP_AV)  &&
>> -	    (rdma_port_get_link_layer(qp->device, qp_attr->ah_attr.port_num)
>> == IB_LINK_LAYER_ETHERNET)) {
>> +	    (!rdma_transport_ib(qp->device, qp_attr->ah_attr.port_num))) {
>>  		ret = ib_query_gid(qp->device, qp_attr->ah_attr.port_num,
>>  				   qp_attr->ah_attr.grh.sgid_index, &sgid);
>>  		if (ret)
> 
> The above checks would be better as:
> 
> 	force_grh = rdma_transport_iboe(...)
> 
> They are RoCE/IBoE specific checks.

Got it, will be in next version :-)

Regards,
Michael Wang

> 
