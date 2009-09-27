From: Jeff Layton <jlayton@redhat.com>
Subject: [RFC PATCH 6/9] sunrpc: add new SMB transport class for sunrpc
Date: Sun, 27 Sep 2009 12:50:27 -0400
Message-ID: <1254070230-13125-7-git-send-email-jlayton@redhat.com>
References: <1254070230-13125-1-git-send-email-jlayton@redhat.com>
To: linux-nfs@vger.kernel.org, linux-cifs-client@lists.samba.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.120]:54616 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752863AbZI0Q5P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Sep 2009 12:57:15 -0400
In-Reply-To: <1254070230-13125-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a new transport class for SMB traffic that lives in xprtsmb.c and
a corresponding header file for making use of it.

With this, it's possible to use the sunrpc layer to send and receive
SMB traffic.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/sunrpc/xprtsmb.h |   59 ++
 net/sunrpc/xprtsmb.c           | 1720 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 1779 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/sunrpc/xprtsmb.h
 create mode 100644 net/sunrpc/xprtsmb.c

diff --git a/include/linux/sunrpc/xprtsmb.h b/include/linux/sunrpc/xprtsmb.h
new file mode 100644
index 0000000..d55e85b
--- /dev/null
+++ b/include/linux/sunrpc/xprtsmb.h
@@ -0,0 +1,59 @@
+/*
+ *   net/sunrpc/xprtsmb.h -- SMB transport for sunrpc
+ *
+ *   Copyright (c) 2009 Red Hat, Inc.
+ *   Author(s): Jeff Layton (jlayton@redhat.com)
+ *
+ *   This library is free software; you can redistribute it and/or modify
+ *   it under the terms of the GNU Lesser General Public License as published
+ *   by the Free Software Foundation; either version 2.1 of the License, or
+ *   (at your option) any later version.
+ *
+ *   This library is distributed in the hope that it will be useful,
+ *   but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ *   the GNU Lesser General Public License for more details.
+ *
+ *   You should have received a copy of the GNU Lesser General Public License
+ *   along with this library; if not, write to the Free Software
+ *   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ */
+
+/*
+ * xprtsmb.h
+ *
+ * This file contains the public interfaces for the SMB transport for
+ * the sunrpc layer.
+ */
+
+#ifndef _LINUX_SUNRPC_XPRTSMB_H
+#define _LINUX_SUNRPC_XPRTSMB_H
+
+/*
+ * RPC transport identifier for SMB
+ */
+#define XPRT_TRANSPORT_SMB	1024
+
+int init_smb_xprt(void);
+void cleanup_smb_xprt(void);
+
+/* standard SMB header */
+struct smb_header {
+	__u8		protocol[4];
+	__u8		command;
+	__le32		status;
+	__u8		flags;
+	__le16		flags2;
+	__le16		pidhigh;
+	__u8		signature[8];
+	__u8		pad[2];
+	__le16		tid;
+	__le16		pid;
+	__le16		uid;
+	__le16		mid;
+} __attribute__((packed));
+
+/* SMB Header Flags of interest */
+#define SMBFLG_RESPONSE 0x80	/* response from server */
+
+#endif /* _LINUX_SUNRPC_XPRTSMB_H */
diff --git a/net/sunrpc/xprtsmb.c b/net/sunrpc/xprtsmb.c
new file mode 100644
index 0000000..585cf37
--- /dev/null
+++ b/net/sunrpc/xprtsmb.c
@@ -0,0 +1,1720 @@
+/*
+ * linux/net/sunrpc/xprtsmb.c
+ *
+ * Client-side transport implementation for SMB sockets.
+ *
+ * (C) 1998 Red Hat
+ * Initial revision by Jeff Layton <jlayton@redhat.com>
+ *
+ * Heavily based on net/sunrpc/xprtsock.c -- copyrights from that file below:
+ *
+ * TCP callback races fixes (C) 1998 Red Hat
+ * TCP send fixes (C) 1998 Red Hat
+ * TCP NFS related read + write fixes
+ *  (C) 1999 Dave Airlie, University of Limerick, Ireland <airlied-cv59FeDIM0c@public.gmane.org>
+ *
+ * Rewrite of larges part of the code in order to stabilize TCP stuff.
+ * Fix behaviour when socket buffer is full.
+ *  (C) 1999 Trond Myklebust <trond.myklebust@fys.uio.no>
+ *
+ * IP socket transport implementation, (C) 2005 Chuck Lever <cel@netapp.com>
+ *
+ * IPv6 support contributed by Gilles Quillard, Bull Open Source, 2005.
+ *   <gilles.quillard@bull.net>
+ *
+ */
+
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/module.h>
+#include <linux/capability.h>
+#include <linux/pagemap.h>
+#include <linux/errno.h>
+#include <linux/socket.h>
+#include <linux/in.h>
+#include <linux/net.h>
+#include <linux/mm.h>
+#include <linux/tcp.h>
+#include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/sched.h>
+#include <linux/sunrpc/xprtsmb.h>
+#include <linux/sunrpc/xprtsock.h>
+#include <linux/file.h>
+#ifdef CONFIG_NFS_V4_1
+#include <linux/sunrpc/bc_xprt.h>
+#endif
+
+#include <net/sock.h>
+#include <net/checksum.h>
+#include <net/tcp.h>
+
+/* CIFS currently defaults to allowing 50 outstanding calls at a time */
+#define SMB_DEF_SLOT_TABLE	50
+
+/*
+ * top byte of the 32-bit SMB "fragment header" is always 0. That gives a max
+ * size for a SMB packet of 2^24-1
+ */
+#define	SMB_FRAGMENT_SIZE_MASK	0x00ffffff
+#define	SMB_MAX_FRAGMENT_SIZE	SMB_FRAGMENT_SIZE_MASK
+
+/*
+ * xprtsock tunables
+ */
+unsigned int xprt_smb_slot_table_entries = SMB_DEF_SLOT_TABLE;
+
+#define XS_TCP_LINGER_TO	(15U * HZ)
+static unsigned int xs_smb_fin_timeout __read_mostly = XS_TCP_LINGER_TO;
+
+/*
+ * We can register our own files under /proc/sys/sunrpc by
+ * calling register_sysctl_table() again.  The files in that
+ * directory become the union of all files registered there.
+ *
+ * We simply need to make sure that we don't collide with
+ * someone else's file names!
+ */
+
+#ifdef RPC_DEBUG
+
+static unsigned int min_slot_table_size = RPC_MIN_SLOT_TABLE;
+static unsigned int max_slot_table_size = RPC_MAX_SLOT_TABLE;
+
+static struct ctl_table_header *sunrpc_table_header;
+
+/*
+ * FIXME: changing the UDP slot table size should also resize the UDP
+ *        socket buffers for existing UDP transports
+ */
+static ctl_table xs_tunables_table[] = {
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "smb_slot_table_entries",
+		.data		= &xprt_smb_slot_table_entries,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &min_slot_table_size,
+		.extra2		= &max_slot_table_size
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "smb_fin_timeout",
+		.data		= &xs_smb_fin_timeout,
+		.maxlen		= sizeof(xs_smb_fin_timeout),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_jiffies,
+		.strategy	= sysctl_jiffies
+	},
+	{
+		.ctl_name = 0,
+	},
+};
+
+static ctl_table sunrpc_table[] = {
+	{
+		.ctl_name	= CTL_SUNRPC,
+		.procname	= "sunrpc",
+		.mode		= 0555,
+		.child		= xs_tunables_table
+	},
+	{
+		.ctl_name = 0,
+	},
+};
+
+#endif
+
+/*
+ * Wait duration for an RPC TCP connection to be established.  Solaris
+ * NFS over TCP uses 60 seconds, for example, which is in line with how
+ * long a server takes to reboot.
+ */
+#define XS_TCP_CONN_TO		(60U * HZ)
+
+/*
+ * Wait duration for a reply from the RPC portmapper.
+ */
+#define XS_BIND_TO		(60U * HZ)
+
+/*
+ * The reestablish timeout allows clients to delay for a bit before attempting
+ * to reconnect to a server that just dropped our connection.
+ *
+ * We implement an exponential backoff when trying to reestablish a TCP
+ * transport connection with the server.  Some servers like to drop a TCP
+ * connection when they are overworked, so we start with a short timeout and
+ * increase over time if the server is down or not responding.
+ */
+#define XS_TCP_INIT_REEST_TO	(3U * HZ)
+#define XS_TCP_MAX_REEST_TO	(5U * 60 * HZ)
+
+/*
+ * reconnecting a SMB socket is expensive, so we don't do idle timeouts if
+ * we can help it.
+ */
+#define XS_SMB_IDLE_DISC_TO     (~0UL)
+
+
+#ifdef RPC_DEBUG
+# undef  RPC_DEBUG_DATA
+# define RPCDBG_FACILITY	RPCDBG_TRANS
+#endif
+
+#ifdef RPC_DEBUG_DATA
+static void xs_pktdump(char *msg, u32 *packet, unsigned int count)
+{
+	u8 *buf = (u8 *) packet;
+	int j;
+
+	dprintk("RPC:       %s\n", msg);
+	for (j = 0; j < count && j < 128; j += 4) {
+		if (!(j & 31)) {
+			if (j)
+				dprintk("\n");
+			dprintk("0x%04x ", j);
+		}
+		dprintk("%02x%02x%02x%02x ",
+			buf[j], buf[j+1], buf[j+2], buf[j+3]);
+	}
+	dprintk("\n");
+}
+#else
+static inline void xs_pktdump(char *msg, u32 *packet, unsigned int count)
+{
+	/* NOP */
+}
+#endif
+
+struct smb_xprt {
+	struct rpc_xprt		xprt;
+
+	/*
+	 * Network layer
+	 */
+	struct socket *		sock;
+	struct sock *		inet;
+
+	/*
+	 * State of TCP reply receive
+	 */
+	__be32			tcp_fraghdr;
+	struct smb_header	smb_header;
+
+	u32			tcp_offset,
+				tcp_reclen;
+
+	unsigned long		tcp_copied,
+				tcp_flags;
+
+	/*
+	 * Connection of transports
+	 */
+	struct delayed_work	connect_worker;
+	struct sockaddr_storage	addr;
+	unsigned short		port;
+
+	/*
+	 * Saved socket callback addresses
+	 */
+	void			(*old_data_ready)(struct sock *, int);
+	void			(*old_state_change)(struct sock *);
+	void			(*old_write_space)(struct sock *);
+	void			(*old_error_report)(struct sock *);
+};
+
+/*
+ * TCP receive state flags
+ */
+#define TCP_RCV_COPY_FRAGHDR	(1UL << 0)
+#define TCP_RCV_READ_SMBHDR	(1UL << 1)
+#define TCP_RCV_COPY_SMBHDR	(1UL << 2)
+#define TCP_RCV_COPY_DATA	(1UL << 3)
+
+static inline struct sockaddr *xs_addr(struct rpc_xprt *xprt)
+{
+	return (struct sockaddr *) &xprt->addr;
+}
+
+static inline struct sockaddr_in *xs_addr_in(struct rpc_xprt *xprt)
+{
+	return (struct sockaddr_in *) &xprt->addr;
+}
+
+static inline struct sockaddr_in6 *xs_addr_in6(struct rpc_xprt *xprt)
+{
+	return (struct sockaddr_in6 *) &xprt->addr;
+}
+
+static void xs_format_common_peer_addresses(struct rpc_xprt *xprt)
+{
+	struct sockaddr *sap = xs_addr(xprt);
+	struct sockaddr_in6 *sin6;
+	struct sockaddr_in *sin;
+	char buf[128];
+
+	(void)rpc_ntop(sap, buf, sizeof(buf));
+	xprt->address_strings[RPC_DISPLAY_ADDR] = kstrdup(buf, GFP_KERNEL);
+
+	switch (sap->sa_family) {
+	case AF_INET:
+		sin = xs_addr_in(xprt);
+		(void)snprintf(buf, sizeof(buf), "%02x%02x%02x%02x",
+					NIPQUAD(sin->sin_addr.s_addr));
+		break;
+	case AF_INET6:
+		sin6 = xs_addr_in6(xprt);
+		(void)snprintf(buf, sizeof(buf), "%pi6", &sin6->sin6_addr);
+		break;
+	default:
+		BUG();
+	}
+	xprt->address_strings[RPC_DISPLAY_HEX_ADDR] = kstrdup(buf, GFP_KERNEL);
+}
+
+static void xs_format_common_peer_ports(struct rpc_xprt *xprt)
+{
+	struct sockaddr *sap = xs_addr(xprt);
+	char buf[128];
+
+	(void)snprintf(buf, sizeof(buf), "%u", rpc_get_port(sap));
+	xprt->address_strings[RPC_DISPLAY_PORT] = kstrdup(buf, GFP_KERNEL);
+
+	(void)snprintf(buf, sizeof(buf), "%4hx", rpc_get_port(sap));
+	xprt->address_strings[RPC_DISPLAY_HEX_PORT] = kstrdup(buf, GFP_KERNEL);
+}
+
+static void xs_format_peer_addresses(struct rpc_xprt *xprt,
+				     const char *protocol,
+				     const char *netid)
+{
+	xprt->address_strings[RPC_DISPLAY_PROTO] = protocol;
+	xprt->address_strings[RPC_DISPLAY_NETID] = netid;
+	xs_format_common_peer_addresses(xprt);
+	xs_format_common_peer_ports(xprt);
+}
+
+static void xs_free_peer_addresses(struct rpc_xprt *xprt)
+{
+	unsigned int i;
+
+	for (i = 0; i < RPC_DISPLAY_MAX; i++)
+		switch (i) {
+		case RPC_DISPLAY_PROTO:
+		case RPC_DISPLAY_NETID:
+			continue;
+		default:
+			kfree(xprt->address_strings[i]);
+		}
+}
+
+#define XS_SENDMSG_FLAGS	(MSG_DONTWAIT | MSG_NOSIGNAL)
+
+static int xs_send_kvec(struct socket *sock, struct sockaddr *addr, int addrlen, struct kvec *vec, unsigned int base, int more)
+{
+	struct msghdr msg = {
+		.msg_name	= addr,
+		.msg_namelen	= addrlen,
+		.msg_flags	= XS_SENDMSG_FLAGS | (more ? MSG_MORE : 0),
+	};
+	struct kvec iov = {
+		.iov_base	= vec->iov_base + base,
+		.iov_len	= vec->iov_len - base,
+	};
+
+	if (iov.iov_len != 0)
+		return kernel_sendmsg(sock, &msg, &iov, 1, iov.iov_len);
+	return kernel_sendmsg(sock, &msg, NULL, 0, 0);
+}
+
+static int xs_send_pagedata(struct socket *sock, struct xdr_buf *xdr, unsigned int base, int more)
+{
+	struct page **ppage;
+	unsigned int remainder;
+	int err, sent = 0;
+
+	remainder = xdr->page_len - base;
+	base += xdr->page_base;
+	ppage = xdr->pages + (base >> PAGE_SHIFT);
+	base &= ~PAGE_MASK;
+	for(;;) {
+		unsigned int len = min_t(unsigned int, PAGE_SIZE - base, remainder);
+		int flags = XS_SENDMSG_FLAGS;
+
+		remainder -= len;
+		if (remainder != 0 || more)
+			flags |= MSG_MORE;
+		err = sock->ops->sendpage(sock, *ppage, base, len, flags);
+		if (remainder == 0 || err != len)
+			break;
+		sent += err;
+		ppage++;
+		base = 0;
+	}
+	if (sent == 0)
+		return err;
+	if (err > 0)
+		sent += err;
+	return sent;
+}
+
+/**
+ * xs_sendpages - write pages directly to a socket
+ * @sock: socket to send on
+ * @addr: UDP only -- address of destination
+ * @addrlen: UDP only -- length of destination address
+ * @xdr: buffer containing this request
+ * @base: starting position in the buffer
+ *
+ */
+static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen, struct xdr_buf *xdr, unsigned int base)
+{
+	unsigned int remainder = xdr->len - base;
+	int err, sent = 0;
+
+	if (unlikely(!sock))
+		return -ENOTSOCK;
+
+	clear_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
+	if (base != 0) {
+		addr = NULL;
+		addrlen = 0;
+	}
+
+	if (base < xdr->head[0].iov_len || addr != NULL) {
+		unsigned int len = xdr->head[0].iov_len - base;
+		remainder -= len;
+		err = xs_send_kvec(sock, addr, addrlen, &xdr->head[0], base, remainder != 0);
+		if (remainder == 0 || err != len)
+			goto out;
+		sent += err;
+		base = 0;
+	} else
+		base -= xdr->head[0].iov_len;
+
+	if (base < xdr->page_len) {
+		unsigned int len = xdr->page_len - base;
+		remainder -= len;
+		err = xs_send_pagedata(sock, xdr, base, remainder != 0);
+		if (remainder == 0 || err != len)
+			goto out;
+		sent += err;
+		base = 0;
+	} else
+		base -= xdr->page_len;
+
+	if (base >= xdr->tail[0].iov_len)
+		return sent;
+	err = xs_send_kvec(sock, NULL, 0, &xdr->tail[0], base, 0);
+out:
+	if (sent == 0)
+		return err;
+	if (err > 0)
+		sent += err;
+	return sent;
+}
+
+static void xs_nospace_callback(struct rpc_task *task)
+{
+	struct smb_xprt *transport = container_of(task->tk_rqstp->rq_xprt, struct smb_xprt, xprt);
+
+	transport->inet->sk_write_pending--;
+	clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
+}
+
+/**
+ * xs_nospace - place task on wait queue if transmit was incomplete
+ * @task: task to put to sleep
+ *
+ */
+static int xs_nospace(struct rpc_task *task)
+{
+	struct rpc_rqst *req = task->tk_rqstp;
+	struct rpc_xprt *xprt = req->rq_xprt;
+	struct smb_xprt *transport = container_of(xprt, struct smb_xprt, xprt);
+	int ret = 0;
+
+	dprintk("RPC: %5u xmit incomplete (%u left of %u)\n",
+			task->tk_pid, req->rq_slen - req->rq_bytes_sent,
+			req->rq_slen);
+
+	/* Protect against races with write_space */
+	spin_lock_bh(&xprt->transport_lock);
+
+	/* Don't race with disconnect */
+	if (xprt_connected(xprt)) {
+		if (test_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags)) {
+			ret = -EAGAIN;
+			/*
+			 * Notify TCP that we're limited by the application
+			 * window size
+			 */
+			set_bit(SOCK_NOSPACE, &transport->sock->flags);
+			transport->inet->sk_write_pending++;
+			/* ...and wait for more buffer space */
+			xprt_wait_for_buffer_space(task, xs_nospace_callback);
+		}
+	} else {
+		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
+		ret = -ENOTCONN;
+	}
+
+	spin_unlock_bh(&xprt->transport_lock);
+	return ret;
+}
+
+/**
+ * xs_tcp_shutdown - gracefully shut down a TCP socket
+ * @xprt: transport
+ *
+ * Initiates a graceful shutdown of the TCP socket by calling the
+ * equivalent of shutdown(SHUT_WR);
+ */
+static void xs_tcp_shutdown(struct rpc_xprt *xprt)
+{
+	struct smb_xprt *transport = container_of(xprt, struct smb_xprt, xprt);
+	struct socket *sock = transport->sock;
+
+	if (sock != NULL)
+		kernel_sock_shutdown(sock, SHUT_WR);
+}
+
+static inline void xs_encode_smb_record_marker(struct xdr_buf *buf)
+{
+	u32 reclen = buf->len - sizeof(rpc_fraghdr);
+	rpc_fraghdr *base = buf->head[0].iov_base;
+	*base = htonl(SMB_FRAGMENT_SIZE_MASK & reclen);
+}
+
+/**
+ * xs_smb_send_request - write an RPC request to a TCP socket
+ * @task: address of RPC task that manages the state of an RPC request
+ *
+ * Return values:
+ *        0:	The request has been sent
+ *   EAGAIN:	The socket was blocked, please call again later to
+ *		complete the request
+ * ENOTCONN:	Caller needs to invoke connect logic then call again
+ *    other:	Some other error occured, the request was not sent
+ *
+ * XXX: In the case of soft timeouts, should we eventually give up
+ *	if sendmsg is not able to make progress?
+ */
+static int xs_smb_send_request(struct rpc_task *task)
+{
+	struct rpc_rqst *req = task->tk_rqstp;
+	struct rpc_xprt *xprt = req->rq_xprt;
+	struct smb_xprt *transport = container_of(xprt, struct smb_xprt, xprt);
+	struct xdr_buf *xdr = &req->rq_snd_buf;
+	int status;
+
+	xs_encode_smb_record_marker(&req->rq_snd_buf);
+
+	xs_pktdump("packet data:",
+				req->rq_svec->iov_base,
+				req->rq_svec->iov_len);
+
+	/* Continue transmitting the packet/record. We must be careful
+	 * to cope with writespace callbacks arriving _after_ we have
+	 * called sendmsg(). */
+	while (1) {
+		status = xs_sendpages(transport->sock,
+					NULL, 0, xdr, req->rq_bytes_sent);
+
+		dprintk("RPC:       %s(%u) = %d\n", __func__,
+				xdr->len - req->rq_bytes_sent, status);
+
+		if (unlikely(status < 0))
+			break;
+
+		/* If we've sent the entire packet, immediately
+		 * reset the count of bytes sent. */
+		req->rq_bytes_sent += status;
+		task->tk_bytes_sent += status;
+		if (likely(req->rq_bytes_sent >= req->rq_slen)) {
+			req->rq_bytes_sent = 0;
+			return 0;
+		}
+
+		if (status != 0)
+			continue;
+		status = -EAGAIN;
+		break;
+	}
+	if (!transport->sock)
+		goto out;
+
+	switch (status) {
+	case -ENOTSOCK:
+		status = -ENOTCONN;
+		/* Should we call xs_close() here? */
+		break;
+	case -EAGAIN:
+		status = xs_nospace(task);
+		break;
+	default:
+		dprintk("RPC:       sendmsg returned unrecognized error %d\n",
+			-status);
+	case -ECONNRESET:
+	case -EPIPE:
+		xs_tcp_shutdown(xprt);
+	case -ECONNREFUSED:
+	case -ENOTCONN:
+		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
+	}
+out:
+	return status;
+}
+
+/**
+ * xs_tcp_release_xprt - clean up after a tcp transmission
+ * @xprt: transport
+ * @task: rpc task
+ *
+ * This cleans up if an error causes us to abort the transmission of a request.
+ * In this case, the socket may need to be reset in order to avoid confusing
+ * the server.
+ */
+static void xs_tcp_release_xprt(struct rpc_xprt *xprt, struct rpc_task *task)
+{
+	struct rpc_rqst *req;
+
+	if (task != xprt->snd_task)
+		return;
+	if (task == NULL)
+		goto out_release;
+	req = task->tk_rqstp;
+	if (req->rq_bytes_sent == 0)
+		goto out_release;
+	if (req->rq_bytes_sent == req->rq_snd_buf.len)
+		goto out_release;
+	set_bit(XPRT_CLOSE_WAIT, &task->tk_xprt->state);
+out_release:
+	xprt_release_xprt(xprt, task);
+}
+
+static void xs_save_old_callbacks(struct smb_xprt *transport, struct sock *sk)
+{
+	transport->old_data_ready = sk->sk_data_ready;
+	transport->old_state_change = sk->sk_state_change;
+	transport->old_write_space = sk->sk_write_space;
+	transport->old_error_report = sk->sk_error_report;
+}
+
+static void xs_restore_old_callbacks(struct smb_xprt *transport, struct sock *sk)
+{
+	sk->sk_data_ready = transport->old_data_ready;
+	sk->sk_state_change = transport->old_state_change;
+	sk->sk_write_space = transport->old_write_space;
+	sk->sk_error_report = transport->old_error_report;
+}
+
+static void xs_reset_transport(struct smb_xprt *transport)
+{
+	struct socket *sock = transport->sock;
+	struct sock *sk = transport->inet;
+
+	if (sk == NULL)
+		return;
+
+	write_lock_bh(&sk->sk_callback_lock);
+	transport->inet = NULL;
+	transport->sock = NULL;
+
+	sk->sk_user_data = NULL;
+
+	xs_restore_old_callbacks(transport, sk);
+	write_unlock_bh(&sk->sk_callback_lock);
+
+	sk->sk_no_check = 0;
+
+	sock_release(sock);
+}
+
+/**
+ * xs_close - close a socket
+ * @xprt: transport
+ *
+ * This is used when all requests are complete; ie, no DRC state remains
+ * on the server we want to save.
+ *
+ * The caller _must_ be holding XPRT_LOCKED in order to avoid issues with
+ * xs_reset_transport() zeroing the socket from underneath a writer.
+ */
+static void xs_close(struct rpc_xprt *xprt)
+{
+	struct smb_xprt *transport = container_of(xprt, struct smb_xprt, xprt);
+
+	dprintk("RPC:       xs_close xprt %p\n", xprt);
+
+	xs_reset_transport(transport);
+
+	smp_mb__before_clear_bit();
+	clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
+	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
+	clear_bit(XPRT_CLOSING, &xprt->state);
+	smp_mb__after_clear_bit();
+	xprt_disconnect_done(xprt);
+}
+
+static void xs_tcp_close(struct rpc_xprt *xprt)
+{
+	if (test_and_clear_bit(XPRT_CONNECTION_CLOSE, &xprt->state))
+		xs_close(xprt);
+	else
+		xs_tcp_shutdown(xprt);
+}
+
+/**
+ * xs_destroy - prepare to shutdown a transport
+ * @xprt: doomed transport
+ *
+ */
+static void xs_destroy(struct rpc_xprt *xprt)
+{
+	struct smb_xprt *transport = container_of(xprt, struct smb_xprt, xprt);
+
+	dprintk("RPC:       xs_destroy xprt %p\n", xprt);
+
+	cancel_rearming_delayed_work(&transport->connect_worker);
+
+	xs_close(xprt);
+	xs_free_peer_addresses(xprt);
+	kfree(xprt->slot);
+	kfree(xprt);
+	module_put(THIS_MODULE);
+}
+
+static inline struct rpc_xprt *xprt_from_sock(struct sock *sk)
+{
+	return (struct rpc_xprt *) sk->sk_user_data;
+}
+
+static inline void xs_smb_read_fraghdr(struct rpc_xprt *xprt, struct xdr_skb_reader *desc)
+{
+	struct smb_xprt *transport = container_of(xprt, struct smb_xprt, xprt);
+	size_t len, used;
+	char *p;
+
+	p = ((char *) &transport->tcp_fraghdr) + transport->tcp_offset;
+	len = sizeof(transport->tcp_fraghdr) - transport->tcp_offset;
+	used = xdr_skb_read_bits(desc, p, len);
+	transport->tcp_offset += used;
+	if (used != len)
+		return;
+
+	transport->tcp_reclen = ntohl(transport->tcp_fraghdr);
+	if (transport->tcp_reclen & ~SMB_FRAGMENT_SIZE_MASK) {
+		dprintk("SMB:       top byte of fragheader invalid\n");
+		xprt_force_disconnect(xprt);
+		return;
+	}
+
+	transport->tcp_reclen &= SMB_FRAGMENT_SIZE_MASK;
+
+	transport->tcp_flags = TCP_RCV_READ_SMBHDR;
+	transport->tcp_offset = 0;
+
+	/* Sanity check of the record length */
+	if (unlikely(transport->tcp_reclen < sizeof(struct smb_header))) {
+		dprintk("RPC:       invalid SMB record fragment length\n");
+		xprt_force_disconnect(xprt);
+		return;
+	}
+	dprintk("RPC:       reading SMB record fragment of length %d\n",
+			transport->tcp_reclen);
+}
+
+static void xs_smb_check_fraghdr(struct smb_xprt *transport)
+{
+	if (transport->tcp_offset == transport->tcp_reclen) {
+		transport->tcp_flags = TCP_RCV_COPY_FRAGHDR;
+		transport->tcp_offset = 0;
+		transport->tcp_copied = 0;
+	}
+}
+
+static inline void xs_smb_read_smbhdr(struct smb_xprt *transport, struct xdr_skb_reader *desc)
+{
+	size_t len, used;
+	char *p;
+
+	len = sizeof(transport->smb_header) - transport->tcp_offset;
+	dprintk("SMB:       reading SMB header (%Zu bytes)\n", len);
+	p = ((char *) &transport->smb_header) + transport->tcp_offset;
+	used = xdr_skb_read_bits(desc, p, len);
+	transport->tcp_offset += used;
+	if (used != len)
+		return;
+	transport->tcp_flags = TCP_RCV_COPY_SMBHDR | TCP_RCV_COPY_DATA;
+
+	if (transport->smb_header.flags & SMBFLG_RESPONSE)
+	dprintk("SMB:       reading %s MID 0x%04x\n",
+			(transport->smb_header.flags & SMBFLG_RESPONSE) ?
+			"reply for" : "request with",
+			le16_to_cpu(transport->smb_header.mid));
+
+	xs_smb_check_fraghdr(transport);
+}
+
+static inline void xs_smb_read_common(struct rpc_xprt *xprt,
+				     struct xdr_skb_reader *desc,
+				     struct rpc_rqst *req)
+{
+	struct smb_xprt *transport =
+				container_of(xprt, struct smb_xprt, xprt);
+	struct xdr_buf *rcvbuf;
+	size_t len;
+	ssize_t r;
+
+	rcvbuf = &req->rq_private_buf;
+
+	/* copy SMB header into buffer */
+	if (transport->tcp_flags & TCP_RCV_COPY_SMBHDR) {
+		memcpy(rcvbuf->head[0].iov_base, &transport->smb_header,
+			sizeof(transport->smb_header));
+		transport->tcp_copied += sizeof(transport->smb_header);
+		transport->tcp_flags &= ~TCP_RCV_COPY_SMBHDR;
+	}
+
+	len = desc->count;
+	if (len > transport->tcp_reclen - transport->tcp_offset) {
+		struct xdr_skb_reader my_desc;
+
+		len = transport->tcp_reclen - transport->tcp_offset;
+		memcpy(&my_desc, desc, sizeof(my_desc));
+		my_desc.count = len;
+		r = xdr_partial_copy_from_skb(rcvbuf, transport->tcp_copied,
+					  &my_desc, xdr_skb_read_bits);
+		desc->count -= r;
+		desc->offset += r;
+	} else
+		r = xdr_partial_copy_from_skb(rcvbuf, transport->tcp_copied,
+					  desc, xdr_skb_read_bits);
+
+	if (r > 0) {
+		transport->tcp_copied += r;
+		transport->tcp_offset += r;
+	}
+	if (r != len) {
+		/* Error when copying to the receive buffer,
+		 * usually because we weren't able to allocate
+		 * additional buffer pages. All we can do now
+		 * is turn off TCP_RCV_COPY_DATA, so the request
+		 * will not receive any additional updates,
+		 * and time out.
+		 * Any remaining data from this record will
+		 * be discarded.
+		 */
+		transport->tcp_flags &= ~TCP_RCV_COPY_DATA;
+		dprintk("RPC:       XID %08x truncated request\n",
+				ntohl(transport->smb_header.mid));
+		dprintk("RPC:       xprt = %p, tcp_copied = %lu, "
+				"tcp_offset = %u, tcp_reclen = %u\n",
+				xprt, transport->tcp_copied,
+				transport->tcp_offset, transport->tcp_reclen);
+		return;
+	}
+
+	dprintk("RPC:       XID %08x read %Zd bytes\n",
+			ntohl(transport->smb_header.mid), r);
+	dprintk("RPC:       xprt = %p, tcp_copied = %lu, tcp_offset = %u, "
+			"tcp_reclen = %u\n", xprt, transport->tcp_copied,
+			transport->tcp_offset, transport->tcp_reclen);
+
+	if (transport->tcp_copied == req->rq_private_buf.buflen ||
+	    transport->tcp_offset == transport->tcp_reclen)
+		transport->tcp_flags &= ~TCP_RCV_COPY_DATA;
+
+	return;
+}
+
+/*
+ * Finds the request corresponding to the RPC xid and invokes the common
+ * tcp read code to read the data.
+ */
+static inline int xs_smb_read_reply(struct rpc_xprt *xprt,
+				    struct xdr_skb_reader *desc)
+{
+	struct smb_xprt *transport =
+				container_of(xprt, struct smb_xprt, xprt);
+	struct rpc_rqst *req;
+
+	dprintk("RPC:       read reply XID %08x\n", ntohl(transport->smb_header.mid));
+
+	/* Find and lock the request corresponding to this xid */
+	spin_lock(&xprt->transport_lock);
+	req = xprt_lookup_rqst(xprt, transport->smb_header.mid);
+	if (!req) {
+		dprintk("RPC:       XID %08x request not found!\n",
+				ntohl(transport->smb_header.mid));
+		spin_unlock(&xprt->transport_lock);
+		return -1;
+	}
+
+	xs_smb_read_common(xprt, desc, req);
+
+	if (!(transport->tcp_flags & TCP_RCV_COPY_DATA))
+		xprt_complete_rqst(req->rq_task, transport->tcp_copied);
+
+	spin_unlock(&xprt->transport_lock);
+	return 0;
+}
+
+#if defined(CONFIG_NFS_V4_1)
+/*
+ * Obtains an rpc_rqst previously allocated and invokes the common
+ * tcp read code to read the data.  The result is placed in the callback
+ * queue.
+ * If we're unable to obtain the rpc_rqst we schedule the closing of the
+ * connection and return -1.
+ */
+static inline int xs_smb_read_callback(struct rpc_xprt *xprt,
+				       struct xdr_skb_reader *desc)
+{
+	struct smb_xprt *transport =
+				container_of(xprt, struct smb_xprt, xprt);
+	struct rpc_rqst *req;
+
+	req = xprt_alloc_bc_request(xprt);
+	if (req == NULL) {
+		printk(KERN_WARNING "Callback slot table overflowed\n");
+		xprt_force_disconnect(xprt);
+		return -1;
+	}
+
+	req->rq_xid = transport->smb_header.mid;
+	dprintk("RPC:       read callback  XID %08x\n", ntohl(req->rq_xid));
+	xs_smb_read_common(xprt, desc, req);
+
+	if (!(transport->tcp_flags & TCP_RCV_COPY_DATA)) {
+		struct svc_serv *bc_serv = xprt->bc_serv;
+
+		/*
+		 * Add callback request to callback list.  The callback
+		 * service sleeps on the sv_cb_waitq waiting for new
+		 * requests.  Wake it up after adding enqueing the
+		 * request.
+		 */
+		dprintk("RPC:       add callback request to list\n");
+		spin_lock(&bc_serv->sv_cb_lock);
+		list_add(&req->rq_bc_list, &bc_serv->sv_cb_list);
+		spin_unlock(&bc_serv->sv_cb_lock);
+		wake_up(&bc_serv->sv_cb_waitq);
+	}
+
+	req->rq_private_buf.len = transport->tcp_copied;
+
+	return 0;
+}
+
+static inline int _xs_smb_read_data(struct rpc_xprt *xprt,
+					struct xdr_skb_reader *desc)
+{
+	struct smb_xprt *transport =
+				container_of(xprt, struct smb_xprt, xprt);
+
+	return (transport->smb_header.flags & SMBFLG_RESPONSE) ?
+		xs_smb_read_reply(xprt, desc) :
+		xs_smb_read_callback(xprt, desc);
+}
+#else
+static inline int _xs_smb_read_data(struct rpc_xprt *xprt,
+					struct xdr_skb_reader *desc)
+{
+	return xs_smb_read_reply(xprt, desc);
+}
+#endif /* CONFIG_NFS_V4_1 */
+
+/*
+ * Read data off the transport.  This can be either an RPC_CALL or an
+ * RPC_REPLY.  Relay the processing to helper functions.
+ */
+static void xs_smb_read_data(struct rpc_xprt *xprt,
+				    struct xdr_skb_reader *desc)
+{
+	struct smb_xprt *transport =
+				container_of(xprt, struct smb_xprt, xprt);
+
+	if (_xs_smb_read_data(xprt, desc) == 0)
+		xs_smb_check_fraghdr(transport);
+	else {
+		/*
+		 * The transport_lock protects the request handling.
+		 * There's no need to hold it to update the tcp_flags.
+		 */
+		transport->tcp_flags &= ~TCP_RCV_COPY_DATA;
+	}
+}
+
+static inline void xs_smb_read_discard(struct smb_xprt *transport, struct xdr_skb_reader *desc)
+{
+	size_t len;
+
+	len = transport->tcp_reclen - transport->tcp_offset;
+	if (len > desc->count)
+		len = desc->count;
+	desc->count -= len;
+	desc->offset += len;
+	transport->tcp_offset += len;
+	dprintk("RPC:       discarded %Zu bytes\n", len);
+	xs_smb_check_fraghdr(transport);
+}
+
+static int xs_smb_data_recv(read_descriptor_t *rd_desc, struct sk_buff *skb, unsigned int offset, size_t len)
+{
+	struct rpc_xprt *xprt = rd_desc->arg.data;
+	struct smb_xprt *transport = container_of(xprt, struct smb_xprt, xprt);
+	struct xdr_skb_reader desc = {
+		.skb	= skb,
+		.offset	= offset,
+		.count	= len,
+	};
+
+	dprintk("RPC:       xs_tcp_data_recv started\n");
+	do {
+		dprintk("SMB:       %s tcp_flags=0x%lx\n", __func__,
+			transport->tcp_flags);
+		/* Read in a new fragment marker if necessary */
+		/* Can we ever really expect to get completely empty fragments? */
+		if (transport->tcp_flags & TCP_RCV_COPY_FRAGHDR) {
+			xs_smb_read_fraghdr(xprt, &desc);
+			continue;
+		}
+		/* Read in the xid if necessary */
+		if (transport->tcp_flags & TCP_RCV_READ_SMBHDR) {
+			xs_smb_read_smbhdr(transport, &desc);
+			continue;
+		}
+		/* Read in the request data */
+		if (transport->tcp_flags & TCP_RCV_COPY_DATA) {
+			xs_smb_read_data(xprt, &desc);
+			continue;
+		}
+		/* Skip over any trailing bytes on short reads */
+		xs_smb_read_discard(transport, &desc);
+	} while (desc.count);
+	dprintk("RPC:       xs_tcp_data_recv done\n");
+	return len - desc.count;
+}
+
+/**
+ * xs_smb_data_ready - "data ready" callback for TCP sockets
+ * @sk: socket with data to read
+ * @bytes: how much data to read
+ *
+ */
+static void xs_smb_data_ready(struct sock *sk, int bytes)
+{
+	struct rpc_xprt *xprt;
+	read_descriptor_t rd_desc;
+	int read;
+
+	dprintk("SMB:       xs_smb_data_ready...\n");
+
+	read_lock(&sk->sk_callback_lock);
+	if (!(xprt = xprt_from_sock(sk)))
+		goto out;
+	if (xprt->shutdown)
+		goto out;
+
+	/* We use rd_desc to pass struct xprt to xs_tcp_data_recv */
+	rd_desc.arg.data = xprt;
+	do {
+		rd_desc.count = 65536;
+		read = tcp_read_sock(sk, &rd_desc, xs_smb_data_recv);
+	} while (read > 0);
+out:
+	read_unlock(&sk->sk_callback_lock);
+}
+
+/*
+ * Do the equivalent of linger/linger2 handling for dealing with
+ * broken servers that don't close the socket in a timely
+ * fashion
+ */
+static void xs_tcp_schedule_linger_timeout(struct rpc_xprt *xprt,
+		unsigned long timeout)
+{
+	struct smb_xprt *transport;
+
+	if (xprt_test_and_set_connecting(xprt))
+		return;
+	set_bit(XPRT_CONNECTION_ABORT, &xprt->state);
+	transport = container_of(xprt, struct smb_xprt, xprt);
+	queue_delayed_work(rpciod_workqueue, &transport->connect_worker,
+			   timeout);
+}
+
+static void xs_tcp_cancel_linger_timeout(struct rpc_xprt *xprt)
+{
+	struct smb_xprt *transport;
+
+	transport = container_of(xprt, struct smb_xprt, xprt);
+
+	if (!test_bit(XPRT_CONNECTION_ABORT, &xprt->state) ||
+	    !cancel_delayed_work(&transport->connect_worker))
+		return;
+	clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
+	xprt_clear_connecting(xprt);
+}
+
+static void xs_sock_mark_closed(struct rpc_xprt *xprt)
+{
+	smp_mb__before_clear_bit();
+	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
+	clear_bit(XPRT_CLOSING, &xprt->state);
+	smp_mb__after_clear_bit();
+	/* Mark transport as closed and wake up all pending tasks */
+	xprt_disconnect_done(xprt);
+}
+
+/**
+ * xs_smb_state_change - callback to handle TCP socket state changes
+ * @sk: socket whose state has changed
+ *
+ */
+static void xs_smb_state_change(struct sock *sk)
+{
+	struct rpc_xprt *xprt;
+
+	read_lock(&sk->sk_callback_lock);
+	if (!(xprt = xprt_from_sock(sk)))
+		goto out;
+	dprintk("RPC:       xs_smb_state_change client %p...\n", xprt);
+	dprintk("RPC:       state %x conn %d dead %d zapped %d\n",
+			sk->sk_state, xprt_connected(xprt),
+			sock_flag(sk, SOCK_DEAD),
+			sock_flag(sk, SOCK_ZAPPED));
+
+	switch (sk->sk_state) {
+	case TCP_ESTABLISHED:
+		spin_lock_bh(&xprt->transport_lock);
+		if (!xprt_test_and_set_connected(xprt)) {
+			struct smb_xprt *transport = container_of(xprt,
+					struct smb_xprt, xprt);
+
+			/* Reset TCP record info */
+			transport->tcp_offset = 0;
+			transport->tcp_reclen = 0;
+			transport->tcp_copied = 0;
+			transport->tcp_flags = TCP_RCV_COPY_FRAGHDR;
+
+			xprt_wake_pending_tasks(xprt, -EAGAIN);
+		}
+		spin_unlock_bh(&xprt->transport_lock);
+		break;
+	case TCP_FIN_WAIT1:
+		/* The client initiated a shutdown of the socket */
+		xprt->connect_cookie++;
+		xprt->reestablish_timeout = 0;
+		set_bit(XPRT_CLOSING, &xprt->state);
+		smp_mb__before_clear_bit();
+		clear_bit(XPRT_CONNECTED, &xprt->state);
+		clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
+		smp_mb__after_clear_bit();
+		xs_tcp_schedule_linger_timeout(xprt, xs_smb_fin_timeout);
+		break;
+	case TCP_CLOSE_WAIT:
+		/* The server initiated a shutdown of the socket */
+		xprt_force_disconnect(xprt);
+	case TCP_SYN_SENT:
+		xprt->connect_cookie++;
+	case TCP_CLOSING:
+		/*
+		 * If the server closed down the connection, make sure that
+		 * we back off before reconnecting
+		 */
+		if (xprt->reestablish_timeout < XS_TCP_INIT_REEST_TO)
+			xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
+		break;
+	case TCP_LAST_ACK:
+		set_bit(XPRT_CLOSING, &xprt->state);
+		xs_tcp_schedule_linger_timeout(xprt, xs_smb_fin_timeout);
+		smp_mb__before_clear_bit();
+		clear_bit(XPRT_CONNECTED, &xprt->state);
+		smp_mb__after_clear_bit();
+		break;
+	case TCP_CLOSE:
+		xs_tcp_cancel_linger_timeout(xprt);
+		xs_sock_mark_closed(xprt);
+	}
+ out:
+	read_unlock(&sk->sk_callback_lock);
+}
+
+/**
+ * xs_error_report - callback mainly for catching socket errors
+ * @sk: socket
+ */
+static void xs_error_report(struct sock *sk)
+{
+	struct rpc_xprt *xprt;
+
+	read_lock(&sk->sk_callback_lock);
+	if (!(xprt = xprt_from_sock(sk)))
+		goto out;
+	dprintk("RPC:       %s client %p...\n"
+			"RPC:       error %d\n",
+			__func__, xprt, sk->sk_err);
+	xprt_wake_pending_tasks(xprt, -EAGAIN);
+out:
+	read_unlock(&sk->sk_callback_lock);
+}
+
+static void xs_write_space(struct sock *sk)
+{
+	struct socket *sock;
+	struct rpc_xprt *xprt;
+
+	if (unlikely(!(sock = sk->sk_socket)))
+		return;
+	clear_bit(SOCK_NOSPACE, &sock->flags);
+
+	if (unlikely(!(xprt = xprt_from_sock(sk))))
+		return;
+	if (test_and_clear_bit(SOCK_ASYNC_NOSPACE, &sock->flags) == 0)
+		return;
+
+	xprt_write_space(xprt);
+}
+
+/**
+ * xs_tcp_write_space - callback invoked when socket buffer space
+ *                             becomes available
+ * @sk: socket whose state has changed
+ *
+ * Called when more output buffer space is available for this socket.
+ * We try not to wake our writers until they can make "significant"
+ * progress, otherwise we'll waste resources thrashing kernel_sendmsg
+ * with a bunch of small requests.
+ */
+static void xs_tcp_write_space(struct sock *sk)
+{
+	read_lock(&sk->sk_callback_lock);
+
+	/* from net/core/stream.c:sk_stream_write_space */
+	if (sk_stream_wspace(sk) >= sk_stream_min_wspace(sk))
+		xs_write_space(sk);
+
+	read_unlock(&sk->sk_callback_lock);
+}
+
+/**
+ * xs_smb_set_port - reset the port number in the remote endpoint address
+ * @xprt: generic transport
+ * @port: new port number
+ *
+ * Should never be needed for SMB transport so just BUG() here.
+ */
+static void
+xs_smb_set_port(struct rpc_xprt *xprt, unsigned short port)
+{
+	dprintk("RPC:       setting port for xprt %p to %u\n", xprt, port);
+	BUG();
+}
+
+/**
+ * xs_smb_rpcbind - attempt to rebind the transport
+ * @task: task
+ *
+ * Should never be needed for SMB transport so just BUG() here.
+ */
+static void
+xs_smb_rpcbind(struct rpc_task *task)
+{
+	dprintk("RPC:       rpcbind called on SMB task %p", task);
+	BUG();
+}
+
+#ifdef CONFIG_DEBUG_LOCK_ALLOC
+static struct lock_class_key xs_key[2];
+static struct lock_class_key xs_slock_key[2];
+
+static inline void xs_reclassify_socket4(struct socket *sock)
+{
+	struct sock *sk = sock->sk;
+
+	BUG_ON(sock_owned_by_user(sk));
+	sock_lock_init_class_and_name(sk, "slock-AF_INET-RPC",
+		&xs_slock_key[0], "sk_lock-AF_INET-RPC", &xs_key[0]);
+}
+
+static inline void xs_reclassify_socket6(struct socket *sock)
+{
+	struct sock *sk = sock->sk;
+
+	BUG_ON(sock_owned_by_user(sk));
+	sock_lock_init_class_and_name(sk, "slock-AF_INET6-RPC",
+		&xs_slock_key[1], "sk_lock-AF_INET6-RPC", &xs_key[1]);
+}
+#else
+static inline void xs_reclassify_socket4(struct socket *sock)
+{
+}
+
+static inline void xs_reclassify_socket6(struct socket *sock)
+{
+}
+#endif
+
+/*
+ * We need to preserve the port number so the reply cache on the server can
+ * find our cached RPC replies when we get around to reconnecting.
+ */
+static void xs_abort_connection(struct rpc_xprt *xprt, struct smb_xprt *transport)
+{
+	int result;
+	struct sockaddr any;
+
+	dprintk("RPC:       disconnecting xprt %p to reuse port\n", xprt);
+
+	/*
+	 * Disconnect the transport socket by doing a connect operation
+	 * with AF_UNSPEC.  This should return immediately...
+	 */
+	memset(&any, 0, sizeof(any));
+	any.sa_family = AF_UNSPEC;
+	result = kernel_connect(transport->sock, &any, sizeof(any), 0);
+	if (!result)
+		xs_sock_mark_closed(xprt);
+	else
+		dprintk("RPC:       AF_UNSPEC connect return code %d\n",
+				result);
+}
+
+static void xs_tcp_reuse_connection(struct rpc_xprt *xprt, struct smb_xprt *transport)
+{
+	unsigned int state = transport->inet->sk_state;
+
+	if (state == TCP_CLOSE && transport->sock->state == SS_UNCONNECTED)
+		return;
+	if ((1 << state) & (TCPF_ESTABLISHED|TCPF_SYN_SENT))
+		return;
+	xs_abort_connection(xprt, transport);
+}
+
+static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
+{
+	struct smb_xprt *transport = container_of(xprt, struct smb_xprt, xprt);
+
+	if (!transport->inet) {
+		struct sock *sk = sock->sk;
+
+		write_lock_bh(&sk->sk_callback_lock);
+
+		xs_save_old_callbacks(transport, sk);
+
+		sk->sk_user_data = xprt;
+		sk->sk_data_ready = xs_smb_data_ready;
+		sk->sk_state_change = xs_smb_state_change;
+		sk->sk_write_space = xs_tcp_write_space;
+		sk->sk_error_report = xs_error_report;
+		sk->sk_allocation = GFP_ATOMIC;
+
+		/* socket options */
+		sk->sk_userlocks |= SOCK_BINDPORT_LOCK;
+		sock_reset_flag(sk, SOCK_LINGER);
+		tcp_sk(sk)->linger2 = 0;
+		tcp_sk(sk)->nonagle |= TCP_NAGLE_OFF;
+
+		xprt_clear_connected(xprt);
+
+		/* Reset to new socket */
+		transport->sock = sock;
+		transport->inet = sk;
+
+		write_unlock_bh(&sk->sk_callback_lock);
+	}
+
+	if (!xprt_bound(xprt))
+		return -ENOTCONN;
+
+	/* Tell the socket layer to start connecting... */
+	xprt->stat.connect_count++;
+	xprt->stat.connect_start = jiffies;
+	return kernel_connect(sock, xs_addr(xprt), xprt->addrlen, O_NONBLOCK);
+}
+
+/**
+ * xs_tcp_setup_socket - create a TCP socket and connect to a remote endpoint
+ * @xprt: RPC transport to connect
+ * @transport: socket transport to connect
+ * @create_sock: function to create a socket of the correct type
+ *
+ * Invoked by a work queue tasklet.
+ */
+static void xs_tcp_setup_socket(struct rpc_xprt *xprt,
+		struct smb_xprt *transport,
+		struct socket *(*create_sock)(struct rpc_xprt *,
+			struct smb_xprt *))
+{
+	struct socket *sock = transport->sock;
+	int status = -EIO;
+
+	if (xprt->shutdown)
+		goto out;
+
+	if (!sock) {
+		clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
+		sock = create_sock(xprt, transport);
+		if (IS_ERR(sock)) {
+			status = PTR_ERR(sock);
+			goto out;
+		}
+	} else {
+		int abort_and_exit;
+
+		abort_and_exit = test_and_clear_bit(XPRT_CONNECTION_ABORT,
+				&xprt->state);
+		/* "close" the socket, preserving the local port */
+		xs_tcp_reuse_connection(xprt, transport);
+
+		if (abort_and_exit)
+			goto out_eagain;
+	}
+
+	dprintk("SMB:       worker connecting xprt %p via %s to "
+		"%s (port %s)\n", xprt,
+		xprt->address_strings[RPC_DISPLAY_PROTO],
+		xprt->address_strings[RPC_DISPLAY_ADDR],
+		xprt->address_strings[RPC_DISPLAY_PORT]);
+
+	status = xs_tcp_finish_connecting(xprt, sock);
+	dprintk("SMB:       %p connect status %d connected %d sock state %d\n",
+			xprt, -status, xprt_connected(xprt),
+			sock->sk->sk_state);
+	switch (status) {
+	default:
+		printk("%s: connect returned unhandled error %d\n",
+			__func__, status);
+	case -EADDRNOTAVAIL:
+		/* We're probably in TIME_WAIT. Get rid of existing socket,
+		 * and retry
+		 */
+		set_bit(XPRT_CONNECTION_CLOSE, &xprt->state);
+		xprt_force_disconnect(xprt);
+		break;
+	case -ECONNREFUSED:
+	case -ECONNRESET:
+	case -ENETUNREACH:
+		/* retry with existing socket, after a delay */
+	case 0:
+	case -EINPROGRESS:
+	case -EALREADY:
+		xprt_clear_connecting(xprt);
+		return;
+	}
+out_eagain:
+	status = -EAGAIN;
+out:
+	xprt_clear_connecting(xprt);
+	xprt_wake_pending_tasks(xprt, status);
+}
+
+static struct socket *xs_create_tcp_sock4(struct rpc_xprt *xprt,
+		struct smb_xprt *transport)
+{
+	struct socket *sock;
+	int err;
+
+	/* start from scratch */
+	err = sock_create_kern(PF_INET, SOCK_STREAM, IPPROTO_TCP, &sock);
+	if (err < 0) {
+		dprintk("RPC:       can't create TCP transport socket (%d).\n",
+				-err);
+		goto out_err;
+	}
+	xs_reclassify_socket4(sock);
+	return sock;
+out_err:
+	return ERR_PTR(-EIO);
+}
+
+/**
+ * xs_tcp_connect_worker4 - connect a TCP socket to a remote endpoint
+ * @work: RPC transport to connect
+ *
+ * Invoked by a work queue tasklet.
+ */
+static void xs_tcp_connect_worker4(struct work_struct *work)
+{
+	struct smb_xprt *transport =
+		container_of(work, struct smb_xprt, connect_worker.work);
+	struct rpc_xprt *xprt = &transport->xprt;
+
+	xs_tcp_setup_socket(xprt, transport, xs_create_tcp_sock4);
+}
+
+static struct socket *xs_create_tcp_sock6(struct rpc_xprt *xprt,
+		struct smb_xprt *transport)
+{
+	struct socket *sock;
+	int err;
+
+	/* start from scratch */
+	err = sock_create_kern(PF_INET6, SOCK_STREAM, IPPROTO_TCP, &sock);
+	if (err < 0) {
+		dprintk("RPC:       can't create TCP transport socket (%d).\n",
+				-err);
+		goto out_err;
+	}
+	xs_reclassify_socket6(sock);
+	return sock;
+out_err:
+	return ERR_PTR(-EIO);
+}
+
+/**
+ * xs_tcp_connect_worker6 - connect a TCP socket to a remote endpoint
+ * @work: RPC transport to connect
+ *
+ * Invoked by a work queue tasklet.
+ */
+static void xs_tcp_connect_worker6(struct work_struct *work)
+{
+	struct smb_xprt *transport =
+		container_of(work, struct smb_xprt, connect_worker.work);
+	struct rpc_xprt *xprt = &transport->xprt;
+
+	xs_tcp_setup_socket(xprt, transport, xs_create_tcp_sock6);
+}
+
+/**
+ * xs_connect - connect a socket to a remote endpoint
+ * @task: address of RPC task that manages state of connect request
+ *
+ * TCP: If the remote end dropped the connection, delay reconnecting.
+ *
+ * UDP socket connects are synchronous, but we use a work queue anyway
+ * to guarantee that even unprivileged user processes can set up a
+ * socket on a privileged port.
+ *
+ * If a UDP socket connect fails, the delay behavior here prevents
+ * retry floods (hard mounts).
+ */
+static void xs_connect(struct rpc_task *task)
+{
+	struct rpc_xprt *xprt = task->tk_xprt;
+	struct smb_xprt *transport = container_of(xprt, struct smb_xprt, xprt);
+
+	if (xprt_test_and_set_connecting(xprt))
+		return;
+
+	if (transport->sock != NULL) {
+		dprintk("RPC:       xs_connect delayed xprt %p for %lu "
+				"seconds\n",
+				xprt, xprt->reestablish_timeout / HZ);
+		queue_delayed_work(rpciod_workqueue,
+				   &transport->connect_worker,
+				   xprt->reestablish_timeout);
+		xprt->reestablish_timeout <<= 1;
+		if (xprt->reestablish_timeout > XS_TCP_MAX_REEST_TO)
+			xprt->reestablish_timeout = XS_TCP_MAX_REEST_TO;
+	} else {
+		dprintk("RPC:       xs_connect scheduled xprt %p\n", xprt);
+		queue_delayed_work(rpciod_workqueue,
+				   &transport->connect_worker, 0);
+	}
+}
+
+static void xs_tcp_connect(struct rpc_task *task)
+{
+	struct rpc_xprt *xprt = task->tk_xprt;
+
+	/* Exit if we need to wait for socket shutdown to complete */
+	if (test_bit(XPRT_CLOSING, &xprt->state))
+		return;
+	xs_connect(task);
+}
+
+/**
+ * xs_tcp_print_stats - display TCP socket-specifc stats
+ * @xprt: rpc_xprt struct containing statistics
+ * @seq: output file
+ *
+ */
+static void xs_tcp_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
+{
+	struct smb_xprt *transport = container_of(xprt, struct smb_xprt, xprt);
+	long idle_time = 0;
+
+	if (xprt_connected(xprt))
+		idle_time = (long)(jiffies - xprt->last_used) / HZ;
+
+	seq_printf(seq, "\txprt:\ttcp %u %lu %lu %lu %ld %lu %lu %lu %Lu %Lu\n",
+			transport->port,
+			xprt->stat.bind_count,
+			xprt->stat.connect_count,
+			xprt->stat.connect_time,
+			idle_time,
+			xprt->stat.sends,
+			xprt->stat.recvs,
+			xprt->stat.bad_xids,
+			xprt->stat.req_u,
+			xprt->stat.bklog_u);
+}
+
+static struct rpc_xprt_ops xs_smb_ops = {
+	.reserve_xprt		= xprt_reserve_xprt,
+	.release_xprt		= xs_tcp_release_xprt,
+	.rpcbind		= xs_smb_rpcbind,
+	.set_port		= xs_smb_set_port,
+	.connect		= xs_tcp_connect,
+	.buf_alloc		= rpc_malloc,
+	.buf_free		= rpc_free,
+	.send_request		= xs_smb_send_request,
+	.set_retrans_timeout	= xprt_set_retrans_timeout_def,
+#if defined(CONFIG_NFS_V4_1)
+	.release_request	= bc_release_request,
+#endif /* CONFIG_NFS_V4_1 */
+	.close			= xs_tcp_close,
+	.destroy		= xs_destroy,
+	.print_stats		= xs_tcp_print_stats,
+};
+
+static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
+				      unsigned int slot_table_size)
+{
+	struct rpc_xprt *xprt;
+	struct smb_xprt *new;
+
+	if (args->addrlen > sizeof(xprt->addr)) {
+		dprintk("RPC:       xs_setup_xprt: address too large\n");
+		return ERR_PTR(-EBADF);
+	}
+
+	new = kzalloc(sizeof(*new), GFP_KERNEL);
+	if (new == NULL) {
+		dprintk("RPC:       xs_setup_xprt: couldn't allocate "
+				"rpc_xprt\n");
+		return ERR_PTR(-ENOMEM);
+	}
+	xprt = &new->xprt;
+
+	xprt->max_reqs = slot_table_size;
+	xprt->slot = kcalloc(xprt->max_reqs, sizeof(struct rpc_rqst), GFP_KERNEL);
+	if (xprt->slot == NULL) {
+		kfree(xprt);
+		dprintk("RPC:       xs_setup_xprt: couldn't allocate slot "
+				"table\n");
+		return ERR_PTR(-ENOMEM);
+	}
+
+	memcpy(&xprt->addr, args->dstaddr, args->addrlen);
+	xprt->addrlen = args->addrlen;
+	if (args->srcaddr)
+		memcpy(&new->addr, args->srcaddr, args->addrlen);
+
+	return xprt;
+}
+
+static const struct rpc_timeout xs_tcp_default_timeout = {
+	.to_initval = 60 * HZ,
+	.to_maxval = 60 * HZ,
+	.to_retries = 2,
+};
+
+/**
+ * xs_setup_tcp - Set up transport to use a TCP socket
+ * @args: rpc transport creation arguments
+ *
+ */
+static struct rpc_xprt *xs_setup_smb(struct xprt_create *args)
+{
+	struct sockaddr *addr = args->dstaddr;
+	struct rpc_xprt *xprt;
+	struct smb_xprt *transport;
+
+	xprt = xs_setup_xprt(args, xprt_smb_slot_table_entries);
+	if (IS_ERR(xprt))
+		return xprt;
+	transport = container_of(xprt, struct smb_xprt, xprt);
+
+	xprt->prot = IPPROTO_TCP;
+	xprt->tsh_size = sizeof(rpc_fraghdr) / sizeof(u32);
+	xprt->max_payload = SMB_MAX_FRAGMENT_SIZE;
+
+	xprt->bind_timeout = XS_BIND_TO;
+	xprt->connect_timeout = XS_TCP_CONN_TO;
+	xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
+	xprt->idle_timeout = XS_SMB_IDLE_DISC_TO;
+
+	xprt->ops = &xs_smb_ops;
+	xprt->timeout = &xs_tcp_default_timeout;
+
+	switch (addr->sa_family) {
+	case AF_INET:
+		if (((struct sockaddr_in *)addr)->sin_port == htons(0))
+			return ERR_PTR(-EINVAL);
+
+		xprt_set_bound(xprt);
+		INIT_DELAYED_WORK(&transport->connect_worker, xs_tcp_connect_worker4);
+		xs_format_peer_addresses(xprt, "tcp", RPCBIND_NETID_TCP);
+		break;
+	case AF_INET6:
+		if (((struct sockaddr_in6 *)addr)->sin6_port == htons(0))
+			return ERR_PTR(-EINVAL);
+
+		xprt_set_bound(xprt);
+		INIT_DELAYED_WORK(&transport->connect_worker, xs_tcp_connect_worker6);
+		xs_format_peer_addresses(xprt, "tcp", RPCBIND_NETID_TCP6);
+		break;
+	default:
+		kfree(xprt);
+		return ERR_PTR(-EAFNOSUPPORT);
+	}
+
+	dprintk("RPC:       set up xprt to %s (port %s) via %s\n",
+			xprt->address_strings[RPC_DISPLAY_ADDR],
+			xprt->address_strings[RPC_DISPLAY_PORT],
+			xprt->address_strings[RPC_DISPLAY_PROTO]);
+
+	if (try_module_get(THIS_MODULE))
+		return xprt;
+
+	kfree(xprt->slot);
+	kfree(xprt);
+	return ERR_PTR(-EINVAL);
+}
+
+static struct xprt_class	xs_smb_transport = {
+	.list		= LIST_HEAD_INIT(xs_smb_transport.list),
+	.name		= "smb",
+	.owner		= THIS_MODULE,
+	.ident		= XPRT_TRANSPORT_SMB,
+	.setup		= xs_setup_smb,
+};
+
+/**
+ * init_socket_xprt - set up xprtsock's sysctls, register with RPC client
+ *
+ */
+int init_smb_xprt(void)
+{
+#ifdef RPC_DEBUG
+	if (!sunrpc_table_header)
+		sunrpc_table_header = register_sysctl_table(sunrpc_table);
+#endif
+
+	xprt_register_transport(&xs_smb_transport);
+
+	return 0;
+}
+
+/**
+ * cleanup_socket_xprt - remove xprtsock's sysctls, unregister
+ *
+ */
+void cleanup_smb_xprt(void)
+{
+#ifdef RPC_DEBUG
+	if (sunrpc_table_header) {
+		unregister_sysctl_table(sunrpc_table_header);
+		sunrpc_table_header = NULL;
+	}
+#endif
+
+	xprt_unregister_transport(&xs_smb_transport);
+}
-- 
1.6.0.6

