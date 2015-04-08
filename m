Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:35435 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752438AbbDHJhG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Apr 2015 05:37:06 -0400
Received: by widdi4 with SMTP id di4so47846302wid.0
        for <linux-nfs@vger.kernel.org>; Wed, 08 Apr 2015 02:37:05 -0700 (PDT)
Message-ID: <5524F6BD.30105@profitbricks.com>
Date: Wed, 08 Apr 2015 11:37:01 +0200
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
Subject: Re: [PATCH v2 13/17] IB/Verbs: Reform cma/ucma with management helpers
References: <5523CCD5.6030401@profitbricks.com> <5523CF74.8020004@profitbricks.com> <1828884A29C6694DAF28B7E6B8A82373A8FBE42B@ORSMSX109.amr.corp.intel.com>
In-Reply-To: <1828884A29C6694DAF28B7E6B8A82373A8FBE42B@ORSMSX109.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, Sean

Thanks for the review :-) cma is the most tough part during
reform, I really need some guide in here.


On 04/07/2015 11:36 PM, Hefty, Sean wrote:
>> diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
>> index d8a8ea7..c23f483 100644
>> --- a/drivers/infiniband/core/cma.c
>> +++ b/drivers/infiniband/core/cma.c
>> @@ -435,10 +435,10 @@ static int cma_resolve_ib_dev(struct rdma_id_private
>> *id_priv)
>>  	pkey = ntohs(addr->sib_pkey);
>>
>>  	list_for_each_entry(cur_dev, &dev_list, list) {
>> -		if (rdma_node_get_transport(cur_dev->device->node_type) !=
>> RDMA_TRANSPORT_IB)
>> -			continue;
>> -
>>  		for (p = 1; p <= cur_dev->device->phys_port_cnt; ++p) {
>> +			if (!rdma_ib_mgmt(cur_dev->device, p))
>> +				continue;
> 
> This check wants to be something like is_af_ib_supported().  Checking for IB transport may actually be better than checking for IB management.  I don't know if IBoE/RoCE devices support AF_IB.

The wrapper make sense, but do we have the guarantee that IBoE port won't
be used for AF_IB address? I just can't locate the place we filtered it out...

> 
[snip]
>> -	    == IB_LINK_LAYER_ETHERNET) {
>> +	/* Will this happen? */
>> +	BUG_ON(id_priv->cma_dev->device != id_priv->id.device);
> 
> This shouldn't happen.  The BUG_ON looks okay.

Got it :-)

> 
> 
>> +	if (rdma_transport_iboe(id_priv->id.device, id_priv->id.port_num)) {
>>  		ret = rdma_addr_find_smac_by_sgid(&sgid, qp_attr.smac, NULL);
>>
>>  		if (ret)
>> @@ -700,8 +700,7 @@ static int cma_ib_init_qp_attr(struct rdma_id_private
>> *id_priv,
>>  	int ret;
>>  	u16 pkey;
>>
>> -	if (rdma_port_get_link_layer(id_priv->id.device, id_priv-
>>> id.port_num) ==
>> -	    IB_LINK_LAYER_INFINIBAND)
>> +	if (rdma_transport_ib(id_priv->id.device, id_priv->id.port_num))
>>  		pkey = ib_addr_get_pkey(dev_addr);
>>  	else
>>  		pkey = 0xffff;
> 
> Check here should be against the link layer, not transport.

I guess the name confusing us again... what if use rdma_tech_ib() here?
it's the only tech using IB link layers, others are all ETH.

> 
> 
>> @@ -735,8 +734,7 @@ int rdma_init_qp_attr(struct rdma_cm_id *id, struct
[snip]
>>
>>  static void cma_cancel_route(struct rdma_id_private *id_priv)
>>  {
>> -	switch (rdma_port_get_link_layer(id_priv->id.device, id_priv-
>>> id.port_num)) {
>> -	case IB_LINK_LAYER_INFINIBAND:
>> +	if (rdma_transport_ib(id_priv->id.device, id_priv->id.port_num)) {
> 
> The check should be cap_ib_sa()

Got it, will be in next version :-)

All the mcast/sa suggestion below will be applied too.

>
[snip]
>>
>>  	id_priv->id.route.addr.dev_addr.dev_type =
>> -		(rdma_port_get_link_layer(cma_dev->device, p) ==
>> IB_LINK_LAYER_INFINIBAND) ?
>> +		(rdma_transport_ib(cma_dev->device, p)) ?
>>  		ARPHRD_INFINIBAND : ARPHRD_ETHER;
> 
> This wants the link layer, or maybe use cap_ipoib.

Is this related with ipoib only?

> 
> 
>>
>>  	rdma_addr_set_sgid(&id_priv->id.route.addr.dev_addr, &gid);
>> @@ -2536,18 +2508,15 @@ int rdma_listen(struct rdma_cm_id *id, int
>> backlog)
>>
>>  	id_priv->backlog = backlog;
>>  	if (id->device) {
>> -		switch (rdma_node_get_transport(id->device->node_type)) {
>> -		case RDMA_TRANSPORT_IB:
>> +		if (rdma_ib_mgmt(id->device, id->port_num)) {
> 
> Want cap_ib_cm()

Will be in next version :-) and the other cap_ib_cm() suggestion too.

> 
> 
>>  			ret = cma_ib_listen(id_priv);
[snip]
>> @@ -3016,14 +2979,10 @@ int rdma_accept(struct rdma_cm_id *id, struct
>> rdma_conn_param *conn_param)
>>  			else
>>  				ret = cma_rep_recv(id_priv);
>>  		}
>> -		break;
>> -	case RDMA_TRANSPORT_IWARP:
>> +	} else if (rdma_transport_iwarp(id->device, id->port_num))
>>  		ret = cma_accept_iw(id_priv, conn_param);
> 
> If cap_ib_cm() is used in the places marked above, maybe add a cap_iw_cm() for the else conditions.

Sounds good, will be in next version :-)

Regards,
Michael Wang

> 
> 
>> -		break;
>> -	default:
>> +	else
>>  		ret = -ENOSYS;
>> -		break;
>> -	}
>>
>>  	if (ret)
>>  		goto reject;
>> @@ -3067,8 +3026,7 @@ int rdma_reject(struct rdma_cm_id *id, const void
>> *private_data,
>>  	if (!id_priv->cm_id.ib)
>>  		return -EINVAL;
>>
>> -	switch (rdma_node_get_transport(id->device->node_type)) {
>> -	case RDMA_TRANSPORT_IB:
>> +	if (rdma_ib_mgmt(id->device, id->port_num)) {
> 
> cap_ib_cm()
> 
> 
>>  		if (id->qp_type == IB_QPT_UD)
>>  			ret = cma_send_sidr_rep(id_priv, IB_SIDR_REJECT, 0,
>>  						private_data, private_data_len);
>> @@ -3076,15 +3034,11 @@ int rdma_reject(struct rdma_cm_id *id, const void
>> *private_data,
>>  			ret = ib_send_cm_rej(id_priv->cm_id.ib,
>>  					     IB_CM_REJ_CONSUMER_DEFINED, NULL,
>>  					     0, private_data, private_data_len);
>> -		break;
>> -	case RDMA_TRANSPORT_IWARP:
>> +	} else if (rdma_transport_iwarp(id->device, id->port_num)) {
>>  		ret = iw_cm_reject(id_priv->cm_id.iw,
>>  				   private_data, private_data_len);
>> -		break;
>> -	default:
>> +	} else
>>  		ret = -ENOSYS;
>> -		break;
>> -	}
>>  	return ret;
>>  }
>>  EXPORT_SYMBOL(rdma_reject);
>> @@ -3098,22 +3052,17 @@ int rdma_disconnect(struct rdma_cm_id *id)
>>  	if (!id_priv->cm_id.ib)
>>  		return -EINVAL;
>>
>> -	switch (rdma_node_get_transport(id->device->node_type)) {
>> -	case RDMA_TRANSPORT_IB:
>> +	if (rdma_ib_mgmt(id->device, id->port_num)) {
>>  		ret = cma_modify_qp_err(id_priv);
>>  		if (ret)
>>  			goto out;
>>  		/* Initiate or respond to a disconnect. */
>>  		if (ib_send_cm_dreq(id_priv->cm_id.ib, NULL, 0))
>>  			ib_send_cm_drep(id_priv->cm_id.ib, NULL, 0);
> 
> cap_ib_cm()
> 
> 
>> -		break;
>> -	case RDMA_TRANSPORT_IWARP:
>> +	} else if (rdma_transport_iwarp(id->device, id->port_num)) {
>>  		ret = iw_cm_disconnect(id_priv->cm_id.iw, 0);
>> -		break;
>> -	default:
>> +	} else
>>  		ret = -EINVAL;
>> -		break;
>> -	}
>>  out:
>>  	return ret;
>>  }
>> @@ -3359,24 +3308,13 @@ int rdma_join_multicast(struct rdma_cm_id *id,
>> struct sockaddr *addr,
>>  	list_add(&mc->list, &id_priv->mc_list);
>>  	spin_unlock(&id_priv->lock);
>>
>> -	switch (rdma_node_get_transport(id->device->node_type)) {
>> -	case RDMA_TRANSPORT_IB:
>> -		switch (rdma_port_get_link_layer(id->device, id->port_num)) {
>> -		case IB_LINK_LAYER_INFINIBAND:
>> -			ret = cma_join_ib_multicast(id_priv, mc);
>> -			break;
>> -		case IB_LINK_LAYER_ETHERNET:
>> -			kref_init(&mc->mcref);
>> -			ret = cma_iboe_join_multicast(id_priv, mc);
>> -			break;
>> -		default:
>> -			ret = -EINVAL;
>> -		}
>> -		break;
>> -	default:
>> +	if (rdma_transport_iboe(id->device, id->port_num)) {
>> +		kref_init(&mc->mcref);
>> +		ret = cma_iboe_join_multicast(id_priv, mc);
>> +	} else if (rdma_transport_ib(id->device, id->port_num))
>> +		ret = cma_join_ib_multicast(id_priv, mc);
> 
> cap_ib_mcast()
> 
> 
>> +	else
>>  		ret = -ENOSYS;
>> -		break;
>> -	}
>>
>>  	if (ret) {
>>  		spin_lock_irq(&id_priv->lock);
>> @@ -3404,19 +3342,17 @@ void rdma_leave_multicast(struct rdma_cm_id *id,
>> struct sockaddr *addr)
>>  				ib_detach_mcast(id->qp,
>>  						&mc->multicast.ib->rec.mgid,
>>  						be16_to_cpu(mc->multicast.ib-
>>> rec.mlid));
>> -			if (rdma_node_get_transport(id_priv->cma_dev->device-
>>> node_type) == RDMA_TRANSPORT_IB) {
>> -				switch (rdma_port_get_link_layer(id->device, id-
>>> port_num)) {
>> -				case IB_LINK_LAYER_INFINIBAND:
>> -					ib_sa_free_multicast(mc->multicast.ib);
>> -					kfree(mc);
>> -					break;
>> -				case IB_LINK_LAYER_ETHERNET:
>> -					kref_put(&mc->mcref, release_mc);
>> -					break;
>> -				default:
>> -					break;
>> -				}
>> -			}
>> +
>> +			/* Will this happen? */
>> +			BUG_ON(id_priv->cma_dev->device != id->device);
> 
> Should not happen
> 
>> +
>> +			if (rdma_transport_ib(id->device, id->port_num)) {
>> +				ib_sa_free_multicast(mc->multicast.ib);
>> +				kfree(mc);
> 
> cap_ib_mcast()
> 
> 
>> +			} else if (rdma_transport_iboe(id->device,
>> +						       id->port_num))
>> +				kref_put(&mc->mcref, release_mc);
>> +
>>  			return;
>>  		}
>>  	}
>> diff --git a/drivers/infiniband/core/ucma.c
>> b/drivers/infiniband/core/ucma.c
>> index 45d67e9..42c9bf6 100644
>> --- a/drivers/infiniband/core/ucma.c
>> +++ b/drivers/infiniband/core/ucma.c
>> @@ -722,26 +722,13 @@ static ssize_t ucma_query_route(struct ucma_file
>> *file,
>>
>>  	resp.node_guid = (__force __u64) ctx->cm_id->device->node_guid;
>>  	resp.port_num = ctx->cm_id->port_num;
>> -	switch (rdma_node_get_transport(ctx->cm_id->device->node_type)) {
>> -	case RDMA_TRANSPORT_IB:
>> -		switch (rdma_port_get_link_layer(ctx->cm_id->device,
>> -			ctx->cm_id->port_num)) {
>> -		case IB_LINK_LAYER_INFINIBAND:
>> -			ucma_copy_ib_route(&resp, &ctx->cm_id->route);
>> -			break;
>> -		case IB_LINK_LAYER_ETHERNET:
>> -			ucma_copy_iboe_route(&resp, &ctx->cm_id->route);
>> -			break;
>> -		default:
>> -			break;
>> -		}
>> -		break;
>> -	case RDMA_TRANSPORT_IWARP:
>> +
>> +	if (rdma_transport_ib(ctx->cm_id->device, ctx->cm_id->port_num))
>> +		ucma_copy_ib_route(&resp, &ctx->cm_id->route);
> 
> cap_ib_sa()
> 
> 
>> +	else if (rdma_transport_iboe(ctx->cm_id->device, ctx->cm_id-
>>> port_num))
>> +		ucma_copy_iboe_route(&resp, &ctx->cm_id->route);
>> +	else if (rdma_transport_iwarp(ctx->cm_id->device, ctx->cm_id-
>>> port_num))
>>  		ucma_copy_iw_route(&resp, &ctx->cm_id->route);
>> -		break;
>> -	default:
>> -		break;
>> -	}
>>
>>  out:
>>  	if (copy_to_user((void __user *)(unsigned long)cmd.response,
> 
> 
> - Sean
> 
