From: "Sean Hefty" <sean.hefty@intel.com>
Subject: [PATCH 6/26] rdma/cm: specify QP type when creating an ID
Date: Thu, 1 Apr 2010 10:08:41 -0700
Message-ID: <19E562321C414D42982C72BE33CFC6E5@amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
To: <linux-rdma@vger.kernel.org>,
	"'Andy Grover'" <andy.grover@oracle.com>, <bfields@fieldses.org>,
	<neilb@suse.de>, <linux-nfs@vger.kernel.org>,
	<v9fs-developer@lists.sourceforge.net>, <
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:29521 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754336Ab0DARI7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Apr 2010 13:08:59 -0400
References: 
In-Reply-To: 
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rdma/cm: specify QP type when creating an ID

From: Sean Hefty <sean.hefty@intel.com>

The rdma_cm infers the QP type from the port space selected by the
user.  In order to support RDMA_PS_IB, we need to know which
QP type the user intends to support in order to perform the
correction operation, such as sending a REQ versus SIDR.

Modify rdma_create_id to allow the user to specify the QP type,
and use it to make our selections of datagram versus connected
mode.

Signed-off-by: Sean Hefty <sean.hefty@intel.com>
---

 drivers/infiniband/core/cma.c            |   35 ++++++++++++++----------------
 drivers/infiniband/core/ucma.c           |   27 ++++++++++++++++++++---
 drivers/infiniband/ulp/iser/iser_verbs.c |    2 +-
 include/rdma/rdma_cm.h                   |    5 +++-
 net/9p/trans_rdma.c                      |    3 ++-
 net/rds/ib.c                             |    2 +-
 net/rds/ib_cm.c                          |    2 +-
 net/rds/iw.c                             |    2 +-
 net/rds/iw_cm.c                          |    2 +-
 net/rds/rdma_transport.c                 |    3 ++-
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    3 ++-
 net/sunrpc/xprtrdma/verbs.c              |    2 +-
 12 files changed, 55 insertions(+), 33 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 1328a8e..ccf47c6 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -271,11 +271,6 @@ static inline void sdp_set_ip_ver(struct sdp_hh *hh, u8 ip_ver)
 	hh->ip_version = (ip_ver << 4) | (hh->ip_version & 0xF);
 }
 
