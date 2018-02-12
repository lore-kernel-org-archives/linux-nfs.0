Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:52656 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753825AbeBLTAZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 12 Feb 2018 14:00:25 -0500
From: Denys Vlasenko <dvlasenk@redhat.com>
To: "David S . Miller" <davem@davemloft.net>
Cc: Denys Vlasenko <dvlasenk@redhat.com>, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org,
        linux-decnet-user@lists.sourceforge.net,
        linux-wireless@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-sctp@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-x25@vger.kernel.org
Subject: [PATCH v2] net: make getname() functions return length rather than use int* parameter
Date: Mon, 12 Feb 2018 20:00:20 +0100
Message-Id: <20180212190020.21536-1-dvlasenk@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Changes since v1:
Added changes in these files:
    drivers/infiniband/hw/usnic/usnic_transport.c
    drivers/staging/lustre/lnet/lnet/lib-socket.c
    drivers/target/iscsi/iscsi_target_login.c
    drivers/vhost/net.c
    fs/dlm/lowcomms.c
    fs/ocfs2/cluster/tcp.c
    security/tomoyo/network.c


Before:
All these functions either return a negative error indicator,
or store length of sockaddr into "int *socklen" parameter
and return zero on success.

"int *socklen" parameter is awkward. For example, if caller does not
care, it still needs to provide on-stack storage for the value
it does not need.

None of the many FOO_getname() functions of various protocols
ever used old value of *socklen. They always just overwrite it.

This change drops this parameter, and makes all these functions, on success,
return length of sockaddr. It's always >= 0 and can be differentiated
from an error.

Tests in callers are changed from "if (err)" to "if (err < 0)", where needed.

rpc_sockname() lost "int buflen" parameter, since its only use was
to be passed to kernel_getsockname() as &buflen and subsequently
not used in any way.

Userspace API is not changed.

    text    data     bss      dec     hex filename
30108430 2633624  873672 33615726 200ef6e vmlinux.before.o
30108109 2633612  873672 33615393 200ee21 vmlinux.o

Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
CC: David S. Miller <davem@davemloft.net>
CC: linux-kernel@vger.kernel.org
CC: netdev@vger.kernel.org
CC: linux-bluetooth@vger.kernel.org
CC: linux-decnet-user@lists.sourceforge.net
CC: linux-wireless@vger.kernel.org
CC: linux-rdma@vger.kernel.org
CC: linux-sctp@vger.kernel.org
CC: linux-nfs@vger.kernel.org
CC: linux-x25@vger.kernel.org
---
 drivers/infiniband/hw/usnic/usnic_transport.c |  5 ++--
 drivers/isdn/mISDN/socket.c                   |  5 ++--
 drivers/net/ppp/pppoe.c                       |  6 ++---
 drivers/net/ppp/pptp.c                        |  6 ++---
 drivers/scsi/iscsi_tcp.c                      | 14 +++++------
 drivers/soc/qcom/qmi_interface.c              |  3 +--
 drivers/staging/ipx/af_ipx.c                  |  6 ++---
 drivers/staging/irda/net/af_irda.c            |  8 +++---
 drivers/staging/lustre/lnet/lnet/lib-socket.c |  7 +++---
 drivers/target/iscsi/iscsi_target_login.c     | 18 +++++++-------
 drivers/vhost/net.c                           |  7 +++---
 fs/dlm/lowcomms.c                             |  7 +++---
 fs/ocfs2/cluster/tcp.c                        |  6 ++---
 include/linux/net.h                           |  8 +++---
 include/net/inet_common.h                     |  2 +-
 include/net/ipv6.h                            |  2 +-
 include/net/sock.h                            |  2 +-
 net/appletalk/ddp.c                           |  5 ++--
 net/atm/pvc.c                                 |  5 ++--
 net/atm/svc.c                                 |  5 ++--
 net/ax25/af_ax25.c                            |  4 +--
 net/bluetooth/hci_sock.c                      |  4 +--
 net/bluetooth/l2cap_sock.c                    |  5 ++--
 net/bluetooth/rfcomm/sock.c                   |  5 ++--
 net/bluetooth/sco.c                           |  5 ++--
 net/can/raw.c                                 |  6 ++---
 net/core/sock.c                               |  5 ++--
 net/decnet/af_decnet.c                        |  6 ++---
 net/ipv4/af_inet.c                            |  5 ++--
 net/ipv6/af_inet6.c                           |  5 ++--
 net/iucv/af_iucv.c                            |  5 ++--
 net/l2tp/l2tp_ip.c                            |  5 ++--
 net/l2tp/l2tp_ip6.c                           |  5 ++--
 net/l2tp/l2tp_ppp.c                           |  5 ++--
 net/llc/af_llc.c                              |  5 ++--
 net/netlink/af_netlink.c                      |  5 ++--
 net/netrom/af_netrom.c                        |  9 ++++---
 net/nfc/llcp_sock.c                           |  5 ++--
 net/packet/af_packet.c                        | 10 +++-----
 net/phonet/socket.c                           |  5 ++--
 net/qrtr/qrtr.c                               |  5 ++--
 net/rds/af_rds.c                              |  5 ++--
 net/rds/tcp.c                                 |  7 ++----
 net/rose/af_rose.c                            |  5 ++--
 net/sctp/ipv6.c                               |  8 +++---
 net/smc/af_smc.c                              | 11 ++++-----
 net/socket.c                                  | 35 +++++++++++++--------------
 net/sunrpc/clnt.c                             |  6 ++---
 net/sunrpc/svcsock.c                          | 13 ++++++----
 net/sunrpc/xprtsock.c                         |  3 +--
 net/tipc/socket.c                             |  5 ++--
 net/unix/af_unix.c                            | 10 ++++----
 net/vmw_vsock/af_vsock.c                      |  4 +--
 net/x25/af_x25.c                              |  4 +--
 security/tomoyo/network.c                     |  5 ++--
 55 files changed, 159 insertions(+), 203 deletions(-)

diff --git a/drivers/infiniband/hw/usnic/usnic_transport.c b/drivers/infiniband/hw/usnic/usnic_transport.c
index de318389a301..67de94343cb4 100644
--- a/drivers/infiniband/hw/usnic/usnic_transport.c
+++ b/drivers/infiniband/hw/usnic/usnic_transport.c
@@ -174,14 +174,13 @@ void usnic_transport_put_socket(struct socket *sock)
 int usnic_transport_sock_get_addr(struct socket *sock, int *proto,
 					uint32_t *addr, uint16_t *port)
 {
-	int len;
 	int err;
 	struct sockaddr_in sock_addr;
 
 	err = sock->ops->getname(sock,
 				(struct sockaddr *)&sock_addr,
-				&len, 0);
-	if (err)
+				0);
+	if (err < 0)
 		return err;
 
 	if (sock_addr.sin_family != AF_INET)
diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
index c5603d1a07d6..1f8f489b4167 100644
--- a/drivers/isdn/mISDN/socket.c
+++ b/drivers/isdn/mISDN/socket.c
@@ -560,7 +560,7 @@ data_sock_bind(struct socket *sock, struct sockaddr *addr, int addr_len)
 
 static int
 data_sock_getname(struct socket *sock, struct sockaddr *addr,
-		  int *addr_len, int peer)
+		  int peer)
 {
 	struct sockaddr_mISDN	*maddr = (struct sockaddr_mISDN *) addr;
 	struct sock		*sk = sock->sk;
@@ -570,14 +570,13 @@ data_sock_getname(struct socket *sock, struct sockaddr *addr,
 
 	lock_sock(sk);
 
-	*addr_len = sizeof(*maddr);
 	maddr->family = AF_ISDN;
 	maddr->dev = _pms(sk)->dev->id;
 	maddr->channel = _pms(sk)->ch.nr;
 	maddr->sapi = _pms(sk)->ch.addr & 0xff;
 	maddr->tei = (_pms(sk)->ch.addr >> 8) & 0xff;
 	release_sock(sk);
-	return 0;
+	return sizeof(*maddr);
 }
 
 static const struct proto_ops data_sock_ops = {
diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
index 5aa59f41bf8c..bd89d1c559ce 100644
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -714,7 +714,7 @@ static int pppoe_connect(struct socket *sock, struct sockaddr *uservaddr,
 }
 
 static int pppoe_getname(struct socket *sock, struct sockaddr *uaddr,
-		  int *usockaddr_len, int peer)
+		  int peer)
 {
 	int len = sizeof(struct sockaddr_pppox);
 	struct sockaddr_pppox sp;
@@ -726,9 +726,7 @@ static int pppoe_getname(struct socket *sock, struct sockaddr *uaddr,
 
 	memcpy(uaddr, &sp, len);
 
-	*usockaddr_len = len;
-
-	return 0;
+	return len;
 }
 
 static int pppoe_ioctl(struct socket *sock, unsigned int cmd,
diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index 6dde9a0cfe76..8249d46a7844 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -483,7 +483,7 @@ static int pptp_connect(struct socket *sock, struct sockaddr *uservaddr,
 }
 
 static int pptp_getname(struct socket *sock, struct sockaddr *uaddr,
-	int *usockaddr_len, int peer)
+	int peer)
 {
 	int len = sizeof(struct sockaddr_pppox);
 	struct sockaddr_pppox sp;
@@ -496,9 +496,7 @@ static int pptp_getname(struct socket *sock, struct sockaddr *uaddr,
 
 	memcpy(uaddr, &sp, len);
 
-	*usockaddr_len = len;
-
-	return 0;
+	return len;
 }
 
 static int pptp_release(struct socket *sock)
diff --git a/drivers/scsi/iscsi_tcp.c b/drivers/scsi/iscsi_tcp.c
index 6198559abbd8..0ad00dbf912d 100644
--- a/drivers/scsi/iscsi_tcp.c
+++ b/drivers/scsi/iscsi_tcp.c
@@ -732,7 +732,7 @@ static int iscsi_sw_tcp_conn_get_param(struct iscsi_cls_conn *cls_conn,
 	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
 	struct iscsi_sw_tcp_conn *tcp_sw_conn = tcp_conn->dd_data;
 	struct sockaddr_in6 addr;
-	int rc, len;
+	int rc;
 
 	switch(param) {
 	case ISCSI_PARAM_CONN_PORT:
@@ -745,12 +745,12 @@ static int iscsi_sw_tcp_conn_get_param(struct iscsi_cls_conn *cls_conn,
 		}
 		if (param == ISCSI_PARAM_LOCAL_PORT)
 			rc = kernel_getsockname(tcp_sw_conn->sock,
-						(struct sockaddr *)&addr, &len);
+						(struct sockaddr *)&addr);
 		else
 			rc = kernel_getpeername(tcp_sw_conn->sock,
-						(struct sockaddr *)&addr, &len);
+						(struct sockaddr *)&addr);
 		spin_unlock_bh(&conn->session->frwd_lock);
-		if (rc)
+		if (rc < 0)
 			return rc;
 
 		return iscsi_conn_get_addr_param((struct sockaddr_storage *)
@@ -771,7 +771,7 @@ static int iscsi_sw_tcp_host_get_param(struct Scsi_Host *shost,
 	struct iscsi_tcp_conn *tcp_conn;
 	struct iscsi_sw_tcp_conn *tcp_sw_conn;
 	struct sockaddr_in6 addr;
-	int rc, len;
+	int rc;
 
 	switch (param) {
 	case ISCSI_HOST_PARAM_IPADDRESS:
@@ -793,9 +793,9 @@ static int iscsi_sw_tcp_host_get_param(struct Scsi_Host *shost,
 		}
 
 		rc = kernel_getsockname(tcp_sw_conn->sock,
-					(struct sockaddr *)&addr, &len);
+					(struct sockaddr *)&addr);
 		spin_unlock_bh(&session->frwd_lock);
-		if (rc)
+		if (rc < 0)
 			return rc;
 
 		return iscsi_conn_get_addr_param((struct sockaddr_storage *)
diff --git a/drivers/soc/qcom/qmi_interface.c b/drivers/soc/qcom/qmi_interface.c
index 877611d5c42b..321982277697 100644
--- a/drivers/soc/qcom/qmi_interface.c
+++ b/drivers/soc/qcom/qmi_interface.c
@@ -586,7 +586,6 @@ static struct socket *qmi_sock_create(struct qmi_handle *qmi,
 				      struct sockaddr_qrtr *sq)
 {
 	struct socket *sock;
-	int sl = sizeof(*sq);
 	int ret;
 
 	ret = sock_create_kern(&init_net, AF_QIPCRTR, SOCK_DGRAM,
@@ -594,7 +593,7 @@ static struct socket *qmi_sock_create(struct qmi_handle *qmi,
 	if (ret < 0)
 		return ERR_PTR(ret);
 
-	ret = kernel_getsockname(sock, (struct sockaddr *)sq, &sl);
+	ret = kernel_getsockname(sock, (struct sockaddr *)sq);
 	if (ret < 0) {
 		sock_release(sock);
 		return ERR_PTR(ret);
diff --git a/drivers/staging/ipx/af_ipx.c b/drivers/staging/ipx/af_ipx.c
index d21a9d128d3e..5703dd176787 100644
--- a/drivers/staging/ipx/af_ipx.c
+++ b/drivers/staging/ipx/af_ipx.c
@@ -1577,7 +1577,7 @@ static int ipx_connect(struct socket *sock, struct sockaddr *uaddr,
 
 
 static int ipx_getname(struct socket *sock, struct sockaddr *uaddr,
-			int *uaddr_len, int peer)
+			int peer)
 {
 	struct ipx_address *addr;
 	struct sockaddr_ipx sipx;
@@ -1585,8 +1585,6 @@ static int ipx_getname(struct socket *sock, struct sockaddr *uaddr,
 	struct ipx_sock *ipxs = ipx_sk(sk);
 	int rc;
 
-	*uaddr_len = sizeof(struct sockaddr_ipx);
-
 	lock_sock(sk);
 	if (peer) {
 		rc = -ENOTCONN;
@@ -1620,7 +1618,7 @@ static int ipx_getname(struct socket *sock, struct sockaddr *uaddr,
 	sipx.sipx_zero	 = 0;
 	memcpy(uaddr, &sipx, sizeof(sipx));
 
-	rc = 0;
+	rc = sizeof(struct sockaddr_ipx);
 out:
 	release_sock(sk);
 	return rc;
diff --git a/drivers/staging/irda/net/af_irda.c b/drivers/staging/irda/net/af_irda.c
index 2f1e9ab3d6d0..c13553a9ee11 100644
--- a/drivers/staging/irda/net/af_irda.c
+++ b/drivers/staging/irda/net/af_irda.c
@@ -697,7 +697,7 @@ static int irda_discover_daddr_and_lsap_sel(struct irda_sock *self, char *name)
  *
  */
 static int irda_getname(struct socket *sock, struct sockaddr *uaddr,
-			int *uaddr_len, int peer)
+			int peer)
 {
 	struct sockaddr_irda saddr;
 	struct sock *sk = sock->sk;
@@ -720,11 +720,9 @@ static int irda_getname(struct socket *sock, struct sockaddr *uaddr,
 	pr_debug("%s(), tsap_sel = %#x\n", __func__, saddr.sir_lsap_sel);
 	pr_debug("%s(), addr = %08x\n", __func__, saddr.sir_addr);
 
-	/* uaddr_len come to us uninitialised */
-	*uaddr_len = sizeof (struct sockaddr_irda);
-	memcpy(uaddr, &saddr, *uaddr_len);
+	memcpy(uaddr, &saddr, sizeof (struct sockaddr_irda));
 
-	return 0;
+	return sizeof (struct sockaddr_irda);
 }
 
 /*
diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index ce93806eefca..1bee667802b0 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -448,14 +448,13 @@ int
 lnet_sock_getaddr(struct socket *sock, bool remote, __u32 *ip, int *port)
 {
 	struct sockaddr_in sin;
-	int len = sizeof(sin);
 	int rc;
 
 	if (remote)
-		rc = kernel_getpeername(sock, (struct sockaddr *)&sin, &len);
+		rc = kernel_getpeername(sock, (struct sockaddr *)&sin);
 	else
-		rc = kernel_getsockname(sock, (struct sockaddr *)&sin, &len);
-	if (rc) {
+		rc = kernel_getsockname(sock, (struct sockaddr *)&sin);
+	if (rc < 0) {
 		CERROR("Error %d getting sock %s IP/port\n",
 		       rc, remote ? "peer" : "local");
 		return rc;
diff --git a/drivers/target/iscsi/iscsi_target_login.c b/drivers/target/iscsi/iscsi_target_login.c
index 64c5a57b92e4..99501785cdc1 100644
--- a/drivers/target/iscsi/iscsi_target_login.c
+++ b/drivers/target/iscsi/iscsi_target_login.c
@@ -1020,7 +1020,7 @@ int iscsit_accept_np(struct iscsi_np *np, struct iscsi_conn *conn)
 	struct socket *new_sock, *sock = np->np_socket;
 	struct sockaddr_in sock_in;
 	struct sockaddr_in6 sock_in6;
-	int rc, err;
+	int rc;
 
 	rc = kernel_accept(sock, &new_sock, 0);
 	if (rc < 0)
@@ -1033,8 +1033,8 @@ int iscsit_accept_np(struct iscsi_np *np, struct iscsi_conn *conn)
 		memset(&sock_in6, 0, sizeof(struct sockaddr_in6));
 
 		rc = conn->sock->ops->getname(conn->sock,
-				(struct sockaddr *)&sock_in6, &err, 1);
-		if (!rc) {
+				(struct sockaddr *)&sock_in6, 1);
+		if (rc >= 0) {
 			if (!ipv6_addr_v4mapped(&sock_in6.sin6_addr)) {
 				memcpy(&conn->login_sockaddr, &sock_in6, sizeof(sock_in6));
 			} else {
@@ -1047,8 +1047,8 @@ int iscsit_accept_np(struct iscsi_np *np, struct iscsi_conn *conn)
 		}
 
 		rc = conn->sock->ops->getname(conn->sock,
-				(struct sockaddr *)&sock_in6, &err, 0);
-		if (!rc) {
+				(struct sockaddr *)&sock_in6, 0);
+		if (rc >= 0) {
 			if (!ipv6_addr_v4mapped(&sock_in6.sin6_addr)) {
 				memcpy(&conn->local_sockaddr, &sock_in6, sizeof(sock_in6));
 			} else {
@@ -1063,13 +1063,13 @@ int iscsit_accept_np(struct iscsi_np *np, struct iscsi_conn *conn)
 		memset(&sock_in, 0, sizeof(struct sockaddr_in));
 
 		rc = conn->sock->ops->getname(conn->sock,
-				(struct sockaddr *)&sock_in, &err, 1);
-		if (!rc)
+				(struct sockaddr *)&sock_in, 1);
+		if (rc >= 0)
 			memcpy(&conn->login_sockaddr, &sock_in, sizeof(sock_in));
 
 		rc = conn->sock->ops->getname(conn->sock,
-				(struct sockaddr *)&sock_in, &err, 0);
-		if (!rc)
+				(struct sockaddr *)&sock_in, 0);
+		if (rc >= 0)
 			memcpy(&conn->local_sockaddr, &sock_in, sizeof(sock_in));
 	}
 
diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 610cba276d47..b5fb56b822fd 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -1038,7 +1038,7 @@ static struct socket *get_raw_socket(int fd)
 		struct sockaddr_ll sa;
 		char  buf[MAX_ADDR_LEN];
 	} uaddr;
-	int uaddr_len = sizeof uaddr, r;
+	int r;
 	struct socket *sock = sockfd_lookup(fd, &r);
 
 	if (!sock)
@@ -1050,9 +1050,8 @@ static struct socket *get_raw_socket(int fd)
 		goto err;
 	}
 
-	r = sock->ops->getname(sock, (struct sockaddr *)&uaddr.sa,
-			       &uaddr_len, 0);
-	if (r)
+	r = sock->ops->getname(sock, (struct sockaddr *)&uaddr.sa, 0);
+	if (r < 0)
 		goto err;
 
 	if (uaddr.sa.sll_family != AF_PACKET) {
diff --git a/fs/dlm/lowcomms.c b/fs/dlm/lowcomms.c
index cff79ea0c01d..5243989a60cc 100644
--- a/fs/dlm/lowcomms.c
+++ b/fs/dlm/lowcomms.c
@@ -482,7 +482,6 @@ static void lowcomms_error_report(struct sock *sk)
 {
 	struct connection *con;
 	struct sockaddr_storage saddr;
-	int buflen;
 	void (*orig_report)(struct sock *) = NULL;
 
 	read_lock_bh(&sk->sk_callback_lock);
@@ -492,7 +491,7 @@ static void lowcomms_error_report(struct sock *sk)
 
 	orig_report = listen_sock.sk_error_report;
 	if (con->sock == NULL ||
-	    kernel_getpeername(con->sock, (struct sockaddr *)&saddr, &buflen)) {
+	    kernel_getpeername(con->sock, (struct sockaddr *)&saddr) < 0) {
 		printk_ratelimited(KERN_ERR "dlm: node %d: socket error "
 				   "sending to node %d, port %d, "
 				   "sk_err=%d/%d\n", dlm_our_nodeid(),
@@ -757,8 +756,8 @@ static int tcp_accept_from_sock(struct connection *con)
 
 	/* Get the connected socket's peer */
 	memset(&peeraddr, 0, sizeof(peeraddr));
-	if (newsock->ops->getname(newsock, (struct sockaddr *)&peeraddr,
-				  &len, 2)) {
+	len = newsock->ops->getname(newsock, (struct sockaddr *)&peeraddr, 2);
+	if (len < 0) {
 		result = -ECONNABORTED;
 		goto accept_err;
 	}
diff --git a/fs/ocfs2/cluster/tcp.c b/fs/ocfs2/cluster/tcp.c
index eac5140aac47..e5076185cc1e 100644
--- a/fs/ocfs2/cluster/tcp.c
+++ b/fs/ocfs2/cluster/tcp.c
@@ -1819,7 +1819,7 @@ int o2net_register_hb_callbacks(void)
 
 static int o2net_accept_one(struct socket *sock, int *more)
 {
-	int ret, slen;
+	int ret;
 	struct sockaddr_in sin;
 	struct socket *new_sock = NULL;
 	struct o2nm_node *node = NULL;
@@ -1864,9 +1864,7 @@ static int o2net_accept_one(struct socket *sock, int *more)
 		goto out;
 	}
 
-	slen = sizeof(sin);
-	ret = new_sock->ops->getname(new_sock, (struct sockaddr *) &sin,
-				       &slen, 1);
+	ret = new_sock->ops->getname(new_sock, (struct sockaddr *) &sin, 1);
 	if (ret < 0)
 		goto out;
 
diff --git a/include/linux/net.h b/include/linux/net.h
index 91216b16feb7..000d1aada74f 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -146,7 +146,7 @@ struct proto_ops {
 				      struct socket *newsock, int flags, bool kern);
 	int		(*getname)   (struct socket *sock,
 				      struct sockaddr *addr,
-				      int *sockaddr_len, int peer);
+				      int peer);
 	__poll_t	(*poll)	     (struct file *file, struct socket *sock,
 				      struct poll_table_struct *wait);
 	int		(*ioctl)     (struct socket *sock, unsigned int cmd,
@@ -294,10 +294,8 @@ int kernel_listen(struct socket *sock, int backlog);
 int kernel_accept(struct socket *sock, struct socket **newsock, int flags);
 int kernel_connect(struct socket *sock, struct sockaddr *addr, int addrlen,
 		   int flags);
-int kernel_getsockname(struct socket *sock, struct sockaddr *addr,
-		       int *addrlen);
-int kernel_getpeername(struct socket *sock, struct sockaddr *addr,
-		       int *addrlen);
+int kernel_getsockname(struct socket *sock, struct sockaddr *addr);
+int kernel_getpeername(struct socket *sock, struct sockaddr *addr);
 int kernel_getsockopt(struct socket *sock, int level, int optname, char *optval,
 		      int *optlen);
 int kernel_setsockopt(struct socket *sock, int level, int optname, char *optval,
diff --git a/include/net/inet_common.h b/include/net/inet_common.h
index 5a54c9570977..500f81375200 100644
--- a/include/net/inet_common.h
+++ b/include/net/inet_common.h
@@ -32,7 +32,7 @@ int inet_shutdown(struct socket *sock, int how);
 int inet_listen(struct socket *sock, int backlog);
 void inet_sock_destruct(struct sock *sk);
 int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len);
-int inet_getname(struct socket *sock, struct sockaddr *uaddr, int *uaddr_len,
+int inet_getname(struct socket *sock, struct sockaddr *uaddr,
 		 int peer);
 int inet_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg);
 int inet_ctl_sock_create(struct sock **sk, unsigned short family,
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 8606c9113d3f..7a98cd583c73 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -1056,7 +1056,7 @@ void ipv6_local_rxpmtu(struct sock *sk, struct flowi6 *fl6, u32 mtu);
 
 int inet6_release(struct socket *sock);
 int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len);
-int inet6_getname(struct socket *sock, struct sockaddr *uaddr, int *uaddr_len,
+int inet6_getname(struct socket *sock, struct sockaddr *uaddr,
 		  int peer);
 int inet6_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg);
 
diff --git a/include/net/sock.h b/include/net/sock.h
index 169c92afcafa..3aa7b7d6e6c7 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1584,7 +1584,7 @@ int sock_no_bind(struct socket *, struct sockaddr *, int);
 int sock_no_connect(struct socket *, struct sockaddr *, int, int);
 int sock_no_socketpair(struct socket *, struct socket *);
 int sock_no_accept(struct socket *, struct socket *, int, bool);
-int sock_no_getname(struct socket *, struct sockaddr *, int *, int);
+int sock_no_getname(struct socket *, struct sockaddr *, int);
 __poll_t sock_no_poll(struct file *, struct socket *,
 			  struct poll_table_struct *);
 int sock_no_ioctl(struct socket *, unsigned int, unsigned long);
diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 03a9fc0771c0..9b6bc5abe946 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1238,7 +1238,7 @@ static int atalk_connect(struct socket *sock, struct sockaddr *uaddr,
  * fields into the sockaddr.
  */
 static int atalk_getname(struct socket *sock, struct sockaddr *uaddr,
-			 int *uaddr_len, int peer)
+			 int peer)
 {
 	struct sockaddr_at sat;
 	struct sock *sk = sock->sk;
@@ -1251,7 +1251,6 @@ static int atalk_getname(struct socket *sock, struct sockaddr *uaddr,
 		if (atalk_autobind(sk) < 0)
 			goto out;
 
-	*uaddr_len = sizeof(struct sockaddr_at);
 	memset(&sat, 0, sizeof(sat));
 
 	if (peer) {
@@ -1268,9 +1267,9 @@ static int atalk_getname(struct socket *sock, struct sockaddr *uaddr,
 		sat.sat_port	    = at->src_port;
 	}
 
-	err = 0;
 	sat.sat_family = AF_APPLETALK;
 	memcpy(uaddr, &sat, sizeof(sat));
+	err = sizeof(struct sockaddr_at);
 
 out:
 	release_sock(sk);
diff --git a/net/atm/pvc.c b/net/atm/pvc.c
index e1140b3bdcaa..2cb10af16afc 100644
--- a/net/atm/pvc.c
+++ b/net/atm/pvc.c
@@ -87,21 +87,20 @@ static int pvc_getsockopt(struct socket *sock, int level, int optname,
 }
 
 static int pvc_getname(struct socket *sock, struct sockaddr *sockaddr,
-		       int *sockaddr_len, int peer)
+		       int peer)
 {
 	struct sockaddr_atmpvc *addr;
 	struct atm_vcc *vcc = ATM_SD(sock);
 
 	if (!vcc->dev || !test_bit(ATM_VF_ADDR, &vcc->flags))
 		return -ENOTCONN;
-	*sockaddr_len = sizeof(struct sockaddr_atmpvc);
 	addr = (struct sockaddr_atmpvc *)sockaddr;
 	memset(addr, 0, sizeof(*addr));
 	addr->sap_family = AF_ATMPVC;
 	addr->sap_addr.itf = vcc->dev->number;
 	addr->sap_addr.vpi = vcc->vpi;
 	addr->sap_addr.vci = vcc->vci;
-	return 0;
+	return sizeof(struct sockaddr_atmpvc);
 }
 
 static const struct proto_ops pvc_proto_ops = {
diff --git a/net/atm/svc.c b/net/atm/svc.c
index c458adcbc177..2f91b766ac42 100644
--- a/net/atm/svc.c
+++ b/net/atm/svc.c
@@ -419,15 +419,14 @@ static int svc_accept(struct socket *sock, struct socket *newsock, int flags,
 }
 
 static int svc_getname(struct socket *sock, struct sockaddr *sockaddr,
-		       int *sockaddr_len, int peer)
+		       int peer)
 {
 	struct sockaddr_atmsvc *addr;
 
-	*sockaddr_len = sizeof(struct sockaddr_atmsvc);
 	addr = (struct sockaddr_atmsvc *) sockaddr;
 	memcpy(addr, peer ? &ATM_SD(sock)->remote : &ATM_SD(sock)->local,
 	       sizeof(struct sockaddr_atmsvc));
-	return 0;
+	return sizeof(struct sockaddr_atmsvc);
 }
 
 int svc_change_qos(struct atm_vcc *vcc, struct atm_qos *qos)
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index 47fdd399626b..c8319ed48485 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1388,7 +1388,7 @@ static int ax25_accept(struct socket *sock, struct socket *newsock, int flags,
 }
 
 static int ax25_getname(struct socket *sock, struct sockaddr *uaddr,
-	int *uaddr_len, int peer)
+	int peer)
 {
 	struct full_sockaddr_ax25 *fsa = (struct full_sockaddr_ax25 *)uaddr;
 	struct sock *sk = sock->sk;
@@ -1427,7 +1427,7 @@ static int ax25_getname(struct socket *sock, struct sockaddr *uaddr,
 			fsa->fsa_digipeater[0] = null_ax25_address;
 		}
 	}
-	*uaddr_len = sizeof (struct full_sockaddr_ax25);
+	err = sizeof (struct full_sockaddr_ax25);
 
 out:
 	release_sock(sk);
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index 923e9a271872..1506e1632394 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -1340,7 +1340,7 @@ static int hci_sock_bind(struct socket *sock, struct sockaddr *addr,
 }
 
 static int hci_sock_getname(struct socket *sock, struct sockaddr *addr,
-			    int *addr_len, int peer)
+			    int peer)
 {
 	struct sockaddr_hci *haddr = (struct sockaddr_hci *)addr;
 	struct sock *sk = sock->sk;
@@ -1360,10 +1360,10 @@ static int hci_sock_getname(struct socket *sock, struct sockaddr *addr,
 		goto done;
 	}
 
-	*addr_len = sizeof(*haddr);
 	haddr->hci_family = AF_BLUETOOTH;
 	haddr->hci_dev    = hdev->id;
 	haddr->hci_channel= hci_pi(sk)->channel;
+	err = sizeof(*haddr);
 
 done:
 	release_sock(sk);
diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index 67a8642f57ea..686bdc6b35b0 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -358,7 +358,7 @@ static int l2cap_sock_accept(struct socket *sock, struct socket *newsock,
 }
 
 static int l2cap_sock_getname(struct socket *sock, struct sockaddr *addr,
-			      int *len, int peer)
+			      int peer)
 {
 	struct sockaddr_l2 *la = (struct sockaddr_l2 *) addr;
 	struct sock *sk = sock->sk;
@@ -373,7 +373,6 @@ static int l2cap_sock_getname(struct socket *sock, struct sockaddr *addr,
 
 	memset(la, 0, sizeof(struct sockaddr_l2));
 	addr->sa_family = AF_BLUETOOTH;
-	*len = sizeof(struct sockaddr_l2);
 
 	la->l2_psm = chan->psm;
 
@@ -387,7 +386,7 @@ static int l2cap_sock_getname(struct socket *sock, struct sockaddr *addr,
 		la->l2_bdaddr_type = chan->src_type;
 	}
 
-	return 0;
+	return sizeof(struct sockaddr_l2);
 }
 
 static int l2cap_sock_getsockopt_old(struct socket *sock, int optname,
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index 1aaccf637479..93a3b219db09 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -533,7 +533,7 @@ static int rfcomm_sock_accept(struct socket *sock, struct socket *newsock, int f
 	return err;
 }
 
-static int rfcomm_sock_getname(struct socket *sock, struct sockaddr *addr, int *len, int peer)
+static int rfcomm_sock_getname(struct socket *sock, struct sockaddr *addr, int peer)
 {
 	struct sockaddr_rc *sa = (struct sockaddr_rc *) addr;
 	struct sock *sk = sock->sk;
@@ -552,8 +552,7 @@ static int rfcomm_sock_getname(struct socket *sock, struct sockaddr *addr, int *
 	else
 		bacpy(&sa->rc_bdaddr, &rfcomm_pi(sk)->src);
 
-	*len = sizeof(struct sockaddr_rc);
-	return 0;
+	return sizeof(struct sockaddr_rc);
 }
 
 static int rfcomm_sock_sendmsg(struct socket *sock, struct msghdr *msg,
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index 08df57665e1f..413b8ee49fec 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -680,7 +680,7 @@ static int sco_sock_accept(struct socket *sock, struct socket *newsock,
 }
 
 static int sco_sock_getname(struct socket *sock, struct sockaddr *addr,
-			    int *len, int peer)
+			    int peer)
 {
 	struct sockaddr_sco *sa = (struct sockaddr_sco *) addr;
 	struct sock *sk = sock->sk;
@@ -688,14 +688,13 @@ static int sco_sock_getname(struct socket *sock, struct sockaddr *addr,
 	BT_DBG("sock %p, sk %p", sock, sk);
 
 	addr->sa_family = AF_BLUETOOTH;
-	*len = sizeof(struct sockaddr_sco);
 
 	if (peer)
 		bacpy(&sa->sco_bdaddr, &sco_pi(sk)->dst);
 	else
 		bacpy(&sa->sco_bdaddr, &sco_pi(sk)->src);
 
-	return 0;
+	return sizeof(struct sockaddr_sco);
 }
 
 static int sco_sock_sendmsg(struct socket *sock, struct msghdr *msg,
diff --git a/net/can/raw.c b/net/can/raw.c
index f2ecc43376a1..1051eee82581 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -470,7 +470,7 @@ static int raw_bind(struct socket *sock, struct sockaddr *uaddr, int len)
 }
 
 static int raw_getname(struct socket *sock, struct sockaddr *uaddr,
-		       int *len, int peer)
+		       int peer)
 {
 	struct sockaddr_can *addr = (struct sockaddr_can *)uaddr;
 	struct sock *sk = sock->sk;
@@ -483,9 +483,7 @@ static int raw_getname(struct socket *sock, struct sockaddr *uaddr,
 	addr->can_family  = AF_CAN;
 	addr->can_ifindex = ro->ifindex;
 
-	*len = sizeof(*addr);
-
-	return 0;
+	return sizeof(*addr);
 }
 
 static int raw_setsockopt(struct socket *sock, int level, int optname,
diff --git a/net/core/sock.c b/net/core/sock.c
index c501499a04fe..04e5e27c9b81 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1274,7 +1274,8 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 	{
 		char address[128];
 
-		if (sock->ops->getname(sock, (struct sockaddr *)address, &lv, 2))
+		lv = sock->ops->getname(sock, (struct sockaddr *)address, 2);
+		if (lv < 0)
 			return -ENOTCONN;
 		if (lv < len)
 			return -EINVAL;
@@ -2497,7 +2498,7 @@ int sock_no_accept(struct socket *sock, struct socket *newsock, int flags,
 EXPORT_SYMBOL(sock_no_accept);
 
 int sock_no_getname(struct socket *sock, struct sockaddr *saddr,
-		    int *len, int peer)
+		    int peer)
 {
 	return -EOPNOTSUPP;
 }
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 91dd09f79808..45cb5bea884b 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -1180,14 +1180,12 @@ static int dn_accept(struct socket *sock, struct socket *newsock, int flags,
 }
 
 
-static int dn_getname(struct socket *sock, struct sockaddr *uaddr,int *uaddr_len,int peer)
+static int dn_getname(struct socket *sock, struct sockaddr *uaddr,int peer)
 {
 	struct sockaddr_dn *sa = (struct sockaddr_dn *)uaddr;
 	struct sock *sk = sock->sk;
 	struct dn_scp *scp = DN_SK(sk);
 
-	*uaddr_len = sizeof(struct sockaddr_dn);
-
 	lock_sock(sk);
 
 	if (peer) {
@@ -1205,7 +1203,7 @@ static int dn_getname(struct socket *sock, struct sockaddr *uaddr,int *uaddr_len
 
 	release_sock(sk);
 
-	return 0;
+	return sizeof(struct sockaddr_dn);
 }
 
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index e4329e161943..f98e2f0db841 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -723,7 +723,7 @@ EXPORT_SYMBOL(inet_accept);
  *	This does both peername and sockname.
  */
 int inet_getname(struct socket *sock, struct sockaddr *uaddr,
-			int *uaddr_len, int peer)
+			int peer)
 {
 	struct sock *sk		= sock->sk;
 	struct inet_sock *inet	= inet_sk(sk);
@@ -745,8 +745,7 @@ int inet_getname(struct socket *sock, struct sockaddr *uaddr,
 		sin->sin_addr.s_addr = addr;
 	}
 	memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
-	*uaddr_len = sizeof(*sin);
-	return 0;
+	return sizeof(*sin);
 }
 EXPORT_SYMBOL(inet_getname);
 
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 416917719a6f..c1e292db04db 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -470,7 +470,7 @@ EXPORT_SYMBOL_GPL(inet6_destroy_sock);
  */
 
 int inet6_getname(struct socket *sock, struct sockaddr *uaddr,
-		 int *uaddr_len, int peer)
+		 int peer)
 {
 	struct sockaddr_in6 *sin = (struct sockaddr_in6 *)uaddr;
 	struct sock *sk = sock->sk;
@@ -500,8 +500,7 @@ int inet6_getname(struct socket *sock, struct sockaddr *uaddr,
 	}
 	sin->sin6_scope_id = ipv6_iface_scope_id(&sin->sin6_addr,
 						 sk->sk_bound_dev_if);
-	*uaddr_len = sizeof(*sin);
-	return 0;
+	return sizeof(*sin);
 }
 EXPORT_SYMBOL(inet6_getname);
 
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index 1e8cc7bcbca3..81ce15ffb878 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -989,14 +989,13 @@ static int iucv_sock_accept(struct socket *sock, struct socket *newsock,
 }
 
 static int iucv_sock_getname(struct socket *sock, struct sockaddr *addr,
-			     int *len, int peer)
+			     int peer)
 {
 	struct sockaddr_iucv *siucv = (struct sockaddr_iucv *) addr;
 	struct sock *sk = sock->sk;
 	struct iucv_sock *iucv = iucv_sk(sk);
 
 	addr->sa_family = AF_IUCV;
-	*len = sizeof(struct sockaddr_iucv);
 
 	if (peer) {
 		memcpy(siucv->siucv_user_id, iucv->dst_user_id, 8);
@@ -1009,7 +1008,7 @@ static int iucv_sock_getname(struct socket *sock, struct sockaddr *addr,
 	memset(&siucv->siucv_addr, 0, sizeof(siucv->siucv_addr));
 	memset(&siucv->siucv_nodeid, 0, sizeof(siucv->siucv_nodeid));
 
-	return 0;
+	return sizeof(struct sockaddr_iucv);
 }
 
 /**
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index ff61124fdf59..4614585e1720 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -349,7 +349,7 @@ static int l2tp_ip_disconnect(struct sock *sk, int flags)
 }
 
 static int l2tp_ip_getname(struct socket *sock, struct sockaddr *uaddr,
-			   int *uaddr_len, int peer)
+			   int peer)
 {
 	struct sock *sk		= sock->sk;
 	struct inet_sock *inet	= inet_sk(sk);
@@ -370,8 +370,7 @@ static int l2tp_ip_getname(struct socket *sock, struct sockaddr *uaddr,
 		lsa->l2tp_conn_id = lsk->conn_id;
 		lsa->l2tp_addr.s_addr = addr;
 	}
-	*uaddr_len = sizeof(*lsa);
-	return 0;
+	return sizeof(*lsa);
 }
 
 static int l2tp_ip_backlog_recv(struct sock *sk, struct sk_buff *skb)
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index 192344688c06..efea58b66295 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -421,7 +421,7 @@ static int l2tp_ip6_disconnect(struct sock *sk, int flags)
 }
 
 static int l2tp_ip6_getname(struct socket *sock, struct sockaddr *uaddr,
-			    int *uaddr_len, int peer)
+			    int peer)
 {
 	struct sockaddr_l2tpip6 *lsa = (struct sockaddr_l2tpip6 *)uaddr;
 	struct sock *sk = sock->sk;
@@ -449,8 +449,7 @@ static int l2tp_ip6_getname(struct socket *sock, struct sockaddr *uaddr,
 	}
 	if (ipv6_addr_type(&lsa->l2tp_addr) & IPV6_ADDR_LINKLOCAL)
 		lsa->l2tp_scope_id = sk->sk_bound_dev_if;
-	*uaddr_len = sizeof(*lsa);
-	return 0;
+	return sizeof(*lsa);
 }
 
 static int l2tp_ip6_backlog_recv(struct sock *sk, struct sk_buff *skb)
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 59f246d7b290..99a03c72db4f 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -870,7 +870,7 @@ static int pppol2tp_session_create(struct net *net, struct l2tp_tunnel *tunnel,
 /* getname() support.
  */
 static int pppol2tp_getname(struct socket *sock, struct sockaddr *uaddr,
-			    int *usockaddr_len, int peer)
+			    int peer)
 {
 	int len = 0;
 	int error = 0;
@@ -969,8 +969,7 @@ static int pppol2tp_getname(struct socket *sock, struct sockaddr *uaddr,
 		memcpy(uaddr, &sp, len);
 	}
 
-	*usockaddr_len = len;
-	error = 0;
+	error = len;
 
 	sock_put(sk);
 end:
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index c38d16f22d2a..01dcc0823d1f 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -971,7 +971,7 @@ static int llc_ui_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
  *	Return the address information of a socket.
  */
 static int llc_ui_getname(struct socket *sock, struct sockaddr *uaddr,
-			  int *uaddrlen, int peer)
+			  int peer)
 {
 	struct sockaddr_llc sllc;
 	struct sock *sk = sock->sk;
@@ -982,7 +982,6 @@ static int llc_ui_getname(struct socket *sock, struct sockaddr *uaddr,
 	lock_sock(sk);
 	if (sock_flag(sk, SOCK_ZAPPED))
 		goto out;
-	*uaddrlen = sizeof(sllc);
 	if (peer) {
 		rc = -ENOTCONN;
 		if (sk->sk_state != TCP_ESTABLISHED)
@@ -1003,9 +1002,9 @@ static int llc_ui_getname(struct socket *sock, struct sockaddr *uaddr,
 			       IFHWADDRLEN);
 		}
 	}
-	rc = 0;
 	sllc.sllc_family = AF_LLC;
 	memcpy(uaddr, &sllc, sizeof(sllc));
+	rc = sizeof(sllc);
 out:
 	release_sock(sk);
 	return rc;
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 2ad445c1d27c..3c8af14330b5 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1105,7 +1105,7 @@ static int netlink_connect(struct socket *sock, struct sockaddr *addr,
 }
 
 static int netlink_getname(struct socket *sock, struct sockaddr *addr,
-			   int *addr_len, int peer)
+			   int peer)
 {
 	struct sock *sk = sock->sk;
 	struct netlink_sock *nlk = nlk_sk(sk);
@@ -1113,7 +1113,6 @@ static int netlink_getname(struct socket *sock, struct sockaddr *addr,
 
 	nladdr->nl_family = AF_NETLINK;
 	nladdr->nl_pad = 0;
-	*addr_len = sizeof(*nladdr);
 
 	if (peer) {
 		nladdr->nl_pid = nlk->dst_portid;
@@ -1124,7 +1123,7 @@ static int netlink_getname(struct socket *sock, struct sockaddr *addr,
 		nladdr->nl_groups = nlk->groups ? nlk->groups[0] : 0;
 		netlink_unlock_table();
 	}
-	return 0;
+	return sizeof(*nladdr);
 }
 
 static int netlink_ioctl(struct socket *sock, unsigned int cmd,
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 9ba30c63be3d..35bb6807927f 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -829,11 +829,12 @@ static int nr_accept(struct socket *sock, struct socket *newsock, int flags,
 }
 
 static int nr_getname(struct socket *sock, struct sockaddr *uaddr,
-	int *uaddr_len, int peer)
+	int peer)
 {
 	struct full_sockaddr_ax25 *sax = (struct full_sockaddr_ax25 *)uaddr;
 	struct sock *sk = sock->sk;
 	struct nr_sock *nr = nr_sk(sk);
+	int uaddr_len;
 
 	memset(&sax->fsa_ax25, 0, sizeof(struct sockaddr_ax25));
 
@@ -848,16 +849,16 @@ static int nr_getname(struct socket *sock, struct sockaddr *uaddr,
 		sax->fsa_ax25.sax25_call   = nr->user_addr;
 		memset(sax->fsa_digipeater, 0, sizeof(sax->fsa_digipeater));
 		sax->fsa_digipeater[0]     = nr->dest_addr;
-		*uaddr_len = sizeof(struct full_sockaddr_ax25);
+		uaddr_len = sizeof(struct full_sockaddr_ax25);
 	} else {
 		sax->fsa_ax25.sax25_family = AF_NETROM;
 		sax->fsa_ax25.sax25_ndigis = 0;
 		sax->fsa_ax25.sax25_call   = nr->source_addr;
-		*uaddr_len = sizeof(struct sockaddr_ax25);
+		uaddr_len = sizeof(struct sockaddr_ax25);
 	}
 	release_sock(sk);
 
-	return 0;
+	return uaddr_len;
 }
 
 int nr_rx_frame(struct sk_buff *skb, struct net_device *dev)
diff --git a/net/nfc/llcp_sock.c b/net/nfc/llcp_sock.c
index 376040092142..ea0c0c6f1874 100644
--- a/net/nfc/llcp_sock.c
+++ b/net/nfc/llcp_sock.c
@@ -497,7 +497,7 @@ static int llcp_sock_accept(struct socket *sock, struct socket *newsock,
 }
 
 static int llcp_sock_getname(struct socket *sock, struct sockaddr *uaddr,
-			     int *len, int peer)
+			     int peer)
 {
 	struct sock *sk = sock->sk;
 	struct nfc_llcp_sock *llcp_sock = nfc_llcp_sock(sk);
@@ -510,7 +510,6 @@ static int llcp_sock_getname(struct socket *sock, struct sockaddr *uaddr,
 		 llcp_sock->dsap, llcp_sock->ssap);
 
 	memset(llcp_addr, 0, sizeof(*llcp_addr));
-	*len = sizeof(struct sockaddr_nfc_llcp);
 
 	lock_sock(sk);
 	if (!llcp_sock->dev) {
@@ -528,7 +527,7 @@ static int llcp_sock_getname(struct socket *sock, struct sockaddr *uaddr,
 	       llcp_addr->service_name_len);
 	release_sock(sk);
 
-	return 0;
+	return sizeof(struct sockaddr_nfc_llcp);
 }
 
 static inline __poll_t llcp_accept_poll(struct sock *parent)
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index e0f3f4aeeb4f..616cb9c18f88 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -3409,7 +3409,7 @@ static int packet_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 }
 
 static int packet_getname_spkt(struct socket *sock, struct sockaddr *uaddr,
-			       int *uaddr_len, int peer)
+			       int peer)
 {
 	struct net_device *dev;
 	struct sock *sk	= sock->sk;
@@ -3424,13 +3424,12 @@ static int packet_getname_spkt(struct socket *sock, struct sockaddr *uaddr,
 	if (dev)
 		strlcpy(uaddr->sa_data, dev->name, sizeof(uaddr->sa_data));
 	rcu_read_unlock();
-	*uaddr_len = sizeof(*uaddr);
 
-	return 0;
+	return sizeof(*uaddr);
 }
 
 static int packet_getname(struct socket *sock, struct sockaddr *uaddr,
-			  int *uaddr_len, int peer)
+			  int peer)
 {
 	struct net_device *dev;
 	struct sock *sk = sock->sk;
@@ -3455,9 +3454,8 @@ static int packet_getname(struct socket *sock, struct sockaddr *uaddr,
 		sll->sll_halen = 0;
 	}
 	rcu_read_unlock();
-	*uaddr_len = offsetof(struct sockaddr_ll, sll_addr) + sll->sll_halen;
 
-	return 0;
+	return offsetof(struct sockaddr_ll, sll_addr) + sll->sll_halen;
 }
 
 static int packet_dev_mc(struct net_device *dev, struct packet_mclist *i,
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index fffcd69f63ff..f9b40e6a18a5 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -326,7 +326,7 @@ static int pn_socket_accept(struct socket *sock, struct socket *newsock,
 }
 
 static int pn_socket_getname(struct socket *sock, struct sockaddr *addr,
-				int *sockaddr_len, int peer)
+				int peer)
 {
 	struct sock *sk = sock->sk;
 	struct pn_sock *pn = pn_sk(sk);
@@ -337,8 +337,7 @@ static int pn_socket_getname(struct socket *sock, struct sockaddr *addr,
 		pn_sockaddr_set_object((struct sockaddr_pn *)addr,
 					pn->sobject);
 
-	*sockaddr_len = sizeof(struct sockaddr_pn);
-	return 0;
+	return sizeof(struct sockaddr_pn);
 }
 
 static __poll_t pn_socket_poll(struct file *file, struct socket *sock,
diff --git a/net/qrtr/qrtr.c b/net/qrtr/qrtr.c
index 5fb3929e3d7d..b33e5aeb4c06 100644
--- a/net/qrtr/qrtr.c
+++ b/net/qrtr/qrtr.c
@@ -893,7 +893,7 @@ static int qrtr_connect(struct socket *sock, struct sockaddr *saddr,
 }
 
 static int qrtr_getname(struct socket *sock, struct sockaddr *saddr,
-			int *len, int peer)
+			int peer)
 {
 	struct qrtr_sock *ipc = qrtr_sk(sock->sk);
 	struct sockaddr_qrtr qaddr;
@@ -912,12 +912,11 @@ static int qrtr_getname(struct socket *sock, struct sockaddr *saddr,
 	}
 	release_sock(sk);
 
-	*len = sizeof(qaddr);
 	qaddr.sq_family = AF_QIPCRTR;
 
 	memcpy(saddr, &qaddr, sizeof(qaddr));
 
-	return 0;
+	return sizeof(qaddr);
 }
 
 static int qrtr_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
diff --git a/net/rds/af_rds.c b/net/rds/af_rds.c
index 744c637c86b0..0a8eefd256b3 100644
--- a/net/rds/af_rds.c
+++ b/net/rds/af_rds.c
@@ -110,7 +110,7 @@ void rds_wake_sk_sleep(struct rds_sock *rs)
 }
 
 static int rds_getname(struct socket *sock, struct sockaddr *uaddr,
-		       int *uaddr_len, int peer)
+		       int peer)
 {
 	struct sockaddr_in *sin = (struct sockaddr_in *)uaddr;
 	struct rds_sock *rs = rds_sk_to_rs(sock->sk);
@@ -131,8 +131,7 @@ static int rds_getname(struct socket *sock, struct sockaddr *uaddr,
 
 	sin->sin_family = AF_INET;
 
-	*uaddr_len = sizeof(*sin);
-	return 0;
+	return sizeof(*sin);
 }
 
 /*
diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index 44c4652721af..08230a145042 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -227,7 +227,6 @@ static void rds_tcp_tc_info(struct socket *rds_sock, unsigned int len,
 	struct rds_tcp_connection *tc;
 	unsigned long flags;
 	struct sockaddr_in sin;
-	int sinlen;
 	struct socket *sock;
 
 	spin_lock_irqsave(&rds_tcp_tc_list_lock, flags);
@@ -239,12 +238,10 @@ static void rds_tcp_tc_info(struct socket *rds_sock, unsigned int len,
 
 		sock = tc->t_sock;
 		if (sock) {
-			sock->ops->getname(sock, (struct sockaddr *)&sin,
-					   &sinlen, 0);
+			sock->ops->getname(sock, (struct sockaddr *)&sin, 0);
 			tsinfo.local_addr = sin.sin_addr.s_addr;
 			tsinfo.local_port = sin.sin_port;
-			sock->ops->getname(sock, (struct sockaddr *)&sin,
-					   &sinlen, 1);
+			sock->ops->getname(sock, (struct sockaddr *)&sin, 1);
 			tsinfo.peer_addr = sin.sin_addr.s_addr;
 			tsinfo.peer_port = sin.sin_port;
 		}
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 083bd251406f..5170373b797c 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -938,7 +938,7 @@ static int rose_accept(struct socket *sock, struct socket *newsock, int flags,
 }
 
 static int rose_getname(struct socket *sock, struct sockaddr *uaddr,
-	int *uaddr_len, int peer)
+	int peer)
 {
 	struct full_sockaddr_rose *srose = (struct full_sockaddr_rose *)uaddr;
 	struct sock *sk = sock->sk;
@@ -964,8 +964,7 @@ static int rose_getname(struct socket *sock, struct sockaddr *uaddr,
 			srose->srose_digis[n] = rose->source_digis[n];
 	}
 
-	*uaddr_len = sizeof(struct full_sockaddr_rose);
-	return 0;
+	return sizeof(struct full_sockaddr_rose);
 }
 
 int rose_rx_call_request(struct sk_buff *skb, struct net_device *dev, struct rose_neigh *neigh, unsigned int lci)
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index e35d4f73d2df..0d873c58e516 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -952,16 +952,16 @@ static int sctp_inet6_supported_addrs(const struct sctp_sock *opt,
 
 /* Handle SCTP_I_WANT_MAPPED_V4_ADDR for getpeername() and getsockname() */
 static int sctp_getname(struct socket *sock, struct sockaddr *uaddr,
-			int *uaddr_len, int peer)
+			int peer)
 {
 	int rc;
 
-	rc = inet6_getname(sock, uaddr, uaddr_len, peer);
+	rc = inet6_getname(sock, uaddr, peer);
 
-	if (rc != 0)
+	if (rc < 0)
 		return rc;
 
-	*uaddr_len = sctp_v6_addr_to_user(sctp_sk(sock->sk),
+	rc = sctp_v6_addr_to_user(sctp_sk(sock->sk),
 					  (union sctp_addr *)uaddr);
 
 	return rc;
diff --git a/net/smc/af_smc.c b/net/smc/af_smc.c
index da1a5cdefd13..38ae22b65e77 100644
--- a/net/smc/af_smc.c
+++ b/net/smc/af_smc.c
@@ -281,7 +281,6 @@ int smc_netinfo_by_tcpsk(struct socket *clcsock,
 	struct in_device *in_dev;
 	struct sockaddr_in addr;
 	int rc = -ENOENT;
-	int len;
 
 	if (!dst) {
 		rc = -ENOTCONN;
@@ -293,7 +292,7 @@ int smc_netinfo_by_tcpsk(struct socket *clcsock,
 	}
 
 	/* get address to which the internal TCP socket is bound */
-	kernel_getsockname(clcsock, (struct sockaddr *)&addr, &len);
+	kernel_getsockname(clcsock, (struct sockaddr *)&addr);
 	/* analyze IPv4 specific data of net_device belonging to TCP socket */
 	rcu_read_lock();
 	in_dev = __in_dev_get_rcu(dst->dev);
@@ -771,7 +770,7 @@ static void smc_listen_work(struct work_struct *work)
 	u8 buf[SMC_CLC_MAX_LEN];
 	struct smc_link *link;
 	int reason_code = 0;
-	int rc = 0, len;
+	int rc = 0;
 	__be32 subnet;
 	u8 prefix_len;
 	u8 ibport;
@@ -824,7 +823,7 @@ static void smc_listen_work(struct work_struct *work)
 	}
 
 	/* get address of the peer connected to the internal TCP socket */
-	kernel_getpeername(newclcsock, (struct sockaddr *)&peeraddr, &len);
+	kernel_getpeername(newclcsock, (struct sockaddr *)&peeraddr);
 
 	/* allocate connection / link group */
 	mutex_lock(&smc_create_lgr_pending);
@@ -1075,7 +1074,7 @@ static int smc_accept(struct socket *sock, struct socket *new_sock,
 }
 
 static int smc_getname(struct socket *sock, struct sockaddr *addr,
-		       int *len, int peer)
+		       int peer)
 {
 	struct smc_sock *smc;
 
@@ -1085,7 +1084,7 @@ static int smc_getname(struct socket *sock, struct sockaddr *addr,
 
 	smc = smc_sk(sock->sk);
 
-	return smc->clcsock->ops->getname(smc->clcsock, addr, len, peer);
+	return smc->clcsock->ops->getname(smc->clcsock, addr, peer);
 }
 
 static int smc_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
diff --git a/net/socket.c b/net/socket.c
index a93c99b518ca..fac8246a8ae8 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1573,8 +1573,9 @@ SYSCALL_DEFINE4(accept4, int, fd, struct sockaddr __user *, upeer_sockaddr,
 		goto out_fd;
 
 	if (upeer_sockaddr) {
-		if (newsock->ops->getname(newsock, (struct sockaddr *)&address,
-					  &len, 2) < 0) {
+		len = newsock->ops->getname(newsock,
+					(struct sockaddr *)&address, 2);
+		if (len < 0) {
 			err = -ECONNABORTED;
 			goto out_fd;
 		}
@@ -1654,7 +1655,7 @@ SYSCALL_DEFINE3(getsockname, int, fd, struct sockaddr __user *, usockaddr,
 {
 	struct socket *sock;
 	struct sockaddr_storage address;
-	int len, err, fput_needed;
+	int err, fput_needed;
 
 	sock = sockfd_lookup_light(fd, &err, &fput_needed);
 	if (!sock)
@@ -1664,10 +1665,11 @@ SYSCALL_DEFINE3(getsockname, int, fd, struct sockaddr __user *, usockaddr,
 	if (err)
 		goto out_put;
 
-	err = sock->ops->getname(sock, (struct sockaddr *)&address, &len, 0);
-	if (err)
+	err = sock->ops->getname(sock, (struct sockaddr *)&address, 0);
+	if (err < 0)
 		goto out_put;
-	err = move_addr_to_user(&address, len, usockaddr, usockaddr_len);
+        /* "err" is actually length in this case */
+	err = move_addr_to_user(&address, err, usockaddr, usockaddr_len);
 
 out_put:
 	fput_light(sock->file, fput_needed);
@@ -1685,7 +1687,7 @@ SYSCALL_DEFINE3(getpeername, int, fd, struct sockaddr __user *, usockaddr,
 {
 	struct socket *sock;
 	struct sockaddr_storage address;
-	int len, err, fput_needed;
+	int err, fput_needed;
 
 	sock = sockfd_lookup_light(fd, &err, &fput_needed);
 	if (sock != NULL) {
@@ -1695,11 +1697,10 @@ SYSCALL_DEFINE3(getpeername, int, fd, struct sockaddr __user *, usockaddr,
 			return err;
 		}
 
-		err =
-		    sock->ops->getname(sock, (struct sockaddr *)&address, &len,
-				       1);
-		if (!err)
-			err = move_addr_to_user(&address, len, usockaddr,
+		err = sock->ops->getname(sock, (struct sockaddr *)&address, 1);
+		if (err >= 0)
+			/* "err" is actually length in this case */
+			err = move_addr_to_user(&address, err, usockaddr,
 						usockaddr_len);
 		fput_light(sock->file, fput_needed);
 	}
@@ -3166,17 +3167,15 @@ int kernel_connect(struct socket *sock, struct sockaddr *addr, int addrlen,
 }
 EXPORT_SYMBOL(kernel_connect);
 
-int kernel_getsockname(struct socket *sock, struct sockaddr *addr,
-			 int *addrlen)
+int kernel_getsockname(struct socket *sock, struct sockaddr *addr)
 {
-	return sock->ops->getname(sock, addr, addrlen, 0);
+	return sock->ops->getname(sock, addr, 0);
 }
 EXPORT_SYMBOL(kernel_getsockname);
 
-int kernel_getpeername(struct socket *sock, struct sockaddr *addr,
-			 int *addrlen)
+int kernel_getpeername(struct socket *sock, struct sockaddr *addr)
 {
-	return sock->ops->getname(sock, addr, addrlen, 1);
+	return sock->ops->getname(sock, addr, 1);
 }
 EXPORT_SYMBOL(kernel_getpeername);
 
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 6e432ecd7f99..806395687bb6 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1231,7 +1231,7 @@ static const struct sockaddr_in6 rpc_in6addr_loopback = {
  * negative errno is returned.
  */
 static int rpc_sockname(struct net *net, struct sockaddr *sap, size_t salen,
-			struct sockaddr *buf, int buflen)
+			struct sockaddr *buf)
 {
 	struct socket *sock;
 	int err;
@@ -1269,7 +1269,7 @@ static int rpc_sockname(struct net *net, struct sockaddr *sap, size_t salen,
 		goto out_release;
 	}
 
-	err = kernel_getsockname(sock, buf, &buflen);
+	err = kernel_getsockname(sock, buf);
 	if (err < 0) {
 		dprintk("RPC:       getsockname failed (%d)\n", err);
 		goto out_release;
@@ -1353,7 +1353,7 @@ int rpc_localaddr(struct rpc_clnt *clnt, struct sockaddr *buf, size_t buflen)
 	rcu_read_unlock();
 
 	rpc_set_port(sap, 0);
-	err = rpc_sockname(net, sap, salen, buf, buflen);
+	err = rpc_sockname(net, sap, salen, buf);
 	put_net(net);
 	if (err != 0)
 		/* Couldn't discover local address, return ANYADDR */
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 943f2a745cd5..08cd951aaeea 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -832,12 +832,13 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
 	}
 	set_bit(XPT_CONN, &svsk->sk_xprt.xpt_flags);
 
-	err = kernel_getpeername(newsock, sin, &slen);
+	err = kernel_getpeername(newsock, sin);
 	if (err < 0) {
 		net_warn_ratelimited("%s: peername failed (err %d)!\n",
 				     serv->sv_name, -err);
 		goto failed;		/* aborted connection or whatever */
 	}
+	slen = err;
 
 	/* Ideally, we would want to reject connections from unauthorized
 	 * hosts here, but when we get encryption, the IP of the host won't
@@ -866,7 +867,8 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
 	if (IS_ERR(newsvsk))
 		goto failed;
 	svc_xprt_set_remote(&newsvsk->sk_xprt, sin, slen);
-	err = kernel_getsockname(newsock, sin, &slen);
+	err = kernel_getsockname(newsock, sin);
+	slen = err;
 	if (unlikely(err < 0)) {
 		dprintk("svc_tcp_accept: kernel_getsockname error %d\n", -err);
 		slen = offsetof(struct sockaddr, sa_data);
@@ -1465,7 +1467,8 @@ int svc_addsock(struct svc_serv *serv, const int fd, char *name_return,
 		err = PTR_ERR(svsk);
 		goto out;
 	}
-	if (kernel_getsockname(svsk->sk_sock, sin, &salen) == 0)
+	salen = kernel_getsockname(svsk->sk_sock, sin);
+	if (salen >= 0)
 		svc_xprt_set_local(&svsk->sk_xprt, sin, salen);
 	svc_add_new_perm_xprt(serv, &svsk->sk_xprt);
 	return svc_one_sock_name(svsk, name_return, len);
@@ -1539,10 +1542,10 @@ static struct svc_xprt *svc_create_socket(struct svc_serv *serv,
 	if (error < 0)
 		goto bummer;
 
-	newlen = len;
-	error = kernel_getsockname(sock, newsin, &newlen);
+	error = kernel_getsockname(sock, newsin);
 	if (error < 0)
 		goto bummer;
+	newlen = error;
 
 	if (protocol == IPPROTO_TCP) {
 		if ((error = kernel_listen(sock, 64)) < 0)
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index a6b8c1f8f92a..956e29c1438d 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1794,10 +1794,9 @@ static void xs_sock_set_reuseport(struct socket *sock)
 static unsigned short xs_sock_getport(struct socket *sock)
 {
 	struct sockaddr_storage buf;
-	int buflen;
 	unsigned short port = 0;
 
-	if (kernel_getsockname(sock, (struct sockaddr *)&buf, &buflen) < 0)
+	if (kernel_getsockname(sock, (struct sockaddr *)&buf) < 0)
 		goto out;
 	switch (buf.ss_family) {
 	case AF_INET6:
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index b0323ec7971e..f93477187a90 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -665,7 +665,7 @@ static int tipc_bind(struct socket *sock, struct sockaddr *uaddr,
  *       a completely predictable manner).
  */
 static int tipc_getname(struct socket *sock, struct sockaddr *uaddr,
-			int *uaddr_len, int peer)
+			int peer)
 {
 	struct sockaddr_tipc *addr = (struct sockaddr_tipc *)uaddr;
 	struct sock *sk = sock->sk;
@@ -684,13 +684,12 @@ static int tipc_getname(struct socket *sock, struct sockaddr *uaddr,
 		addr->addr.id.node = tn->own_addr;
 	}
 
-	*uaddr_len = sizeof(*addr);
 	addr->addrtype = TIPC_ADDR_ID;
 	addr->family = AF_TIPC;
 	addr->scope = 0;
 	addr->addr.name.domain = 0;
 
-	return 0;
+	return sizeof(*addr);
 }
 
 /**
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index d545e1d0dea2..723698416242 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -637,7 +637,7 @@ static int unix_stream_connect(struct socket *, struct sockaddr *,
 			       int addr_len, int flags);
 static int unix_socketpair(struct socket *, struct socket *);
 static int unix_accept(struct socket *, struct socket *, int, bool);
-static int unix_getname(struct socket *, struct sockaddr *, int *, int);
+static int unix_getname(struct socket *, struct sockaddr *, int);
 static __poll_t unix_poll(struct file *, struct socket *, poll_table *);
 static __poll_t unix_dgram_poll(struct file *, struct socket *,
 				    poll_table *);
@@ -1453,7 +1453,7 @@ static int unix_accept(struct socket *sock, struct socket *newsock, int flags,
 }
 
 
-static int unix_getname(struct socket *sock, struct sockaddr *uaddr, int *uaddr_len, int peer)
+static int unix_getname(struct socket *sock, struct sockaddr *uaddr, int peer)
 {
 	struct sock *sk = sock->sk;
 	struct unix_sock *u;
@@ -1476,12 +1476,12 @@ static int unix_getname(struct socket *sock, struct sockaddr *uaddr, int *uaddr_
 	if (!u->addr) {
 		sunaddr->sun_family = AF_UNIX;
 		sunaddr->sun_path[0] = 0;
-		*uaddr_len = sizeof(short);
+		err = sizeof(short);
 	} else {
 		struct unix_address *addr = u->addr;
 
-		*uaddr_len = addr->len;
-		memcpy(sunaddr, addr->name, *uaddr_len);
+		err = addr->len;
+		memcpy(sunaddr, addr->name, addr->len);
 	}
 	unix_state_unlock(sk);
 	sock_put(sk);
diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index e0fc84daed94..aac9b8f6552e 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -759,7 +759,7 @@ vsock_bind(struct socket *sock, struct sockaddr *addr, int addr_len)
 }
 
 static int vsock_getname(struct socket *sock,
-			 struct sockaddr *addr, int *addr_len, int peer)
+			 struct sockaddr *addr, int peer)
 {
 	int err;
 	struct sock *sk;
@@ -794,7 +794,7 @@ static int vsock_getname(struct socket *sock,
 	 */
 	BUILD_BUG_ON(sizeof(*vm_addr) > 128);
 	memcpy(addr, vm_addr, sizeof(*vm_addr));
-	*addr_len = sizeof(*vm_addr);
+	err = sizeof(*vm_addr);
 
 out:
 	release_sock(sk);
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 562cc11131f6..d49aa79b7997 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -896,7 +896,7 @@ static int x25_accept(struct socket *sock, struct socket *newsock, int flags,
 }
 
 static int x25_getname(struct socket *sock, struct sockaddr *uaddr,
-		       int *uaddr_len, int peer)
+		       int peer)
 {
 	struct sockaddr_x25 *sx25 = (struct sockaddr_x25 *)uaddr;
 	struct sock *sk = sock->sk;
@@ -913,7 +913,7 @@ static int x25_getname(struct socket *sock, struct sockaddr *uaddr,
 		sx25->sx25_addr = x25->source_addr;
 
 	sx25->sx25_family = AF_X25;
-	*uaddr_len = sizeof(*sx25);
+	rc = sizeof(*sx25);
 
 out:
 	return rc;
diff --git a/security/tomoyo/network.c b/security/tomoyo/network.c
index cd6932e5225c..9094f4b3b367 100644
--- a/security/tomoyo/network.c
+++ b/security/tomoyo/network.c
@@ -655,10 +655,11 @@ int tomoyo_socket_listen_permission(struct socket *sock)
 		return 0;
 	{
 		const int error = sock->ops->getname(sock, (struct sockaddr *)
-						     &addr, &addr_len, 0);
+						     &addr, 0);
 
-		if (error)
+		if (error < 0)
 			return error;
+		addr_len = error;
 	}
 	address.protocol = type;
 	address.operation = TOMOYO_NETWORK_LISTEN;
-- 
2.16.1

