Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:42514 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751054AbbDGVLU convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Apr 2015 17:11:20 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Michael Wang'" <yun.wang@profitbricks.com>,
        "'Roland Dreier'" <roland@kernel.org>,
        "'Sean Hefty'" <sean.hefty@intel.com>, <linux-rdma@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <netdev@vger.kernel.org>
Cc: "'Hal Rosenstock'" <hal.rosenstock@gmail.com>,
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
References: <5523CCD5.6030401@profitbricks.com> <5523CF74.8020004@profitbricks.com>
In-Reply-To: <5523CF74.8020004@profitbricks.com>
Subject: RE: [PATCH v2 13/17] IB/Verbs: Reform cma/ucma with management helpers
Date: Tue, 7 Apr 2015 16:11:23 -0500
Message-ID: <009b01d07177$66a9b7f0$33fd27d0$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: Michael Wang [mailto:yun.wang@profitbricks.com]
> Sent: Tuesday, April 07, 2015 7:37 AM
> To: Roland Dreier; Sean Hefty; linux-rdma@vger.kernel.org; linux-kernel@vger.kernel.org; linux-nfs@vger.kernel.org;
> netdev@vger.kernel.org
> Cc: Hal Rosenstock; Tom Tucker; Steve Wise; Hoang-Nam Nguyen; Christoph Raisch; Mike Marciniszyn; Eli Cohen; Faisal Latif; Upinder
> Malhi; Trond Myklebust; J. Bruce Fields; David S. Miller; Ira Weiny; PJ Waskiewicz; Tatyana Nikolova; Or Gerlitz; Jack Morgenstein; Haggai
> Eran; Ilya Nelkenbaum; Yann Droneaud; Bart Van Assche; Shachar Raindel; Sagi Grimberg; Devesh Sharma; Matan Barak; Moni Shoua; Jiri
> Kosina; Selvin Xavier; Mitesh Ahuja; Li RongQing; Rasmus Villemoes; Alex Estrin; Doug Ledford; Eric Dumazet; Erez Shitrit; Tom
> Gundersen; Chuck Lever; Michael Wang
> Subject: [PATCH v2 13/17] IB/Verbs: Reform cma/ucma with management helpers
> 
> 
> Reform cma/ucma with management helpers.
> 
> Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> Cc: Doug Ledford <dledford@redhat.com>
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Sean Hefty <sean.hefty@intel.com>
> Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
> ---
>  drivers/infiniband/core/cma.c  | 182 +++++++++++++----------------------------
>  drivers/infiniband/core/ucma.c |  25 ++----
>  2 files changed, 65 insertions(+), 142 deletions(-)
> 
> diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
> index d8a8ea7..c23f483 100644
> --- a/drivers/infiniband/core/cma.c
> +++ b/drivers/infiniband/core/cma.c
> @@ -435,10 +435,10 @@ static int cma_resolve_ib_dev(struct rdma_id_private *id_priv)
>  	pkey = ntohs(addr->sib_pkey);
> 
>  	list_for_each_entry(cur_dev, &dev_list, list) {
> -		if (rdma_node_get_transport(cur_dev->device->node_type) != RDMA_TRANSPORT_IB)
> -			continue;
> -
>  		for (p = 1; p <= cur_dev->device->phys_port_cnt; ++p) {
> +			if (!rdma_ib_mgmt(cur_dev->device, p))
> +				continue;
> +
>  			if (ib_find_cached_pkey(cur_dev->device, p, pkey, &index))
>  				continue;
> 
> @@ -633,10 +633,10 @@ static int cma_modify_qp_rtr(struct rdma_id_private *id_priv,
>  	if (ret)
>  		goto out;
> 
> -	if (rdma_node_get_transport(id_priv->cma_dev->device->node_type)
> -	    == RDMA_TRANSPORT_IB &&
> -	    rdma_port_get_link_layer(id_priv->id.device, id_priv->id.port_num)
> -	    == IB_LINK_LAYER_ETHERNET) {
> +	/* Will this happen? */
> +	BUG_ON(id_priv->cma_dev->device != id_priv->id.device);
> +
> +	if (rdma_transport_iboe(id_priv->id.device, id_priv->id.port_num)) {
>  		ret = rdma_addr_find_smac_by_sgid(&sgid, qp_attr.smac, NULL);
> 
>  		if (ret)
> @@ -700,8 +700,7 @@ static int cma_ib_init_qp_attr(struct rdma_id_private *id_priv,
>  	int ret;
>  	u16 pkey;
> 
> -	if (rdma_port_get_link_layer(id_priv->id.device, id_priv->id.port_num) ==
> -	    IB_LINK_LAYER_INFINIBAND)
> +	if (rdma_transport_ib(id_priv->id.device, id_priv->id.port_num))
>  		pkey = ib_addr_get_pkey(dev_addr);
>  	else
>  		pkey = 0xffff;
> @@ -735,8 +734,7 @@ int rdma_init_qp_attr(struct rdma_cm_id *id, struct ib_qp_attr *qp_attr,
>  	int ret = 0;
> 
>  	id_priv = container_of(id, struct rdma_id_private, id);
> -	switch (rdma_node_get_transport(id_priv->id.device->node_type)) {
> -	case RDMA_TRANSPORT_IB:
> +	if (rdma_ib_mgmt(id_priv->id.device, id_priv->id.port_num)) {
>  		if (!id_priv->cm_id.ib || (id_priv->id.qp_type == IB_QPT_UD))
>  			ret = cma_ib_init_qp_attr(id_priv, qp_attr, qp_attr_mask);
>  		else
> @@ -745,19 +743,16 @@ int rdma_init_qp_attr(struct rdma_cm_id *id, struct ib_qp_attr *qp_attr,
> 
>  		if (qp_attr->qp_state == IB_QPS_RTR)
>  			qp_attr->rq_psn = id_priv->seq_num;
> -		break;
> -	case RDMA_TRANSPORT_IWARP:
> +	} else if (rdma_transport_iwarp(id_priv->id.device,
> +						id_priv->id.port_num)) {
>  		if (!id_priv->cm_id.iw) {
>  			qp_attr->qp_access_flags = 0;
>  			*qp_attr_mask = IB_QP_STATE | IB_QP_ACCESS_FLAGS;
>  		} else
>  			ret = iw_cm_init_qp_attr(id_priv->cm_id.iw, qp_attr,
>  						 qp_attr_mask);
> -		break;
> -	default:
> +	} else
>  		ret = -ENOSYS;
> -		break;
> -	}
> 
>  	return ret;
>  }
> @@ -928,13 +923,9 @@ static inline int cma_user_data_offset(struct rdma_id_private *id_priv)
> 
>  static void cma_cancel_route(struct rdma_id_private *id_priv)
>  {
> -	switch (rdma_port_get_link_layer(id_priv->id.device, id_priv->id.port_num)) {
> -	case IB_LINK_LAYER_INFINIBAND:
> +	if (rdma_transport_ib(id_priv->id.device, id_priv->id.port_num)) {
>  		if (id_priv->query)
>  			ib_sa_cancel_query(id_priv->query_id, id_priv->query);
> -		break;
> -	default:
> -		break;
>  	}
>  }
> 
> @@ -1006,17 +997,14 @@ static void cma_leave_mc_groups(struct rdma_id_private *id_priv)
>  		mc = container_of(id_priv->mc_list.next,
>  				  struct cma_multicast, list);
>  		list_del(&mc->list);
> -		switch (rdma_port_get_link_layer(id_priv->cma_dev->device, id_priv->id.port_num)) {
> -		case IB_LINK_LAYER_INFINIBAND:
> +		if (rdma_transport_ib(id_priv->cma_dev->device,
> +				      id_priv->id.port_num)) {
>  			ib_sa_free_multicast(mc->multicast.ib);
>  			kfree(mc);
>  			break;
> -		case IB_LINK_LAYER_ETHERNET:
> +		} else if (rdma_transport_ib(id_priv->cma_dev->device,
> +					     id_priv->id.port_num))
>  			kref_put(&mc->mcref, release_mc);
> -			break;
> -		default:
> -			break;
> -		}
>  	}
>  }
>

Doesn't the above change result in:

if (rdma_transport_ib()) {
} else if (rdma_transport_ib()) {
}
 
????

> @@ -1037,17 +1025,13 @@ void rdma_destroy_id(struct rdma_cm_id *id)
>  	mutex_unlock(&id_priv->handler_mutex);
> 
>  	if (id_priv->cma_dev) {
> -		switch (rdma_node_get_transport(id_priv->id.device->node_type)) {
> -		case RDMA_TRANSPORT_IB:
> +		if (rdma_ib_mgmt(id_priv->id.device, id_priv->id.port_num)) {
>  			if (id_priv->cm_id.ib)
>  				ib_destroy_cm_id(id_priv->cm_id.ib);
> -			break;
> -		case RDMA_TRANSPORT_IWARP:
> +		} else if (rdma_transport_iwarp(id_priv->id.device,
> +							id_priv->id.port_num)) {
>  			if (id_priv->cm_id.iw)
>  				iw_destroy_cm_id(id_priv->cm_id.iw);
> -			break;
> -		default:
> -			break;
>  		}
>  		cma_leave_mc_groups(id_priv);
>  		cma_release_dev(id_priv);
> @@ -1966,26 +1950,14 @@ int rdma_resolve_route(struct rdma_cm_id *id, int timeout_ms)
>  		return -EINVAL;
> 
>  	atomic_inc(&id_priv->refcount);
> -	switch (rdma_node_get_transport(id->device->node_type)) {
> -	case RDMA_TRANSPORT_IB:
> -		switch (rdma_port_get_link_layer(id->device, id->port_num)) {
> -		case IB_LINK_LAYER_INFINIBAND:
> -			ret = cma_resolve_ib_route(id_priv, timeout_ms);
> -			break;
> -		case IB_LINK_LAYER_ETHERNET:
> -			ret = cma_resolve_iboe_route(id_priv);
> -			break;
> -		default:
> -			ret = -ENOSYS;
> -		}
> -		break;
> -	case RDMA_TRANSPORT_IWARP:
> +	if (rdma_transport_ib(id->device, id->port_num))
> +		ret = cma_resolve_ib_route(id_priv, timeout_ms);
> +	else if (rdma_transport_iboe(id->device, id->port_num))
> +		ret = cma_resolve_iboe_route(id_priv);
> +	else if (rdma_transport_iwarp(id->device, id->port_num))
>  		ret = cma_resolve_iw_route(id_priv, timeout_ms);
> -		break;
> -	default:
> +	else
>  		ret = -ENOSYS;
> -		break;
> -	}
>  	if (ret)
>  		goto err;
> 
> @@ -2059,7 +2031,7 @@ port_found:
>  		goto out;
> 
>  	id_priv->id.route.addr.dev_addr.dev_type =
> -		(rdma_port_get_link_layer(cma_dev->device, p) == IB_LINK_LAYER_INFINIBAND) ?
> +		(rdma_transport_ib(cma_dev->device, p)) ?
>  		ARPHRD_INFINIBAND : ARPHRD_ETHER;
> 
>  	rdma_addr_set_sgid(&id_priv->id.route.addr.dev_addr, &gid);
> @@ -2536,18 +2508,15 @@ int rdma_listen(struct rdma_cm_id *id, int backlog)
> 
>  	id_priv->backlog = backlog;
>  	if (id->device) {
> -		switch (rdma_node_get_transport(id->device->node_type)) {
> -		case RDMA_TRANSPORT_IB:
> +		if (rdma_ib_mgmt(id->device, id->port_num)) {
>  			ret = cma_ib_listen(id_priv);
>  			if (ret)
>  				goto err;
> -			break;
> -		case RDMA_TRANSPORT_IWARP:
> +		} else if (rdma_transport_iwarp(id->device, id->port_num)) {
>  			ret = cma_iw_listen(id_priv, backlog);
>  			if (ret)
>  				goto err;
> -			break;
> -		default:
> +		} else {
>  			ret = -ENOSYS;
>  			goto err;
>  		}
> @@ -2883,20 +2852,15 @@ int rdma_connect(struct rdma_cm_id *id, struct rdma_conn_param *conn_param)
>  		id_priv->srq = conn_param->srq;
>  	}
> 
> -	switch (rdma_node_get_transport(id->device->node_type)) {
> -	case RDMA_TRANSPORT_IB:
> +	if (rdma_ib_mgmt(id->device, id->port_num)) {
>  		if (id->qp_type == IB_QPT_UD)
>  			ret = cma_resolve_ib_udp(id_priv, conn_param);
>  		else
>  			ret = cma_connect_ib(id_priv, conn_param);
> -		break;
> -	case RDMA_TRANSPORT_IWARP:
> +	} else if (rdma_transport_iwarp(id->device, id->port_num))
>  		ret = cma_connect_iw(id_priv, conn_param);
> -		break;
> -	default:
> +	else
>  		ret = -ENOSYS;
> -		break;
> -	}
>  	if (ret)
>  		goto err;
> 
> @@ -2999,8 +2963,7 @@ int rdma_accept(struct rdma_cm_id *id, struct rdma_conn_param *conn_param)
>  		id_priv->srq = conn_param->srq;
>  	}
> 
> -	switch (rdma_node_get_transport(id->device->node_type)) {
> -	case RDMA_TRANSPORT_IB:
> +	if (rdma_ib_mgmt(id->device, id->port_num)) {
>  		if (id->qp_type == IB_QPT_UD) {
>  			if (conn_param)
>  				ret = cma_send_sidr_rep(id_priv, IB_SIDR_SUCCESS,
> @@ -3016,14 +2979,10 @@ int rdma_accept(struct rdma_cm_id *id, struct rdma_conn_param *conn_param)
>  			else
>  				ret = cma_rep_recv(id_priv);
>  		}
> -		break;
> -	case RDMA_TRANSPORT_IWARP:
> +	} else if (rdma_transport_iwarp(id->device, id->port_num))
>  		ret = cma_accept_iw(id_priv, conn_param);
> -		break;
> -	default:
> +	else
>  		ret = -ENOSYS;
> -		break;
> -	}
> 
>  	if (ret)
>  		goto reject;
> @@ -3067,8 +3026,7 @@ int rdma_reject(struct rdma_cm_id *id, const void *private_data,
>  	if (!id_priv->cm_id.ib)
>  		return -EINVAL;
> 
> -	switch (rdma_node_get_transport(id->device->node_type)) {
> -	case RDMA_TRANSPORT_IB:
> +	if (rdma_ib_mgmt(id->device, id->port_num)) {
>  		if (id->qp_type == IB_QPT_UD)
>  			ret = cma_send_sidr_rep(id_priv, IB_SIDR_REJECT, 0,
>  						private_data, private_data_len);
> @@ -3076,15 +3034,11 @@ int rdma_reject(struct rdma_cm_id *id, const void *private_data,
>  			ret = ib_send_cm_rej(id_priv->cm_id.ib,
>  					     IB_CM_REJ_CONSUMER_DEFINED, NULL,
>  					     0, private_data, private_data_len);
> -		break;
> -	case RDMA_TRANSPORT_IWARP:
> +	} else if (rdma_transport_iwarp(id->device, id->port_num)) {
>  		ret = iw_cm_reject(id_priv->cm_id.iw,
>  				   private_data, private_data_len);
> -		break;
> -	default:
> +	} else
>  		ret = -ENOSYS;
> -		break;
> -	}
>  	return ret;
>  }
>  EXPORT_SYMBOL(rdma_reject);
> @@ -3098,22 +3052,17 @@ int rdma_disconnect(struct rdma_cm_id *id)
>  	if (!id_priv->cm_id.ib)
>  		return -EINVAL;
> 
> -	switch (rdma_node_get_transport(id->device->node_type)) {
> -	case RDMA_TRANSPORT_IB:
> +	if (rdma_ib_mgmt(id->device, id->port_num)) {
>  		ret = cma_modify_qp_err(id_priv);
>  		if (ret)
>  			goto out;
>  		/* Initiate or respond to a disconnect. */
>  		if (ib_send_cm_dreq(id_priv->cm_id.ib, NULL, 0))
>  			ib_send_cm_drep(id_priv->cm_id.ib, NULL, 0);
> -		break;
> -	case RDMA_TRANSPORT_IWARP:
> +	} else if (rdma_transport_iwarp(id->device, id->port_num)) {
>  		ret = iw_cm_disconnect(id_priv->cm_id.iw, 0);
> -		break;
> -	default:
> +	} else
>  		ret = -EINVAL;
> -		break;
> -	}
>  out:
>  	return ret;
>  }
> @@ -3359,24 +3308,13 @@ int rdma_join_multicast(struct rdma_cm_id *id, struct sockaddr *addr,
>  	list_add(&mc->list, &id_priv->mc_list);
>  	spin_unlock(&id_priv->lock);
> 
> -	switch (rdma_node_get_transport(id->device->node_type)) {
> -	case RDMA_TRANSPORT_IB:
> -		switch (rdma_port_get_link_layer(id->device, id->port_num)) {
> -		case IB_LINK_LAYER_INFINIBAND:
> -			ret = cma_join_ib_multicast(id_priv, mc);
> -			break;
> -		case IB_LINK_LAYER_ETHERNET:
> -			kref_init(&mc->mcref);
> -			ret = cma_iboe_join_multicast(id_priv, mc);
> -			break;
> -		default:
> -			ret = -EINVAL;
> -		}
> -		break;
> -	default:
> +	if (rdma_transport_iboe(id->device, id->port_num)) {
> +		kref_init(&mc->mcref);
> +		ret = cma_iboe_join_multicast(id_priv, mc);
> +	} else if (rdma_transport_ib(id->device, id->port_num))
> +		ret = cma_join_ib_multicast(id_priv, mc);
> +	else
>  		ret = -ENOSYS;
> -		break;
> -	}
> 
>  	if (ret) {
>  		spin_lock_irq(&id_priv->lock);
> @@ -3404,19 +3342,17 @@ void rdma_leave_multicast(struct rdma_cm_id *id, struct sockaddr *addr)
>  				ib_detach_mcast(id->qp,
>  						&mc->multicast.ib->rec.mgid,
>  						be16_to_cpu(mc->multicast.ib->rec.mlid));
> -			if (rdma_node_get_transport(id_priv->cma_dev->device->node_type) == RDMA_TRANSPORT_IB) {
> -				switch (rdma_port_get_link_layer(id->device, id->port_num)) {
> -				case IB_LINK_LAYER_INFINIBAND:
> -					ib_sa_free_multicast(mc->multicast.ib);
> -					kfree(mc);
> -					break;
> -				case IB_LINK_LAYER_ETHERNET:
> -					kref_put(&mc->mcref, release_mc);
> -					break;
> -				default:
> -					break;
> -				}
> -			}
> +
> +			/* Will this happen? */
> +			BUG_ON(id_priv->cma_dev->device != id->device);
> +
> +			if (rdma_transport_ib(id->device, id->port_num)) {
> +				ib_sa_free_multicast(mc->multicast.ib);
> +				kfree(mc);
> +			} else if (rdma_transport_iboe(id->device,
> +						       id->port_num))
> +				kref_put(&mc->mcref, release_mc);
> +
>  			return;
>  		}
>  	}
> diff --git a/drivers/infiniband/core/ucma.c b/drivers/infiniband/core/ucma.c
> index 45d67e9..42c9bf6 100644
> --- a/drivers/infiniband/core/ucma.c
> +++ b/drivers/infiniband/core/ucma.c
> @@ -722,26 +722,13 @@ static ssize_t ucma_query_route(struct ucma_file *file,
> 
>  	resp.node_guid = (__force __u64) ctx->cm_id->device->node_guid;
>  	resp.port_num = ctx->cm_id->port_num;
> -	switch (rdma_node_get_transport(ctx->cm_id->device->node_type)) {
> -	case RDMA_TRANSPORT_IB:
> -		switch (rdma_port_get_link_layer(ctx->cm_id->device,
> -			ctx->cm_id->port_num)) {
> -		case IB_LINK_LAYER_INFINIBAND:
> -			ucma_copy_ib_route(&resp, &ctx->cm_id->route);
> -			break;
> -		case IB_LINK_LAYER_ETHERNET:
> -			ucma_copy_iboe_route(&resp, &ctx->cm_id->route);
> -			break;
> -		default:
> -			break;
> -		}
> -		break;
> -	case RDMA_TRANSPORT_IWARP:
> +
> +	if (rdma_transport_ib(ctx->cm_id->device, ctx->cm_id->port_num))
> +		ucma_copy_ib_route(&resp, &ctx->cm_id->route);
> +	else if (rdma_transport_iboe(ctx->cm_id->device, ctx->cm_id->port_num))
> +		ucma_copy_iboe_route(&resp, &ctx->cm_id->route);
> +	else if (rdma_transport_iwarp(ctx->cm_id->device, ctx->cm_id->port_num))
>  		ucma_copy_iw_route(&resp, &ctx->cm_id->route);
> -		break;
> -	default:
> -		break;
> -	}
> 
>  out:
>  	if (copy_to_user((void __user *)(unsigned long)cmd.response,
> --
> 2.1.0

