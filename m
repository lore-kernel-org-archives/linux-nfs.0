Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:32939 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753241AbaJNRZC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Oct 2014 13:25:02 -0400
Message-ID: <543D5C70.5050906@opengridcomputing.com>
Date: Tue, 14 Oct 2014 12:25:04 -0500
From: Steve Wise <swise@opengridcomputing.com>
MIME-Version: 1.0
To: Dan Carpenter <dan.carpenter@oracle.com>
CC: Hariprasad S <hariprasad@chelsio.com>, linux-nfs@vger.kernel.org,
        pramod@chelsio.com
Subject: Re: RDMA/cxgb4: Add support for active and passive open connection
 with IPv6 address
References: <20141014084629.GA26952@mwanda>
In-Reply-To: <20141014084629.GA26952@mwanda>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/14/2014 3:46 AM, Dan Carpenter wrote:
> Hello Vipul Pandya,
>
> The patch 830662f6f032: "RDMA/cxgb4: Add support for active and
> passive open connection with IPv6 address" from Jul 4, 2013, leads to
> the following static checker warning:
>
> 	net/sunrpc/xprtrdma/svc_rdma_transport.c:737 svc_rdma_create()
> 	error: passing non negative 1 to ERR_PTR
>
> drivers/infiniband/hw/cxgb4/cm.c
>    3128  static int create_server4(struct c4iw_dev *dev, struct c4iw_listen_ep *ep)
>    3129  {
>    3130          int err;
>    3131          struct sockaddr_in *sin = (struct sockaddr_in *)
>    3132                                    &ep->com.mapped_local_addr;
>    3133
>    3134          if (dev->rdev.lldi.enable_fw_ofld_conn) {
>    3135                  do {
>    3136                          err = cxgb4_create_server_filter(
>    3137                                  ep->com.dev->rdev.lldi.ports[0], ep->stid,
>    3138                                  sin->sin_addr.s_addr, sin->sin_port, 0,
>    3139                                  ep->com.dev->rdev.lldi.rxq_ids[0], 0, 0);
>    3140                          if (err == -EBUSY) {
>    3141                                  set_current_state(TASK_UNINTERRUPTIBLE);
>    3142                                  schedule_timeout(usecs_to_jiffies(100));
>    3143                          }
>    3144                  } while (err == -EBUSY);
>    3145          } else {
>    3146                  c4iw_init_wr_wait(&ep->com.wr_wait);
>    3147                  err = cxgb4_create_server(ep->com.dev->rdev.lldi.ports[0],
>    3148                                  ep->stid, sin->sin_addr.s_addr, sin->sin_port,
>    3149                                  0, ep->com.dev->rdev.lldi.rxq_ids[0]);
>                                ^^^^^^^^^^^^^^^^^^^^
> cxgb4_create_server() can return NET_XMIT_DROP which leads to an oops.
> The 1 is eventually returned to svc_create_xprt() which treats it as a
> valid pointer and passes it to svc_add_new_perm_xprt() which
> dereferences it.
>
>    3150                  if (!err)
>    3151                          err = c4iw_wait_for_reply(&ep->com.dev->rdev,
>    3152                                                    &ep->com.wr_wait,
>    3153                                                    0, 0, __func__);
>    3154          }
>    3155          if (err)
>    3156                  pr_err("cxgb4_create_server/filter failed err %d stid %d laddr %pI4 lport %d\n"
>    3157                         , err, ep->stid,
>    3158                         &sin->sin_addr, ntohs(sin->sin_port));
>    3159          return err;
>    3160  }
>
> regards,
> dan carpenter
>

Hey Dan, Thanks for the analysis.  We'll get on this asap (Vipul is no 
longer working on cxgb4).

Steve.
