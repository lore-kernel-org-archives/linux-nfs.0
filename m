Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59328 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752811AbbC3P4v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Mar 2015 11:56:51 -0400
Message-ID: <1427730964.21101.195.camel@redhat.com>
Subject: Re: [PATCH 01/11] IB/Verbs: Use helpers to check transport and link
 layer
From: Doug Ledford <dledford@redhat.com>
To: Michael Wang <yun.wang@profitbricks.com>
Cc: Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>,
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
        Eric Dumazet <edumazet@google.com>, Erez Shitrit <erezsh@mellanox.com>,
        Sagi Grimberg <sagig@mellanox.com>, Haggai Eran <haggaie@mellanox.com>,
        Shachar Raindel <raindel@mellanox.com>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>,
        Steve Wise <swise@opengridcomputing.com>, Tom Tucker <tom@ogc.us>,
        Chuck Lever <chuck.lever@oracle.com>
Date: Mon, 30 Mar 2015 11:56:04 -0400
In-Reply-To: <55157A0B.4000002@profitbricks.com>
References: <551579CA.4030901@profitbricks.com>
	 <55157A0B.4000002@profitbricks.com>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-/32TPje5lUuKe37tEZG2"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-/32TPje5lUuKe37tEZG2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-03-27 at 16:40 +0100, Michael Wang wrote:
> We have so much places to check transport type and link layer type, it's =
now
> make sense to introduce some helpers in order to refine the lengthy code.
>=20
> This patch will introduce helpers:
>     rdma_transport_is_ib()
>     rdma_transport_is_iwarp()
>     rdma_port_ll_is_ib()
>     rdma_port_ll_is_eth()
> and use them to save some code for us.

If the end result is to do something like I proposed, then why take this
intermediate step that just has to be backed out later?

In other words, if our end goal is to have

rdma_transport_is_ib()
rdma_transport_is_iwarp()
rdma_transport_is_roce()
rdma_transport_is_opa()

Then we should skip doing rdma_port_ll_is_*() as the answers to these
items would be implied by rdma_transport_is_roce() and such.

> Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> Cc: Doug Ledford <dledford@redhat.com>
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Sean Hefty <sean.hefty@intel.com>
> Signed-off-by: Michael Wang <yun.wang@profitbricks.com>
> ---
>  drivers/infiniband/core/agent.c           |  2 +-
>  drivers/infiniband/core/cm.c              |  2 +-
>  drivers/infiniband/core/cma.c             | 27 ++++++++++++-------------=
--
>  drivers/infiniband/core/mad.c             |  6 +++---
>  drivers/infiniband/core/multicast.c       | 11 ++++-------
>  drivers/infiniband/core/sa_query.c        | 14 +++++++-------
>  drivers/infiniband/core/ucm.c             |  3 +--
>  drivers/infiniband/core/user_mad.c        |  2 +-
>  drivers/infiniband/core/verbs.c           |  5 ++---
>  drivers/infiniband/hw/mlx4/ah.c           |  2 +-
>  drivers/infiniband/hw/mlx4/cq.c           |  4 +---
>  drivers/infiniband/hw/mlx4/mad.c          | 14 ++++----------
>  drivers/infiniband/hw/mlx4/main.c         |  8 +++-----
>  drivers/infiniband/hw/mlx4/mlx4_ib.h      |  2 +-
>  drivers/infiniband/hw/mlx4/qp.c           | 21 +++++++--------------
>  drivers/infiniband/hw/mlx4/sysfs.c        |  6 ++----
>  drivers/infiniband/ulp/ipoib/ipoib_main.c |  6 +++---
>  include/rdma/ib_verbs.h                   | 24 ++++++++++++++++++++++++
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c   |  3 +--
>  19 files changed, 79 insertions(+), 83 deletions(-)
>=20
> diff --git a/drivers/infiniband/core/agent.c b/drivers/infiniband/core/ag=
ent.c
> index f6d2961..27f1bec 100644
> --- a/drivers/infiniband/core/agent.c
> +++ b/drivers/infiniband/core/agent.c
> @@ -156,7 +156,7 @@ int ib_agent_port_open(struct ib_device *device, int =
port_num)
>          goto error1;
>      }
> =20
> -    if (rdma_port_get_link_layer(device, port_num) =3D=3D IB_LINK_LAYER_=
INFINIBAND) {
> +    if (rdma_port_ll_is_ib(device, port_num)) {
>          /* Obtain send only MAD agent for SMI QP */
>          port_priv->agent[0] =3D ib_register_mad_agent(device, port_num,
>                                  IB_QPT_SMI, NULL, 0,
> diff --git a/drivers/infiniband/core/cm.c b/drivers/infiniband/core/cm.c
> index e28a494..2c72e9e 100644
> --- a/drivers/infiniband/core/cm.c
> +++ b/drivers/infiniband/core/cm.c
> @@ -3762,7 +3762,7 @@ static void cm_add_one(struct ib_device *ib_device)
>      int ret;
>      u8 i;
> =20
> -    if (rdma_node_get_transport(ib_device->node_type) !=3D RDMA_TRANSPOR=
T_IB)
> +    if (!rdma_transport_is_ib(ib_device))
>          return;
> =20
>      cm_dev =3D kzalloc(sizeof(*cm_dev) + sizeof(*port) *
> diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.=
c
> index d570030..668e955 100644
> --- a/drivers/infiniband/core/cma.c
> +++ b/drivers/infiniband/core/cma.c
> @@ -375,8 +375,8 @@ static int cma_acquire_dev(struct rdma_id_private *id=
_priv,
>                       listen_id_priv->id.port_num) =3D=3D dev_ll) {
>          cma_dev =3D listen_id_priv->cma_dev;
>          port =3D listen_id_priv->id.port_num;
> -        if (rdma_node_get_transport(cma_dev->device->node_type) =3D=3D R=
DMA_TRANSPORT_IB &&
> -            rdma_port_get_link_layer(cma_dev->device, port) =3D=3D IB_LI=
NK_LAYER_ETHERNET)
> +        if (rdma_transport_is_ib(cma_dev->device) &&
> +            rdma_port_ll_is_eth(cma_dev->device, port))
>              ret =3D ib_find_cached_gid(cma_dev->device, &iboe_gid,
>                           &found_port, NULL);
>          else
> @@ -395,8 +395,8 @@ static int cma_acquire_dev(struct rdma_id_private *id=
_priv,
>                  listen_id_priv->id.port_num =3D=3D port)
>                  continue;
>              if (rdma_port_get_link_layer(cma_dev->device, port) =3D=3D d=
ev_ll) {
> -                if (rdma_node_get_transport(cma_dev->device->node_type) =
=3D=3D RDMA_TRANSPORT_IB &&
> -                    rdma_port_get_link_layer(cma_dev->device, port) =3D=
=3D IB_LINK_LAYER_ETHERNET)
> +                if (rdma_transport_is_ib(cma_dev->device) &&
> +                    rdma_port_ll_is_eth(cma_dev->device, port))
>                      ret =3D ib_find_cached_gid(cma_dev->device, &iboe_gi=
d, &found_port, NULL);
>                  else
>                      ret =3D ib_find_cached_gid(cma_dev->device, &gid, &f=
ound_port, NULL);
> @@ -435,7 +435,7 @@ static int cma_resolve_ib_dev(struct rdma_id_private =
*id_priv)
>      pkey =3D ntohs(addr->sib_pkey);
> =20
>      list_for_each_entry(cur_dev, &dev_list, list) {
> -        if (rdma_node_get_transport(cur_dev->device->node_type) !=3D RDM=
A_TRANSPORT_IB)
> +        if (!rdma_transport_is_ib(cur_dev->device))
>              continue;
> =20
>          for (p =3D 1; p <=3D cur_dev->device->phys_port_cnt; ++p) {
> @@ -633,10 +633,8 @@ static int cma_modify_qp_rtr(struct rdma_id_private =
*id_priv,
>      if (ret)
>          goto out;
> =20
> -    if (rdma_node_get_transport(id_priv->cma_dev->device->node_type)
> -        =3D=3D RDMA_TRANSPORT_IB &&
> -        rdma_port_get_link_layer(id_priv->id.device, id_priv->id.port_nu=
m)
> -        =3D=3D IB_LINK_LAYER_ETHERNET) {
> +    if (rdma_transport_is_ib(id_priv->cma_dev->device) &&
> +        rdma_port_ll_is_eth(id_priv->id.device, id_priv->id.port_num)) {
>          ret =3D rdma_addr_find_smac_by_sgid(&sgid, qp_attr.smac, NULL);
> =20
>          if (ret)
> @@ -700,8 +698,7 @@ static int cma_ib_init_qp_attr(struct rdma_id_private=
 *id_priv,
>      int ret;
>      u16 pkey;
> =20
> -    if (rdma_port_get_link_layer(id_priv->id.device, id_priv->id.port_nu=
m) =3D=3D
> -        IB_LINK_LAYER_INFINIBAND)
> +    if (rdma_port_ll_is_ib(id_priv->id.device, id_priv->id.port_num))
>          pkey =3D ib_addr_get_pkey(dev_addr);
>      else
>          pkey =3D 0xffff;
> @@ -1626,7 +1623,7 @@ static void cma_listen_on_dev(struct rdma_id_privat=
e *id_priv,
>      int ret;
> =20
>      if (cma_family(id_priv) =3D=3D AF_IB &&
> -        rdma_node_get_transport(cma_dev->device->node_type) !=3D RDMA_TR=
ANSPORT_IB)
> +        !rdma_transport_is_ib(cma_dev->device))
>          return;
> =20
>      id =3D rdma_create_id(cma_listen_handler, id_priv, id_priv->id.ps,
> @@ -2028,7 +2025,7 @@ static int cma_bind_loopback(struct rdma_id_private=
 *id_priv)
>      mutex_lock(&lock);
>      list_for_each_entry(cur_dev, &dev_list, list) {
>          if (cma_family(id_priv) =3D=3D AF_IB &&
> -            rdma_node_get_transport(cur_dev->device->node_type) !=3D RDM=
A_TRANSPORT_IB)
> +            !rdma_transport_is_ib(cur_dev->device))
>              continue;
> =20
>          if (!cma_dev)
> @@ -2060,7 +2057,7 @@ port_found:
>          goto out;
> =20
>      id_priv->id.route.addr.dev_addr.dev_type =3D
> -        (rdma_port_get_link_layer(cma_dev->device, p) =3D=3D IB_LINK_LAY=
ER_INFINIBAND) ?
> +        (rdma_port_ll_is_ib(cma_dev->device, p)) ?
>          ARPHRD_INFINIBAND : ARPHRD_ETHER;
> =20
>      rdma_addr_set_sgid(&id_priv->id.route.addr.dev_addr, &gid);
> @@ -3405,7 +3402,7 @@ void rdma_leave_multicast(struct rdma_cm_id *id, st=
ruct sockaddr *addr)
>                  ib_detach_mcast(id->qp,
>                          &mc->multicast.ib->rec.mgid,
>                          be16_to_cpu(mc->multicast.ib->rec.mlid));
> -            if (rdma_node_get_transport(id_priv->cma_dev->device->node_t=
ype) =3D=3D RDMA_TRANSPORT_IB) {
> +            if (rdma_transport_is_ib(id_priv->cma_dev->device)) {
>                  switch (rdma_port_get_link_layer(id->device, id->port_nu=
m)) {
>                  case IB_LINK_LAYER_INFINIBAND:
>                      ib_sa_free_multicast(mc->multicast.ib);
> diff --git a/drivers/infiniband/core/mad.c b/drivers/infiniband/core/mad.=
c
> index 74c30f4..23cf9e8 100644
> --- a/drivers/infiniband/core/mad.c
> +++ b/drivers/infiniband/core/mad.c
> @@ -2938,7 +2938,7 @@ static int ib_mad_port_open(struct ib_device *devic=
e,
>      init_mad_qp(port_priv, &port_priv->qp_info[1]);
> =20
>      cq_size =3D mad_sendq_size + mad_recvq_size;
> -    has_smi =3D rdma_port_get_link_layer(device, port_num) =3D=3D IB_LIN=
K_LAYER_INFINIBAND;
> +    has_smi =3D rdma_port_ll_is_ib(device, port_num);
>      if (has_smi)
>          cq_size *=3D 2;
> =20
> @@ -3057,7 +3057,7 @@ static void ib_mad_init_device(struct ib_device *de=
vice)
>  {
>      int start, end, i;
> =20
> -    if (rdma_node_get_transport(device->node_type) !=3D RDMA_TRANSPORT_I=
B)
> +    if (!rdma_transport_is_ib(device))
>          return;
> =20
>      if (device->node_type =3D=3D RDMA_NODE_IB_SWITCH) {
> @@ -3102,7 +3102,7 @@ static void ib_mad_remove_device(struct ib_device *=
device)
>  {
>      int i, num_ports, cur_port;
> =20
> -    if (rdma_node_get_transport(device->node_type) !=3D RDMA_TRANSPORT_I=
B)
> +    if (!rdma_transport_is_ib(device))
>          return;
> =20
>      if (device->node_type =3D=3D RDMA_NODE_IB_SWITCH) {
> diff --git a/drivers/infiniband/core/multicast.c b/drivers/infiniband/cor=
e/multicast.c
> index fa17b55..17573ff 100644
> --- a/drivers/infiniband/core/multicast.c
> +++ b/drivers/infiniband/core/multicast.c
> @@ -780,8 +780,7 @@ static void mcast_event_handler(struct ib_event_handl=
er *handler,
>      int index;
> =20
>      dev =3D container_of(handler, struct mcast_device, event_handler);
> -    if (rdma_port_get_link_layer(dev->device, event->element.port_num) !=
=3D
> -        IB_LINK_LAYER_INFINIBAND)
> +    if (!rdma_port_ll_is_ib(dev->device, event->element.port_num))
>          return;
> =20
>      index =3D event->element.port_num - dev->start_port;
> @@ -808,7 +807,7 @@ static void mcast_add_one(struct ib_device *device)
>      int i;
>      int count =3D 0;
> =20
> -    if (rdma_node_get_transport(device->node_type) !=3D RDMA_TRANSPORT_I=
B)
> +    if (!rdma_transport_is_ib(device))
>          return;
> =20
>      dev =3D kmalloc(sizeof *dev + device->phys_port_cnt * sizeof *port,
> @@ -824,8 +823,7 @@ static void mcast_add_one(struct ib_device *device)
>      }
> =20
>      for (i =3D 0; i <=3D dev->end_port - dev->start_port; i++) {
> -        if (rdma_port_get_link_layer(device, dev->start_port + i) !=3D
> -            IB_LINK_LAYER_INFINIBAND)
> +        if (!rdma_port_ll_is_ib(device, dev->start_port + i))
>              continue;
>          port =3D &dev->port[i];
>          port->dev =3D dev;
> @@ -863,8 +861,7 @@ static void mcast_remove_one(struct ib_device *device=
)
>      flush_workqueue(mcast_wq);
> =20
>      for (i =3D 0; i <=3D dev->end_port - dev->start_port; i++) {
> -        if (rdma_port_get_link_layer(device, dev->start_port + i) =3D=3D
> -            IB_LINK_LAYER_INFINIBAND) {
> +        if (rdma_port_ll_is_ib(device, dev->start_port + i)) {
>              port =3D &dev->port[i];
>              deref_port(port);
>              wait_for_completion(&port->comp);
> diff --git a/drivers/infiniband/core/sa_query.c b/drivers/infiniband/core=
/sa_query.c
> index c38f030..d95d25f 100644
> --- a/drivers/infiniband/core/sa_query.c
> +++ b/drivers/infiniband/core/sa_query.c
> @@ -450,7 +450,7 @@ static void ib_sa_event(struct ib_event_handler *hand=
ler, struct ib_event *event
>          struct ib_sa_port *port =3D
>              &sa_dev->port[event->element.port_num - sa_dev->start_port];
> =20
> -        if (rdma_port_get_link_layer(handler->device, port->port_num) !=
=3D IB_LINK_LAYER_INFINIBAND)
> +        if (!rdma_port_ll_is_ib(handler->device, port->port_num))
>              return;
> =20
>          spin_lock_irqsave(&port->ah_lock, flags);
> @@ -540,7 +540,7 @@ int ib_init_ah_from_path(struct ib_device *device, u8=
 port_num,
>      ah_attr->port_num =3D port_num;
>      ah_attr->static_rate =3D rec->rate;
> =20
> -    force_grh =3D rdma_port_get_link_layer(device, port_num) =3D=3D IB_L=
INK_LAYER_ETHERNET;
> +    force_grh =3D rdma_port_ll_is_eth(device, port_num);
> =20
>      if (rec->hop_limit > 1 || force_grh) {
>          ah_attr->ah_flags =3D IB_AH_GRH;
> @@ -1154,7 +1154,7 @@ static void ib_sa_add_one(struct ib_device *device)
>      struct ib_sa_device *sa_dev;
>      int s, e, i;
> =20
> -    if (rdma_node_get_transport(device->node_type) !=3D RDMA_TRANSPORT_I=
B)
> +    if (!rdma_transport_is_ib(device))
>          return;
> =20
>      if (device->node_type =3D=3D RDMA_NODE_IB_SWITCH)
> @@ -1175,7 +1175,7 @@ static void ib_sa_add_one(struct ib_device *device)
> =20
>      for (i =3D 0; i <=3D e - s; ++i) {
>          spin_lock_init(&sa_dev->port[i].ah_lock);
> -        if (rdma_port_get_link_layer(device, i + 1) !=3D IB_LINK_LAYER_I=
NFINIBAND)
> +        if (!rdma_port_ll_is_ib(device, i + 1))
>              continue;
> =20
>          sa_dev->port[i].sm_ah    =3D NULL;
> @@ -1205,14 +1205,14 @@ static void ib_sa_add_one(struct ib_device *devic=
e)
>          goto err;
> =20
>      for (i =3D 0; i <=3D e - s; ++i)
> -        if (rdma_port_get_link_layer(device, i + 1) =3D=3D IB_LINK_LAYER=
_INFINIBAND)
> +        if (rdma_port_ll_is_ib(device, i + 1))
>              update_sm_ah(&sa_dev->port[i].update_task);
> =20
>      return;
> =20
>  err:
>      while (--i >=3D 0)
> -        if (rdma_port_get_link_layer(device, i + 1) =3D=3D IB_LINK_LAYER=
_INFINIBAND)
> +        if (rdma_port_ll_is_ib(device, i + 1))
>              ib_unregister_mad_agent(sa_dev->port[i].agent);
> =20
>      kfree(sa_dev);
> @@ -1233,7 +1233,7 @@ static void ib_sa_remove_one(struct ib_device *devi=
ce)
>      flush_workqueue(ib_wq);
> =20
>      for (i =3D 0; i <=3D sa_dev->end_port - sa_dev->start_port; ++i) {
> -        if (rdma_port_get_link_layer(device, i + 1) =3D=3D IB_LINK_LAYER=
_INFINIBAND) {
> +        if (rdma_port_ll_is_ib(device, i + 1)) {
>              ib_unregister_mad_agent(sa_dev->port[i].agent);
>              if (sa_dev->port[i].sm_ah)
>                  kref_put(&sa_dev->port[i].sm_ah->ref, free_sm_ah);
> diff --git a/drivers/infiniband/core/ucm.c b/drivers/infiniband/core/ucm.=
c
> index f2f6393..ddbe0b4 100644
> --- a/drivers/infiniband/core/ucm.c
> +++ b/drivers/infiniband/core/ucm.c
> @@ -1253,8 +1253,7 @@ static void ib_ucm_add_one(struct ib_device *device=
)
>      dev_t base;
>      struct ib_ucm_device *ucm_dev;
> =20
> -    if (!device->alloc_ucontext ||
> -        rdma_node_get_transport(device->node_type) !=3D RDMA_TRANSPORT_I=
B)
> +    if (!device->alloc_ucontext || !rdma_transport_is_ib(device))
>          return;
> =20
>      ucm_dev =3D kzalloc(sizeof *ucm_dev, GFP_KERNEL);
> diff --git a/drivers/infiniband/core/user_mad.c b/drivers/infiniband/core=
/user_mad.c
> index 928cdd2..28a8b30 100644
> --- a/drivers/infiniband/core/user_mad.c
> +++ b/drivers/infiniband/core/user_mad.c
> @@ -1274,7 +1274,7 @@ static void ib_umad_add_one(struct ib_device *devic=
e)
>      struct ib_umad_device *umad_dev;
>      int s, e, i;
> =20
> -    if (rdma_node_get_transport(device->node_type) !=3D RDMA_TRANSPORT_I=
B)
> +    if (!rdma_transport_is_ib(device))
>          return;
> =20
>      if (device->node_type =3D=3D RDMA_NODE_IB_SWITCH)
> diff --git a/drivers/infiniband/core/verbs.c b/drivers/infiniband/core/ve=
rbs.c
> index f93eb8d..d8d015a 100644
> --- a/drivers/infiniband/core/verbs.c
> +++ b/drivers/infiniband/core/verbs.c
> @@ -198,8 +198,7 @@ int ib_init_ah_from_wc(struct ib_device *device, u8 p=
ort_num, struct ib_wc *wc,
>      u32 flow_class;
>      u16 gid_index;
>      int ret;
> -    int is_eth =3D (rdma_port_get_link_layer(device, port_num) =3D=3D
> -            IB_LINK_LAYER_ETHERNET);
> +    int is_eth =3D (rdma_port_ll_is_eth(device, port_num));
> =20
>      memset(ah_attr, 0, sizeof *ah_attr);
>      if (is_eth) {
> @@ -871,7 +870,7 @@ int ib_resolve_eth_l2_attrs(struct ib_qp *qp,
>      union ib_gid  sgid;
> =20
>      if ((*qp_attr_mask & IB_QP_AV)  &&
> -        (rdma_port_get_link_layer(qp->device, qp_attr->ah_attr.port_num)=
 =3D=3D IB_LINK_LAYER_ETHERNET)) {
> +        (rdma_port_ll_is_eth(qp->device, qp_attr->ah_attr.port_num))) {
>          ret =3D ib_query_gid(qp->device, qp_attr->ah_attr.port_num,
>                     qp_attr->ah_attr.grh.sgid_index, &sgid);
>          if (ret)
> diff --git a/drivers/infiniband/hw/mlx4/ah.c b/drivers/infiniband/hw/mlx4=
/ah.c
> index 2d8c339..829eb60 100644
> --- a/drivers/infiniband/hw/mlx4/ah.c
> +++ b/drivers/infiniband/hw/mlx4/ah.c
> @@ -118,7 +118,7 @@ struct ib_ah *mlx4_ib_create_ah(struct ib_pd *pd, str=
uct ib_ah_attr *ah_attr)
>      if (!ah)
>          return ERR_PTR(-ENOMEM);
> =20
> -    if (rdma_port_get_link_layer(pd->device, ah_attr->port_num) =3D=3D I=
B_LINK_LAYER_ETHERNET) {
> +    if (rdma_port_ll_is_eth(pd->device, ah_attr->port_num)) {
>          if (!(ah_attr->ah_flags & IB_AH_GRH)) {
>              ret =3D ERR_PTR(-EINVAL);
>          } else {
> diff --git a/drivers/infiniband/hw/mlx4/cq.c b/drivers/infiniband/hw/mlx4=
/cq.c
> index cb63ecd..0417f03 100644
> --- a/drivers/infiniband/hw/mlx4/cq.c
> +++ b/drivers/infiniband/hw/mlx4/cq.c
> @@ -789,9 +789,7 @@ repoll:
>              break;
>          }
> =20
> -        is_eth =3D (rdma_port_get_link_layer(wc->qp->device,
> -                          (*cur_qp)->port) =3D=3D
> -              IB_LINK_LAYER_ETHERNET);
> +        is_eth =3D (rdma_port_ll_is_eth(wc->qp->device, (*cur_qp)->port)=
);
>          if (mlx4_is_mfunc(to_mdev(cq->ibcq.device)->dev)) {
>              if ((*cur_qp)->mlx4_ib_qp_type &
>                  (MLX4_IB_QPT_PROXY_SMI_OWNER |
> diff --git a/drivers/infiniband/hw/mlx4/mad.c b/drivers/infiniband/hw/mlx=
4/mad.c
> index 82a7dd8..4736fc7 100644
> --- a/drivers/infiniband/hw/mlx4/mad.c
> +++ b/drivers/infiniband/hw/mlx4/mad.c
> @@ -606,12 +606,7 @@ static int mlx4_ib_demux_mad(struct ib_device *ibdev=
, u8 port,
>      int err;
>      int slave;
>      u8 *slave_id;
> -    int is_eth =3D 0;
> -
> -    if (rdma_port_get_link_layer(ibdev, port) =3D=3D IB_LINK_LAYER_INFIN=
IBAND)
> -        is_eth =3D 0;
> -    else
> -        is_eth =3D 1;
> +    int is_eth =3D rdma_port_ll_is_eth(ibdev, port);
> =20
>      if (is_eth) {
>          if (!(wc->wc_flags & IB_WC_GRH)) {
> @@ -1252,7 +1247,7 @@ out:
> =20
>  static int get_slave_base_gid_ix(struct mlx4_ib_dev *dev, int slave, int=
 port)
>  {
> -    if (rdma_port_get_link_layer(&dev->ib_dev, port) =3D=3D IB_LINK_LAYE=
R_INFINIBAND)
> +    if (rdma_port_ll_is_ib(&dev->ib_dev, port))
>          return slave;
>      return mlx4_get_base_gid_ix(dev->dev, slave, port);
>  }
> @@ -1260,7 +1255,7 @@ static int get_slave_base_gid_ix(struct mlx4_ib_dev=
 *dev, int slave, int port)
>  static void fill_in_real_sgid_index(struct mlx4_ib_dev *dev, int slave, =
int port,
>                      struct ib_ah_attr *ah_attr)
>  {
> -    if (rdma_port_get_link_layer(&dev->ib_dev, port) =3D=3D IB_LINK_LAYE=
R_INFINIBAND)
> +    if (rdma_port_ll_is_ib(&dev->ib_dev, port))
>          ah_attr->grh.sgid_index =3D slave;
>      else
>          ah_attr->grh.sgid_index +=3D get_slave_base_gid_ix(dev, slave, p=
ort);
> @@ -1758,8 +1753,7 @@ static int create_pv_resources(struct ib_device *ib=
dev, int slave, int port,
> =20
>      ctx->state =3D DEMUX_PV_STATE_STARTING;
>      /* have QP0 only if link layer is IB */
> -    if (rdma_port_get_link_layer(ibdev, ctx->port) =3D=3D
> -        IB_LINK_LAYER_INFINIBAND)
> +    if (rdma_port_ll_is_ib(ibdev, ctx->port))
>          ctx->has_smi =3D 1;
> =20
>      if (ctx->has_smi) {
> diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/ml=
x4/main.c
> index 0b280b1..f445f4c 100644
> --- a/drivers/infiniband/hw/mlx4/main.c
> +++ b/drivers/infiniband/hw/mlx4/main.c
> @@ -482,7 +482,7 @@ static int iboe_query_gid(struct ib_device *ibdev, u8=
 port, int index,
>  static int mlx4_ib_query_gid(struct ib_device *ibdev, u8 port, int index=
,
>                   union ib_gid *gid)
>  {
> -    if (rdma_port_get_link_layer(ibdev, port) =3D=3D IB_LINK_LAYER_INFIN=
IBAND)
> +    if (rdma_port_ll_is_ib(ibdev, port))
>          return __mlx4_ib_query_gid(ibdev, port, index, gid, 0);
>      else
>          return iboe_query_gid(ibdev, port, index, gid);
> @@ -1801,8 +1801,7 @@ static int mlx4_ib_init_gid_table(struct mlx4_ib_de=
v *ibdev)
>      int err =3D 0;
> =20
>      for (i =3D 1; i <=3D ibdev->num_ports; ++i) {
> -        if (rdma_port_get_link_layer(&ibdev->ib_dev, i) =3D=3D
> -            IB_LINK_LAYER_ETHERNET) {
> +        if (rdma_port_ll_is_eth(&ibdev->ib_dev, i)) {
>              err =3D reset_gid_table(ibdev, i);
>              if (err)
>                  goto out;
> @@ -2554,8 +2553,7 @@ static void mlx4_ib_event(struct mlx4_dev *dev, voi=
d *ibdev_ptr,
>          if (p > ibdev->num_ports)
>              return;
>          if (mlx4_is_master(dev) &&
> -            rdma_port_get_link_layer(&ibdev->ib_dev, p) =3D=3D
> -            IB_LINK_LAYER_INFINIBAND) {
> +            rdma_port_ll_is_ib(&ibdev->ib_dev, p)) {
>              mlx4_ib_invalidate_all_guid_record(ibdev, p);
>          }
>          ibev.event =3D IB_EVENT_PORT_ACTIVE;
> diff --git a/drivers/infiniband/hw/mlx4/mlx4_ib.h b/drivers/infiniband/hw=
/mlx4/mlx4_ib.h
> index 6eb743f..1befeb8 100644
> --- a/drivers/infiniband/hw/mlx4/mlx4_ib.h
> +++ b/drivers/infiniband/hw/mlx4/mlx4_ib.h
> @@ -712,7 +712,7 @@ static inline bool mlx4_ib_ah_grh_present(struct mlx4=
_ib_ah *ah)
>  {
>      u8 port =3D be32_to_cpu(ah->av.ib.port_pd) >> 24 & 3;
> =20
> -    if (rdma_port_get_link_layer(ah->ibah.device, port) =3D=3D IB_LINK_L=
AYER_ETHERNET)
> +    if (rdma_port_ll_is_eth(ah->ibah.device, port))
>          return true;
> =20
>      return !!(ah->av.ib.g_slid & 0x80);
> diff --git a/drivers/infiniband/hw/mlx4/qp.c b/drivers/infiniband/hw/mlx4=
/qp.c
> index c880329..bd2f557 100644
> --- a/drivers/infiniband/hw/mlx4/qp.c
> +++ b/drivers/infiniband/hw/mlx4/qp.c
> @@ -1248,8 +1248,7 @@ static int _mlx4_set_path(struct mlx4_ib_dev *dev, =
const struct ib_ah_attr *ah,
>                u64 smac, u16 vlan_tag, struct mlx4_qp_path *path,
>                struct mlx4_roce_smac_vlan_info *smac_info, u8 port)
>  {
> -    int is_eth =3D rdma_port_get_link_layer(&dev->ib_dev, port) =3D=3D
> -        IB_LINK_LAYER_ETHERNET;
> +    int is_eth =3D rdma_port_ll_is_eth(&dev->ib_dev, port);
>      int vidx;
>      int smac_index;
>      int err;
> @@ -1433,8 +1432,7 @@ static int __mlx4_ib_modify_qp(struct ib_qp *ibqp,
> =20
>      /* APM is not supported under RoCE */
>      if (attr_mask & IB_QP_ALT_PATH &&
> -        rdma_port_get_link_layer(&dev->ib_dev, qp->port) =3D=3D
> -        IB_LINK_LAYER_ETHERNET)
> +        rdma_port_ll_is_eth(&dev->ib_dev, qp->port))
>          return -ENOTSUPP;
> =20
>      context =3D kzalloc(sizeof *context, GFP_KERNEL);
> @@ -1664,8 +1662,7 @@ static int __mlx4_ib_modify_qp(struct ib_qp *ibqp,
>                  context->pri_path.fl =3D 0x80;
>              context->pri_path.sched_queue |=3D MLX4_IB_DEFAULT_SCHED_QUE=
UE;
>          }
> -        if (rdma_port_get_link_layer(&dev->ib_dev, qp->port) =3D=3D
> -            IB_LINK_LAYER_ETHERNET) {
> +        if (rdma_port_ll_is_eth(&dev->ib_dev, qp->port)) {
>              if (qp->mlx4_ib_qp_type =3D=3D MLX4_IB_QPT_TUN_GSI ||
>                  qp->mlx4_ib_qp_type =3D=3D MLX4_IB_QPT_GSI)
>                  context->pri_path.feup =3D 1 << 7; /* don't fsm */
> @@ -1695,9 +1692,7 @@ static int __mlx4_ib_modify_qp(struct ib_qp *ibqp,
>      }
> =20
>      if (ibqp->qp_type =3D=3D IB_QPT_UD && (new_state =3D=3D IB_QPS_RTR))=
 {
> -        int is_eth =3D rdma_port_get_link_layer(
> -                &dev->ib_dev, qp->port) =3D=3D
> -                IB_LINK_LAYER_ETHERNET;
> +        int is_eth =3D rdma_port_ll_is_eth(&dev->ib_dev, qp->port);
>          if (is_eth) {
>              context->pri_path.ackto =3D MLX4_IB_LINK_TYPE_ETH;
>              optpar |=3D MLX4_QP_OPTPAR_PRIMARY_ADDR_PATH;
> @@ -1927,8 +1922,7 @@ int mlx4_ib_modify_qp(struct ib_qp *ibqp, struct ib=
_qp_attr *attr,
>      }
> =20
>      if ((attr_mask & IB_QP_PORT) && (ibqp->qp_type =3D=3D IB_QPT_RAW_PAC=
KET) &&
> -        (rdma_port_get_link_layer(&dev->ib_dev, attr->port_num) !=3D
> -         IB_LINK_LAYER_ETHERNET))
> +        !rdma_port_ll_is_eth(&dev->ib_dev, attr->port_num))
>          goto out;
> =20
>      if (attr_mask & IB_QP_PKEY_INDEX) {
> @@ -2132,7 +2126,7 @@ static int build_mlx_header(struct mlx4_ib_sqp *sqp=
, struct ib_send_wr *wr,
>      for (i =3D 0; i < wr->num_sge; ++i)
>          send_size +=3D wr->sg_list[i].length;
> =20
> -    is_eth =3D rdma_port_get_link_layer(sqp->qp.ibqp.device, sqp->qp.por=
t) =3D=3D IB_LINK_LAYER_ETHERNET;
> +    is_eth =3D rdma_port_ll_is_eth(sqp->qp.ibqp.device, sqp->qp.port);
>      is_grh =3D mlx4_ib_ah_grh_present(ah);
>      if (is_eth) {
>          if (mlx4_is_mfunc(to_mdev(ib_dev)->dev)) {
> @@ -3029,8 +3023,7 @@ static void to_ib_ah_attr(struct mlx4_ib_dev *ibdev=
, struct ib_ah_attr *ib_ah_at
>      if (ib_ah_attr->port_num =3D=3D 0 || ib_ah_attr->port_num > dev->cap=
s.num_ports)
>          return;
> =20
> -    is_eth =3D rdma_port_get_link_layer(&ibdev->ib_dev, ib_ah_attr->port=
_num) =3D=3D
> -        IB_LINK_LAYER_ETHERNET;
> +    is_eth =3D rdma_port_ll_is_eth(&ibdev->ib_dev, ib_ah_attr->port_num)=
;
>      if (is_eth)
>          ib_ah_attr->sl =3D ((path->sched_queue >> 3) & 0x7) |
>          ((path->sched_queue & 4) << 1);
> diff --git a/drivers/infiniband/hw/mlx4/sysfs.c b/drivers/infiniband/hw/m=
lx4/sysfs.c
> index cb4c66e..d339b55 100644
> --- a/drivers/infiniband/hw/mlx4/sysfs.c
> +++ b/drivers/infiniband/hw/mlx4/sysfs.c
> @@ -610,8 +610,7 @@ static ssize_t sysfs_store_enable_smi_admin(struct de=
vice *dev,
> =20
>  static int add_vf_smi_entries(struct mlx4_port *p)
>  {
> -    int is_eth =3D rdma_port_get_link_layer(&p->dev->ib_dev, p->port_num=
) =3D=3D
> -            IB_LINK_LAYER_ETHERNET;
> +    int is_eth =3D rdma_port_ll_is_eth(&p->dev->ib_dev, p->port_num);
>      int ret;
> =20
>      /* do not display entries if eth transport, or if master */
> @@ -645,8 +644,7 @@ static int add_vf_smi_entries(struct mlx4_port *p)
> =20
>  static void remove_vf_smi_entries(struct mlx4_port *p)
>  {
> -    int is_eth =3D rdma_port_get_link_layer(&p->dev->ib_dev, p->port_num=
) =3D=3D
> -            IB_LINK_LAYER_ETHERNET;
> +    int is_eth =3D rdma_port_ll_is_eth(&p->dev->ib_dev, p->port_num);
> =20
>      if (is_eth || p->slave =3D=3D mlx4_master_func_num(p->dev->dev))
>          return;
> diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniba=
nd/ulp/ipoib/ipoib_main.c
> index 58b5aa3..3341754 100644
> --- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
> +++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
> @@ -1655,7 +1655,7 @@ static void ipoib_add_one(struct ib_device *device)
>      struct ipoib_dev_priv *priv;
>      int s, e, p;
> =20
> -    if (rdma_node_get_transport(device->node_type) !=3D RDMA_TRANSPORT_I=
B)
> +    if (!rdma_transport_is_ib(device))
>          return;
> =20
>      dev_list =3D kmalloc(sizeof *dev_list, GFP_KERNEL);
> @@ -1673,7 +1673,7 @@ static void ipoib_add_one(struct ib_device *device)
>      }
> =20
>      for (p =3D s; p <=3D e; ++p) {
> -        if (rdma_port_get_link_layer(device, p) !=3D IB_LINK_LAYER_INFIN=
IBAND)
> +        if (!rdma_port_ll_is_ib(device, p))
>              continue;
>          dev =3D ipoib_add_port("ib%d", device, p);
>          if (!IS_ERR(dev)) {
> @@ -1690,7 +1690,7 @@ static void ipoib_remove_one(struct ib_device *devi=
ce)
>      struct ipoib_dev_priv *priv, *tmp;
>      struct list_head *dev_list;
> =20
> -    if (rdma_node_get_transport(device->node_type) !=3D RDMA_TRANSPORT_I=
B)
> +    if (!rdma_transport_is_ib(device))
>          return;
> =20
>      dev_list =3D ib_get_client_data(device, &ipoib_client);
> diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
> index 65994a1..2bf9094 100644
> --- a/include/rdma/ib_verbs.h
> +++ b/include/rdma/ib_verbs.h
> @@ -1743,6 +1743,30 @@ int ib_query_port(struct ib_device *device,
>  enum rdma_link_layer rdma_port_get_link_layer(struct ib_device *device,
>                             u8 port_num);
> =20
> +static inline int rdma_transport_is_ib(struct ib_device *device)
> +{
> +    return rdma_node_get_transport(device->node_type)
> +            =3D=3D RDMA_TRANSPORT_IB;
> +}
> +
> +static inline int rdma_transport_is_iwarp(struct ib_device *device)
> +{
> +    return rdma_node_get_transport(device->node_type)
> +            =3D=3D RDMA_TRANSPORT_IWARP;
> +}
> +
> +static inline int rdma_port_ll_is_ib(struct ib_device *device, u8 port_n=
um)
> +{
> +    return rdma_port_get_link_layer(device, port_num)
> +            =3D=3D IB_LINK_LAYER_INFINIBAND;
> +}
> +
> +static inline int rdma_port_ll_is_eth(struct ib_device *device, u8 port_=
num)
> +{
> +    return rdma_port_get_link_layer(device, port_num)
> +            =3D=3D IB_LINK_LAYER_ETHERNET;
> +}
> +
>  int ib_query_gid(struct ib_device *device,
>           u8 port_num, int index, union ib_gid *gid);
> =20
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdm=
a/svc_rdma_recvfrom.c
> index e011027..a7b5891 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> @@ -118,8 +118,7 @@ static void rdma_build_arg_xdr(struct svc_rqst *rqstp=
,
> =20
>  static int rdma_read_max_sge(struct svcxprt_rdma *xprt, int sge_count)
>  {
> -    if (rdma_node_get_transport(xprt->sc_cm_id->device->node_type) =3D=
=3D
> -         RDMA_TRANSPORT_IWARP)
> +    if (rdma_transport_is_iwarp(xprt->sc_cm_id->device))
>          return 1;
>      else
>          return min_t(int, sge_count, xprt->sc_max_sge);


--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--=-/32TPje5lUuKe37tEZG2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABAgAGBQJVGXIUAAoJELgmozMOVy/dY58QAI8hRuY4ZsLWpBi0ldrLvYS9
xK7E4JJpJaYIN4cRYIU02zUbt11FXFzitdX/MjykFYdpoCT38LZe22JTMBjLhxy3
AkBuTw7dztECNR+fc+MuTxJEbZSy1LDcFEnZe0ViVLXeULoR45gEvWwtZSoBJYJD
07ljYTaQw7Mt2c1W/4ZF7wREmt/hOWyWdMCh6C5pshLwK6UhHIHqssFP64X7/Veq
Psf3vPhF8P+iHH7JRC4aEYDfiWvUTLxZwm3yk3sCZFTPcdUdOWpnrhEweMlPgJHV
yVQgopwZr64OzAYMHQbKw8ZeeYbWyaSOKgj8QeOge4rmnqlYSB8ITDq9qAITu1Ut
faSoI1QsK64NQU+fItsOv6/1ThtUwa8WK992vOHHylskxvuUNTxoIqjDXmzxim/e
Z4ZwCNZ8ChH7vlvLm0sjg+5YTLFAlwYZByYnMa+U6ed8uJn65NAXhrKNUixFx4Ml
oBILIOAjlKmFPjON/uFWwZBcXkOsymw80sozp9VLDlBSpiZ9QpZEaxaHmZpxtLgW
8Q18SnjPSa1ei7ESIf86d4DiMcttaSJaRKMSBnLpyOXkKKVEwIh+8njQD6UPWZdH
QK1DCrR3hFttpix+B8VBJR8XTpcX8I0XSWdSx1rWr92dSSKIgWCP6E+w2xektBrW
lOwof/7y3EEK1BRcf+ru
=p9cO
-----END PGP SIGNATURE-----

--=-/32TPje5lUuKe37tEZG2--