-static inline int cma_is_ud_ps(enum rdma_port_space ps)
-{
-	return (ps == RDMA_PS_UDP || ps == RDMA_PS_IPOIB);
-}
-
 static void cma_attach_to_dev(struct rdma_id_private *id_priv,
 			      struct cma_device *cma_dev)
 {
@@ -366,7 +361,8 @@ static int cma_has_cm_dev(struct rdma_id_private *id_priv)
 }
 
 struct rdma_cm_id *rdma_create_id(rdma_cm_event_handler event_handler,
-				  void *context, enum rdma_port_space ps)
+				  void *context, enum rdma_port_space ps,
+				  enum ib_qp_type qp_type)
 {
 	struct rdma_id_private *id_priv;
 
@@ -378,6 +374,7 @@ struct rdma_cm_id *rdma_create_id(rdma_cm_event_handler event_handler,
 	id_priv->id.context = context;
 	id_priv->id.event_handler = event_handler;
 	id_priv->id.ps = ps;
+	id_priv->id.qp_type = qp_type;
 	spin_lock_init(&id_priv->lock);
 	mutex_init(&id_priv->qp_mutex);
 	init_completion(&id_priv->comp);
@@ -445,7 +442,7 @@ int rdma_create_qp(struct rdma_cm_id *id, struct ib_pd *pd,
 	if (IS_ERR(qp))
 		return PTR_ERR(qp);
 
-	if (cma_is_ud_ps(id_priv->id.ps))
+	if (id->qp_type == IB_QPT_UD)
 		ret = cma_init_ud_qp(id_priv, qp);
 	else
 		ret = cma_init_conn_qp(id_priv, qp);
@@ -567,7 +564,7 @@ static int cma_ib_init_qp_attr(struct rdma_id_private *id_priv,
 	qp_attr->port_num = id_priv->id.port_num;
 	*qp_attr_mask = IB_QP_STATE | IB_QP_PKEY_INDEX | IB_QP_PORT;
 
-	if (cma_is_ud_ps(id_priv->id.ps)) {
+	if (id_priv->id.qp_type == IB_QPT_UD) {
 		ret = cma_set_qkey(id_priv);
 		if (ret)
 			return ret;
@@ -590,7 +587,7 @@ int rdma_init_qp_attr(struct rdma_cm_id *id, struct ib_qp_attr *qp_attr,
 	id_priv = container_of(id, struct rdma_id_private, id);
 	switch (rdma_node_get_transport(id_priv->id.device->node_type)) {
 	case RDMA_TRANSPORT_IB:
-		if (!id_priv->cm_id.ib || cma_is_ud_ps(id_priv->id.ps))
+		if (!id_priv->cm_id.ib || (id_priv->id.qp_type == IB_QPT_UD))
 			ret = cma_ib_init_qp_attr(id_priv, qp_attr, qp_attr_mask);
 		else
 			ret = ib_cm_init_qp_attr(id_priv->cm_id.ib, qp_attr,
@@ -1035,7 +1032,7 @@ static struct rdma_id_private *cma_new_conn_id(struct rdma_cm_id *listen_id,
 		goto err;
 
 	id = rdma_create_id(listen_id->event_handler, listen_id->context,
-			    listen_id->ps);
+			    listen_id->ps, ib_event->param.req_rcvd.qp_type);
 	if (IS_ERR(id))
 		goto err;
 
@@ -1086,7 +1083,7 @@ static struct rdma_id_private *cma_new_udp_id(struct rdma_cm_id *listen_id,
 	int ret;
 
 	id = rdma_create_id(listen_id->event_handler, listen_id->context,
-			    listen_id->ps);
+			    listen_id->ps, IB_QPT_UD);
 	if (IS_ERR(id))
 		return NULL;
 
@@ -1141,7 +1138,7 @@ static int cma_req_handler(struct ib_cm_id *cm_id, struct ib_cm_event *ib_event)
 	memset(&event, 0, sizeof event);
 	offset = cma_user_data_offset(listen_id->id.ps);
 	event.event = RDMA_CM_EVENT_CONNECT_REQUEST;
-	if (cma_is_ud_ps(listen_id->id.ps)) {
+	if (listen_id->id.qp_type == IB_QPT_UD) {
 		conn_id = cma_new_udp_id(&listen_id->id, ib_event);
 		event.param.ud.private_data = ib_event->private_data + offset;
 		event.param.ud.private_data_len =
@@ -1174,8 +1171,7 @@ static int cma_req_handler(struct ib_cm_id *cm_id, struct ib_cm_event *ib_event)
 		 * while we're accessing the cm_id.
 		 */
 		mutex_lock(&lock);
-		if (cma_comp(conn_id, CMA_CONNECT) &&
-		    !cma_is_ud_ps(conn_id->id.ps))
+		if (cma_comp(conn_id, CMA_CONNECT) && (conn_id->id.qp_type != IB_QPT_UD))
 			ib_send_cm_mra(cm_id, CMA_CM_MRA_SETTING, NULL, 0);
 		mutex_unlock(&lock);
 		mutex_unlock(&conn_id->handler_mutex);
@@ -1328,7 +1324,7 @@ static int iw_conn_req_handler(struct iw_cm_id *cm_id,
 	/* Create a new RDMA id for the new IW CM ID */
 	new_cm_id = rdma_create_id(listen_id->id.event_handler,
 				   listen_id->id.context,
-				   RDMA_PS_TCP);
+				   RDMA_PS_TCP, IB_QPT_RC);
 	if (IS_ERR(new_cm_id)) {
 		ret = -ENOMEM;
 		goto out;
@@ -1471,7 +1467,8 @@ static void cma_listen_on_dev(struct rdma_id_private *id_priv,
 	struct rdma_cm_id *id;
 	int ret;
 
-	id = rdma_create_id(cma_listen_handler, id_priv, id_priv->id.ps);
+	id = rdma_create_id(cma_listen_handler, id_priv, id_priv->id.ps,
+			    id_priv->id.qp_type);
 	if (IS_ERR(id))
 		return;
 
@@ -2510,7 +2507,7 @@ int rdma_connect(struct rdma_cm_id *id, struct rdma_conn_param *conn_param)
 
 	switch (rdma_node_get_transport(id->device->node_type)) {
 	case RDMA_TRANSPORT_IB:
-		if (cma_is_ud_ps(id->ps))
+		if (id->qp_type == IB_QPT_UD)
 			ret = cma_resolve_ib_udp(id_priv, conn_param);
 		else
 			ret = cma_connect_ib(id_priv, conn_param);
@@ -2623,7 +2620,7 @@ int rdma_accept(struct rdma_cm_id *id, struct rdma_conn_param *conn_param)
 
 	switch (rdma_node_get_transport(id->device->node_type)) {
 	case RDMA_TRANSPORT_IB:
-		if (cma_is_ud_ps(id->ps))
+		if (id->qp_type == IB_QPT_UD)
 			ret = cma_send_sidr_rep(id_priv, IB_SIDR_SUCCESS,
 						conn_param->private_data,
 						conn_param->private_data_len);
@@ -2684,7 +2681,7 @@ int rdma_reject(struct rdma_cm_id *id, const void *private_data,
 
 	switch (rdma_node_get_transport(id->device->node_type)) {
 	case RDMA_TRANSPORT_IB:
-		if (cma_is_ud_ps(id->ps))
+		if (id->qp_type == IB_QPT_UD)
 			ret = cma_send_sidr_rep(id_priv, IB_SIDR_REJECT,
 						private_data, private_data_len);
 		else
diff --git a/drivers/infiniband/core/ucma.c b/drivers/infiniband/core/ucma.c
index b2e16c3..9feb18b 100644
--- a/drivers/infiniband/core/ucma.c
+++ b/drivers/infiniband/core/ucma.c
@@ -349,13 +349,28 @@ done:
 	return ret;
 }
 
-static ssize_t ucma_create_id(struct ucma_file *file,
-				const char __user *inbuf,
-				int in_len, int out_len)
+static int ucma_get_qp_type(struct rdma_ucm_create_id *cmd, enum ib_qp_type *qp_type)
+{
+	switch (cmd->ps) {
+	case RDMA_PS_TCP:
+		*qp_type = IB_QPT_RC;
+		return 0;
+	case RDMA_PS_UDP:
+	case RDMA_PS_IPOIB:
+		*qp_type = IB_QPT_UD;
+		return 0;
+	default:
+		return -EINVAL;
+	}
+}
+
+static ssize_t ucma_create_id(struct ucma_file *file, const char __user *inbuf,
+			      int in_len, int out_len)
 {
 	struct rdma_ucm_create_id cmd;
 	struct rdma_ucm_create_id_resp resp;
 	struct ucma_context *ctx;
+	enum ib_qp_type qp_type;
 	int ret;
 
 	if (out_len < sizeof(resp))
@@ -364,6 +379,10 @@ static ssize_t ucma_create_id(struct ucma_file *file,
 	if (copy_from_user(&cmd, inbuf, sizeof(cmd)))
 		return -EFAULT;
 
+	ret = ucma_get_qp_type(&cmd, &qp_type);
+	if (ret)
+		return ret;
+
 	mutex_lock(&file->mut);
 	ctx = ucma_alloc_ctx(file);
 	mutex_unlock(&file->mut);
@@ -371,7 +390,7 @@ static ssize_t ucma_create_id(struct ucma_file *file,
 		return -ENOMEM;
 
 	ctx->uid = cmd.uid;
-	ctx->cm_id = rdma_create_id(ucma_event_handler, ctx, cmd.ps);
+	ctx->cm_id = rdma_create_id(ucma_event_handler, ctx, cmd.ps, qp_type);
 	if (IS_ERR(ctx->cm_id)) {
 		ret = PTR_ERR(ctx->cm_id);
 		goto err1;
diff --git a/drivers/infiniband/ulp/iser/iser_verbs.c b/drivers/infiniband/ulp/iser/iser_verbs.c
index 8579f32..5b8411b 100644
--- a/drivers/infiniband/ulp/iser/iser_verbs.c
+++ b/drivers/infiniband/ulp/iser/iser_verbs.c
@@ -522,7 +522,7 @@ int iser_connect(struct iser_conn   *ib_conn,
 
 	ib_conn->cma_id = rdma_create_id(iser_cma_handler,
 					     (void *)ib_conn,
-					     RDMA_PS_TCP);
+					     RDMA_PS_TCP, IB_QPT_RC);
 	if (IS_ERR(ib_conn->cma_id)) {
 		err = PTR_ERR(ib_conn->cma_id);
 		iser_err("rdma_create_id failed: %d\n", err);
diff --git a/include/rdma/rdma_cm.h b/include/rdma/rdma_cm.h
index 8c27b6e..68e73d1 100644
--- a/include/rdma/rdma_cm.h
+++ b/include/rdma/rdma_cm.h
@@ -137,6 +137,7 @@ struct rdma_cm_id {
 	rdma_cm_event_handler	 event_handler;
 	struct rdma_route	 route;
 	enum rdma_port_space	 ps;
+	enum ib_qp_type		 qp_type;
 	u8			 port_num;
 };
 
@@ -147,9 +148,11 @@ struct rdma_cm_id {
  *   returned rdma_id.
  * @context: User specified context associated with the id.
  * @ps: RDMA port space.
+ * @qp_type: type of queue pair associated with the id.
  */
 struct rdma_cm_id *rdma_create_id(rdma_cm_event_handler event_handler,
-				  void *context, enum rdma_port_space ps);
+				  void *context, enum rdma_port_space ps,
+				  enum ib_qp_type qp_type);
 
 /**
   * rdma_destroy_id - Destroys an RDMA identifier.
diff --git a/net/9p/trans_rdma.c b/net/9p/trans_rdma.c
index 2c95a89..34e89f8 100644
--- a/net/9p/trans_rdma.c
+++ b/net/9p/trans_rdma.c
@@ -585,7 +585,8 @@ rdma_create_trans(struct p9_client *client, const char *addr, char *args)
 		return -ENOMEM;
 
 	/* Create the RDMA CM ID */
-	rdma->cm_id = rdma_create_id(p9_cm_event_handler, client, RDMA_PS_TCP);
+	rdma->cm_id = rdma_create_id(p9_cm_event_handler, client, RDMA_PS_TCP,
+				     IB_QPT_RC);
 	if (IS_ERR(rdma->cm_id))
 		goto error;
 
diff --git a/net/rds/ib.c b/net/rds/ib.c
index 3b89923..a6b3925 100644
--- a/net/rds/ib.c
+++ b/net/rds/ib.c
@@ -223,7 +223,7 @@ static int rds_ib_laddr_check(__be32 addr)
 	/* Create a CMA ID and try to bind it. This catches both
 	 * IB and iWARP capable NICs.
 	 */
-	cm_id = rdma_create_id(NULL, NULL, RDMA_PS_TCP);
+	cm_id = rdma_create_id(NULL, NULL, RDMA_PS_TCP, IB_QPT_RC);
 	if (IS_ERR(cm_id))
 		return PTR_ERR(cm_id);
 
diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 647cb8f..c8d4343 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -539,7 +539,7 @@ int rds_ib_conn_connect(struct rds_connection *conn)
 	/* XXX I wonder what affect the port space has */
 	/* delegate cm event handler to rdma_transport */
 	ic->i_cm_id = rdma_create_id(rds_rdma_cm_event_handler, conn,
-				     RDMA_PS_TCP);
+				     RDMA_PS_TCP, IB_QPT_RC);
 	if (IS_ERR(ic->i_cm_id)) {
 		ret = PTR_ERR(ic->i_cm_id);
 		ic->i_cm_id = NULL;
diff --git a/net/rds/iw.c b/net/rds/iw.c
index b28fa85..bcce00e 100644
--- a/net/rds/iw.c
+++ b/net/rds/iw.c
@@ -225,7 +225,7 @@ static int rds_iw_laddr_check(__be32 addr)
 	/* Create a CMA ID and try to bind it. This catches both
 	 * IB and iWARP capable NICs.
 	 */
-	cm_id = rdma_create_id(NULL, NULL, RDMA_PS_TCP);
+	cm_id = rdma_create_id(NULL, NULL, RDMA_PS_TCP, IB_QPT_RC);
 	if (IS_ERR(cm_id))
 		return PTR_ERR(cm_id);
 
diff --git a/net/rds/iw_cm.c b/net/rds/iw_cm.c
index 394cf6b..d05cfad 100644
--- a/net/rds/iw_cm.c
+++ b/net/rds/iw_cm.c
@@ -518,7 +518,7 @@ int rds_iw_conn_connect(struct rds_connection *conn)
 	/* XXX I wonder what affect the port space has */
 	/* delegate cm event handler to rdma_transport */
 	ic->i_cm_id = rdma_create_id(rds_rdma_cm_event_handler, conn,
-				     RDMA_PS_TCP);
+				     RDMA_PS_TCP, IB_QPT_RC);
 	if (IS_ERR(ic->i_cm_id)) {
 		ret = PTR_ERR(ic->i_cm_id);
 		ic->i_cm_id = NULL;
diff --git a/net/rds/rdma_transport.c b/net/rds/rdma_transport.c
index 9ece910..e55bf7d 100644
--- a/net/rds/rdma_transport.c
+++ b/net/rds/rdma_transport.c
@@ -129,7 +129,8 @@ static int __init rds_rdma_listen_init(void)
 	struct rdma_cm_id *cm_id;
 	int ret;
 
-	cm_id = rdma_create_id(rds_rdma_cm_event_handler, NULL, RDMA_PS_TCP);
+	cm_id = rdma_create_id(rds_rdma_cm_event_handler, NULL, RDMA_PS_TCP,
+			       IB_QPT_RC);
 	if (IS_ERR(cm_id)) {
 		ret = PTR_ERR(cm_id);
 		printk(KERN_ERR "RDS/RDMA: failed to setup listener, "
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 3fa5751..963b269 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -684,7 +684,8 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
 		return ERR_PTR(-ENOMEM);
 	xprt = &cma_xprt->sc_xprt;
 
-	listen_id = rdma_create_id(rdma_listen_handler, cma_xprt, RDMA_PS_TCP);
+	listen_id = rdma_create_id(rdma_listen_handler, cma_xprt, RDMA_PS_TCP,
+				   IB_QPT_RC);
 	if (IS_ERR(listen_id)) {
 		ret = PTR_ERR(listen_id);
 		dprintk("svcrdma: rdma_create_id failed = %d\n", ret);
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 2209aa8..bb271be 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -377,7 +377,7 @@ rpcrdma_create_id(struct rpcrdma_xprt *xprt,
 
 	init_completion(&ia->ri_done);
 
-	id = rdma_create_id(rpcrdma_conn_upcall, xprt, RDMA_PS_TCP);
+	id = rdma_create_id(rpcrdma_conn_upcall, xprt, RDMA_PS_TCP, IB_QPT_RC);
 	if (IS_ERR(id)) {
 		rc = PTR_ERR(id);
 		dprintk("RPC:       %s: rdma_create_id() failed %i\n",



