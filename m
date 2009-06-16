From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 37/44] nfsd41: sunrpc: Added rpc server-side backchannel handling
Date: Tue, 16 Jun 2009 04:20:59 +0300
Message-ID: <1245115259-8023-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2617
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752387AbZFPBU7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:20:59 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Rahul Iyer <iyer@netapp.com>

Signed-off-by: Rahul Iyer <iyer@netapp.com>
Signed-off-by: Mike Sager <sager@netapp.com>
Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

When the call direction is a reply, copy the xid and call direction into the
req->rq_private_buf.head[0].iov_base otherwise rpc_verify_header returns
rpc_garbage.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>

[get rid of CONFIG_NFSD_V4_1]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>

[sunrpc: refactoring of svc_tcp_recvfrom]
Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

[nfsd41: sunrpc: create common send routine for the fore and the back channels]
Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

[nfsd41: sunrpc: Use free_page() to free server backchannel pages]
Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

[nfsd41: sunrpc: Document server backchannel locking]
Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

[nfsd41: sunrpc: remove bc_connect_worker()]
Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

[nfsd41: sunrpc: Define xprt_server_backchannel()[
Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

[nfsd41: sunrpc: remove bc_close and bc_init_auto_disconnect dummy functions]
Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

[nfsd41: sunrpc: eliminate unneeded switch statement in xs_setup_tcp()]
Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

[nfsd41: sunrpc: Don't auto close the server backchannel connection]
Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

[nfsd41: sunrpc: Remove unused functions]
Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/sunrpc/clnt.h    |    1 +
 include/linux/sunrpc/svcsock.h |    1 +
 include/linux/sunrpc/xprt.h    |    7 ++
 net/sunrpc/clnt.c              |    1 +
 net/sunrpc/sunrpc.h            |   35 +++++++
 net/sunrpc/svcsock.c           |  172 +++++++++++++++++++++++++++-------
 net/sunrpc/xprt.c              |   16 +++-
 net/sunrpc/xprtsock.c          |  201 ++++++++++++++++++++++++++++++++++++++--
 8 files changed, 390 insertions(+), 44 deletions(-)
 create mode 100644 net/sunrpc/sunrpc.h

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index c39a210..cf9a8ec 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -110,6 +110,7 @@ struct rpc_create_args {
 	rpc_authflavor_t	authflavor;
 	unsigned long		flags;
 	char			*client_name;
+	struct svc_sock		*bc_sock;	/* NFSv4.1 backchannel */
 };
 
 /* Values for "flags" field */
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 8271631..19228f4 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -28,6 +28,7 @@ struct svc_sock {
 	/* private TCP part */
 	u32			sk_reclen;	/* length of record */
 	u32			sk_tcplen;	/* current read length */
+	struct rpc_xprt	       *sk_bc_xprt;	/* NFSv4.1 backchannel xprt */
 };
 
 /*
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 1758d9f..d180661 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -174,6 +174,7 @@ struct rpc_xprt {
 	spinlock_t		reserve_lock;	/* lock slot table */
 	u32			xid;		/* Next XID value to use */
 	struct rpc_task *	snd_task;	/* Task blocked in send */
+	struct svc_sock		*bc_sock;	/* NFSv4.1 backchannel */
 	struct list_head	recv;
 
 	struct {
@@ -197,6 +198,7 @@ struct xprt_create {
 	struct sockaddr *	srcaddr;	/* optional local address */
 	struct sockaddr *	dstaddr;	/* remote peer address */
 	size_t			addrlen;
+	struct svc_sock		*bc_sock;	/* NFSv4.1 backchannel */
 };
 
 struct xprt_class {
@@ -331,6 +333,11 @@ static inline int xprt_test_and_set_binding(struct rpc_xprt *xprt)
 	return test_and_set_bit(XPRT_BINDING, &xprt->state);
 }
 
+static inline int xprt_server_backchannel(struct rpc_xprt *xprt)
+{
+	return xprt->bc_sock != NULL;
+}
+
 #endif /* __KERNEL__*/
 
 #endif /* _LINUX_SUNRPC_XPRT_H */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 5abab09..3dc847f 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -266,6 +266,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 		.srcaddr = args->saddress,
 		.dstaddr = args->address,
 		.addrlen = args->addrsize,
+		.bc_sock = args->bc_sock,
 	};
 	char servername[48];
 
diff --git a/net/sunrpc/sunrpc.h b/net/sunrpc/sunrpc.h
new file mode 100644
index 0000000..3258089
--- /dev/null
+++ b/net/sunrpc/sunrpc.h
@@ -0,0 +1,35 @@
+/******************************************************************************
+
+(c) 2008 NetApp.  All Rights Reserved.
+
+NetApp provides this source code under the GPL v2 License.
+The GPL v2 license is available at
+http://opensource.org/licenses/gpl-license.php.
+
+THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
+CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
+EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
+PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
+PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+
+******************************************************************************/
+
+/*
+ * Functions and macros used internally by RPC
+ */
+
+#ifndef _NET_SUNRPC_SUNRPC_H
+#define _NET_SUNRPC_SUNRPC_H
+
+int svc_send_common(struct socket *sock, struct xdr_buf *xdr,
+		    struct page *headpage, unsigned long headoffset,
+		    struct page *tailpage, unsigned long tailoffset);
+
+#endif /* _NET_SUNRPC_SUNRPC_H */
+
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 295582f..d065e7e 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -49,6 +49,7 @@
 #include <linux/sunrpc/msg_prot.h>
 #include <linux/sunrpc/svcsock.h>
 #include <linux/sunrpc/stats.h>
+#include <linux/sunrpc/xprt.h>
 
 #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
 
@@ -153,49 +154,27 @@ static void svc_set_cmsg_data(struct svc_rqst *rqstp, struct cmsghdr *cmh)
 }
 
 /*
- * Generic sendto routine
+ * send routine intended to be shared by the fore- and back-channel
  */
-static int svc_sendto(struct svc_rqst *rqstp, struct xdr_buf *xdr)
+int svc_send_common(struct socket *sock, struct xdr_buf *xdr,
+		    struct page *headpage, unsigned long headoffset,
+		    struct page *tailpage, unsigned long tailoffset)
 {
-	struct svc_sock	*svsk =
-		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
-	struct socket	*sock = svsk->sk_sock;
-	int		slen;
-	union {
-		struct cmsghdr	hdr;
-		long		all[SVC_PKTINFO_SPACE / sizeof(long)];
-	} buffer;
-	struct cmsghdr *cmh = &buffer.hdr;
-	int		len = 0;
 	int		result;
 	int		size;
 	struct page	**ppage = xdr->pages;
 	size_t		base = xdr->page_base;
 	unsigned int	pglen = xdr->page_len;
 	unsigned int	flags = MSG_MORE;
-	RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
+	int		slen;
+	int		len = 0;
 
 	slen = xdr->len;
 
-	if (rqstp->rq_prot == IPPROTO_UDP) {
-		struct msghdr msg = {
-			.msg_name	= &rqstp->rq_addr,
-			.msg_namelen	= rqstp->rq_addrlen,
-			.msg_control	= cmh,
-			.msg_controllen	= sizeof(buffer),
-			.msg_flags	= MSG_MORE,
-		};
-
-		svc_set_cmsg_data(rqstp, cmh);
-
-		if (sock_sendmsg(sock, &msg, 0) < 0)
-			goto out;
-	}
-
 	/* send head */
 	if (slen == xdr->head[0].iov_len)
 		flags = 0;
-	len = kernel_sendpage(sock, rqstp->rq_respages[0], 0,
+	len = kernel_sendpage(sock, headpage, headoffset,
 				  xdr->head[0].iov_len, flags);
 	if (len != xdr->head[0].iov_len)
 		goto out;
@@ -219,16 +198,58 @@ static int svc_sendto(struct svc_rqst *rqstp, struct xdr_buf *xdr)
 		base = 0;
 		ppage++;
 	}
+
 	/* send tail */
 	if (xdr->tail[0].iov_len) {
-		result = kernel_sendpage(sock, rqstp->rq_respages[0],
-					     ((unsigned long)xdr->tail[0].iov_base)
-						& (PAGE_SIZE-1),
-					     xdr->tail[0].iov_len, 0);
-
+		result = kernel_sendpage(sock, tailpage, tailoffset,
+				   xdr->tail[0].iov_len, 0);
 		if (result > 0)
 			len += result;
 	}
+
+out:
+	return len;
+}
+
+
+/*
+ * Generic sendto routine
+ */
+static int svc_sendto(struct svc_rqst *rqstp, struct xdr_buf *xdr)
+{
+	struct svc_sock	*svsk =
+		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
+	struct socket	*sock = svsk->sk_sock;
+	union {
+		struct cmsghdr	hdr;
+		long		all[SVC_PKTINFO_SPACE / sizeof(long)];
+	} buffer;
+	struct cmsghdr *cmh = &buffer.hdr;
+	int		len = 0;
+	unsigned long tailoff;
+	unsigned long headoff;
+	RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
+
+	if (rqstp->rq_prot == IPPROTO_UDP) {
+		struct msghdr msg = {
+			.msg_name	= &rqstp->rq_addr,
+			.msg_namelen	= rqstp->rq_addrlen,
+			.msg_control	= cmh,
+			.msg_controllen	= sizeof(buffer),
+			.msg_flags	= MSG_MORE,
+		};
+
+		svc_set_cmsg_data(rqstp, cmh);
+
+		if (sock_sendmsg(sock, &msg, 0) < 0)
+			goto out;
+	}
+
+	tailoff = ((unsigned long)xdr->tail[0].iov_base) & (PAGE_SIZE-1);
+	headoff = 0;
+	len = svc_send_common(sock, xdr, rqstp->rq_respages[0], headoff,
+			       rqstp->rq_respages[0], tailoff);
+
 out:
 	dprintk("svc: socket %p sendto([%p %Zu... ], %d) = %d (addr %s)\n",
 		svsk, xdr->head[0].iov_base, xdr->head[0].iov_len,
@@ -895,6 +916,57 @@ static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
 	return -EAGAIN;
 }
 
+static int svc_process_calldir(struct svc_sock *svsk, struct svc_rqst *rqstp,
+			       struct rpc_rqst **reqpp, struct kvec *vec)
+{
+	struct rpc_rqst *req = NULL;
+	u32 *p;
+	u32 xid;
+	u32 calldir;
+	int len;
+
+	len = svc_recvfrom(rqstp, vec, 1, 8);
+	if (len < 0)
+		goto error;
+
+	p = (u32 *)rqstp->rq_arg.head[0].iov_base;
+	xid = *p++;
+	calldir = *p;
+
+	if (calldir == 0) {
+		/* REQUEST is the most common case */
+		vec[0] = rqstp->rq_arg.head[0];
+	} else {
+		/* REPLY */
+		if (svsk->sk_bc_xprt)
+			req = xprt_lookup_rqst(svsk->sk_bc_xprt, xid);
+
+		if (!req) {
+			printk(KERN_NOTICE
+				"%s: Got unrecognized reply: "
+				"calldir 0x%x sk_bc_xprt %p xid %08x\n",
+				__func__, ntohl(calldir),
+				svsk->sk_bc_xprt, xid);
+			vec[0] = rqstp->rq_arg.head[0];
+			goto out;
+		}
+
+		memcpy(&req->rq_private_buf, &req->rq_rcv_buf,
+		       sizeof(struct xdr_buf));
+		/* copy the xid and call direction */
+		memcpy(req->rq_private_buf.head[0].iov_base,
+		       rqstp->rq_arg.head[0].iov_base, 8);
+		vec[0] = req->rq_private_buf.head[0];
+	}
+ out:
+	vec[0].iov_base += 8;
+	vec[0].iov_len -= 8;
+	len = svsk->sk_reclen - 8;
+ error:
+	*reqpp = req;
+	return len;
+}
+
 /*
  * Receive data from a TCP socket.
  */
@@ -906,6 +978,7 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	int		len;
 	struct kvec *vec;
 	int pnum, vlen;
+	struct rpc_rqst *req = NULL;
 
 	dprintk("svc: tcp_recv %p data %d conn %d close %d\n",
 		svsk, test_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags),
@@ -919,9 +992,27 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	vec = rqstp->rq_vec;
 	vec[0] = rqstp->rq_arg.head[0];
 	vlen = PAGE_SIZE;
+
+	/*
+	 * We have enough data for the whole tcp record. Let's try and read the
+	 * first 8 bytes to get the xid and the call direction. We can use this
+	 * to figure out if this is a call or a reply to a callback. If
+	 * sk_reclen is < 8 (xid and calldir), then this is a malformed packet.
+	 * In that case, don't bother with the calldir and just read the data.
+	 * It will be rejected in svc_process.
+	 */
+	if (len >= 8) {
+		len = svc_process_calldir(svsk, rqstp, &req, vec);
+		if (len < 0)
+			goto err_again;
+		vlen -= 8;
+	}
+
 	pnum = 1;
 	while (vlen < len) {
-		vec[pnum].iov_base = page_address(rqstp->rq_pages[pnum]);
+		vec[pnum].iov_base = (req) ?
+			page_address(req->rq_private_buf.pages[pnum - 1]) :
+			page_address(rqstp->rq_pages[pnum]);
 		vec[pnum].iov_len = PAGE_SIZE;
 		pnum++;
 		vlen += PAGE_SIZE;
@@ -933,6 +1024,16 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	if (len < 0)
 		goto err_again;
 
+	/*
+	 * Account for the 8 bytes we read earlier
+	 */
+	len += 8;
+
+	if (req) {
+		xprt_complete_rqst(req->rq_task, len);
+		len = 0;
+		goto out;
+	}
 	dprintk("svc: TCP complete record (%d bytes)\n", len);
 	rqstp->rq_arg.len = len;
 	rqstp->rq_arg.page_base = 0;
@@ -946,6 +1047,7 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	rqstp->rq_xprt_ctxt   = NULL;
 	rqstp->rq_prot	      = IPPROTO_TCP;
 
+out:
 	/* Reset TCP read info */
 	svsk->sk_reclen = 0;
 	svsk->sk_tcplen = 0;
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index a0bfe53..1f240f1 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -596,6 +596,9 @@ static void xprt_autoclose(struct work_struct *work)
 	struct rpc_xprt *xprt =
 		container_of(work, struct rpc_xprt, task_cleanup);
 
+	if (xprt_server_backchannel(xprt))
+		return;
+
 	xprt->ops->close(xprt);
 	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
 	xprt_release_write(xprt, NULL);
@@ -666,6 +669,9 @@ xprt_init_autodisconnect(unsigned long data)
 {
 	struct rpc_xprt *xprt = (struct rpc_xprt *)data;
 
+	if (xprt_server_backchannel(xprt))
+		return;
+
 	spin_lock(&xprt->transport_lock);
 	if (!list_empty(&xprt->recv) || xprt->shutdown)
 		goto out_abort;
@@ -1053,7 +1059,8 @@ found:
 	INIT_LIST_HEAD(&xprt->recv);
 	INIT_WORK(&xprt->task_cleanup, xprt_autoclose);
 	setup_timer(&xprt->timer, xprt_init_autodisconnect,
-			(unsigned long)xprt);
+		    (unsigned long)xprt);
+
 	xprt->last_used = jiffies;
 	xprt->cwnd = RPC_INITCWND;
 	xprt->bind_index = 0;
@@ -1073,6 +1080,13 @@ found:
 	dprintk("RPC:       created transport %p with %u slots\n", xprt,
 			xprt->max_reqs);
 
+	/*
+	 * Since we don't want connections for the backchannel, we set
+	 * the xprt status to connected
+	 */
+	if (args->bc_sock)
+		xprt_set_connected(xprt);
+
 	return xprt;
 }
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index d40ff50..9a33804 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -32,6 +32,7 @@
 #include <linux/tcp.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/sched.h>
+#include <linux/sunrpc/svcsock.h>
 #include <linux/sunrpc/xprtsock.h>
 #include <linux/file.h>
 
@@ -40,6 +41,7 @@
 #include <net/udp.h>
 #include <net/tcp.h>
 
+#include "sunrpc.h"
 /*
  * xprtsock tunables
  */
@@ -1966,6 +1968,134 @@ static void xs_tcp_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 			xprt->stat.bklog_u);
 }
 
+struct rpc_buffer {
+	size_t	len;
+	char	data[];
+};
+/*
+ * Allocate a bunch of pages for a scratch buffer for the rpc code. The reason
+ * we allocate pages instead doing a kmalloc like rpc_malloc is because we want
+ * to use the server side send routines.
+ */
+void *bc_malloc(struct rpc_task *task, size_t size)
+{
+	struct page *page;
+	struct rpc_buffer *buf;
+
+	BUG_ON(size > PAGE_SIZE - sizeof(struct rpc_buffer));
+	page = alloc_page(GFP_KERNEL);
+
+	if (!page)
+		return NULL;
+
+	buf = page_address(page);
+	buf->len = PAGE_SIZE;
+
+	return buf->data;
+}
+
+/*
+ * Free the space allocated in the bc_alloc routine
+ */
+void bc_free(void *buffer)
+{
+	struct rpc_buffer *buf;
+
+	if (!buffer)
+		return;
+
+	buf = container_of(buffer, struct rpc_buffer, data);
+	free_page((unsigned long)buf);
+}
+
+/*
+ * Use the svc_sock to send the callback. Must be called with svsk->sk_mutex
+ * held. Borrows heavily from svc_tcp_sendto and xs_tcp_semd_request.
+ */
+static int bc_sendto(struct rpc_rqst *req)
+{
+	int len;
+	struct xdr_buf *xbufp = &req->rq_snd_buf;
+	struct rpc_xprt *xprt = req->rq_xprt;
+	struct sock_xprt *transport =
+				container_of(xprt, struct sock_xprt, xprt);
+	struct socket *sock = transport->sock;
+	unsigned long headoff;
+	unsigned long tailoff;
+
+	/*
+	 * Set up the rpc header and record marker stuff
+	 */
+	xs_encode_tcp_record_marker(xbufp);
+
+	tailoff = (unsigned long)xbufp->tail[0].iov_base & ~PAGE_MASK;
+	headoff = (unsigned long)xbufp->head[0].iov_base & ~PAGE_MASK;
+	len = svc_send_common(sock, xbufp,
+			      virt_to_page(xbufp->head[0].iov_base), headoff,
+			      xbufp->tail[0].iov_base, tailoff);
+
+	if (len != xbufp->len) {
+		printk(KERN_NOTICE "Error sending entire callback!\n");
+		len = -EAGAIN;
+	}
+
+	return len;
+}
+
+/*
+ * The send routine. Borrows from svc_send
+ */
+static int bc_send_request(struct rpc_task *task)
+{
+	struct rpc_rqst *req = task->tk_rqstp;
+	struct rpc_xprt *bc_xprt = req->rq_xprt;
+	struct svc_xprt	*xprt;
+	struct svc_sock         *svsk;
+	u32                     len;
+
+	dprintk("sending request with xid: %08x\n", ntohl(req->rq_xid));
+	/*
+	 * Get the server socket associated with this callback xprt
+	 */
+	svsk = bc_xprt->bc_sock;
+	xprt = &svsk->sk_xprt;
+
+	/*
+	 * Grab the mutex to serialize data as the connection is shared
+	 * with the fore channel
+	 */
+	mutex_lock(&xprt->xpt_mutex);
+	if (test_bit(XPT_DEAD, &xprt->xpt_flags))
+		len = -ENOTCONN;
+	else
+		len = bc_sendto(req);
+	mutex_unlock(&xprt->xpt_mutex);
+
+	if (len > 0)
+		len = 0;
+
+	return len;
+}
+
+/*
+ * The close routine. Since this is client initiated, we do nothing
+ */
+
+static void bc_close(struct rpc_xprt *xprt)
+{
+	return;
+}
+
+/*
+ * The xprt destroy routine. Again, because this connection is client
+ * initiated, we do nothing
+ */
+
+static void bc_destroy(struct rpc_xprt *xprt)
+{
+	return;
+}
+
 static struct rpc_xprt_ops xs_udp_ops = {
 	.set_buffer_size	= xs_udp_set_buffer_size,
 	.reserve_xprt		= xprt_reserve_xprt_cong,
@@ -1999,6 +2129,22 @@ static struct rpc_xprt_ops xs_tcp_ops = {
 	.print_stats		= xs_tcp_print_stats,
 };
 
+/*
+ * The rpc_xprt_ops for the server backchannel
+ */
+
+static struct rpc_xprt_ops bc_tcp_ops = {
+	.reserve_xprt		= xprt_reserve_xprt,
+	.release_xprt		= xprt_release_xprt,
+	.buf_alloc		= bc_malloc,
+	.buf_free		= bc_free,
+	.send_request		= bc_send_request,
+	.set_retrans_timeout	= xprt_set_retrans_timeout_def,
+	.close			= bc_close,
+	.destroy		= bc_destroy,
+	.print_stats		= xs_tcp_print_stats,
+};
+
 static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
 				      unsigned int slot_table_size)
 {
@@ -2130,14 +2276,43 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 	xprt->prot = IPPROTO_TCP;
 	xprt->tsh_size = sizeof(rpc_fraghdr) / sizeof(u32);
 	xprt->max_payload = RPC_MAX_FRAGMENT_SIZE;
+	xprt->timeout = &xs_tcp_default_timeout;
 
-	xprt->bind_timeout = XS_BIND_TO;
-	xprt->connect_timeout = XS_TCP_CONN_TO;
-	xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
-	xprt->idle_timeout = XS_IDLE_DISC_TO;
+	if (args->bc_sock) {
+		/* backchannel */
+		xprt_set_bound(xprt);
+		xprt->bind_timeout = 0;
+		xprt->connect_timeout = 0;
+		xprt->reestablish_timeout = 0;
+		xprt->idle_timeout = (~0);
 
-	xprt->ops = &xs_tcp_ops;
-	xprt->timeout = &xs_tcp_default_timeout;
+		/*
+		 * The backchannel uses the same socket connection as the
+		 * forechannel
+		 */
+		xprt->bc_sock = args->bc_sock;
+		xprt->bc_sock->sk_bc_xprt = xprt;
+		transport->sock = xprt->bc_sock->sk_sock;
+		transport->inet = xprt->bc_sock->sk_sk;
+
+		xprt->ops = &bc_tcp_ops;
+
+		switch (addr->sa_family) {
+		case AF_INET:
+			xs_format_ipv4_peer_addresses(xprt, "tcp",
+						      RPCBIND_NETID_TCP);
+			break;
+		case AF_INET6:
+			xs_format_ipv6_peer_addresses(xprt, "tcp",
+						      RPCBIND_NETID_TCP6);
+			break;
+		default:
+			kfree(xprt);
+			return ERR_PTR(-EAFNOSUPPORT);
+		}
+
+		goto out;
+	}
 
 	switch (addr->sa_family) {
 	case AF_INET:
@@ -2145,20 +2320,30 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 			xprt_set_bound(xprt);
 
 		INIT_DELAYED_WORK(&transport->connect_worker, xs_tcp_connect_worker4);
-		xs_format_ipv4_peer_addresses(xprt, "tcp", RPCBIND_NETID_TCP);
+		xs_format_ipv4_peer_addresses(xprt, "tcp",
+					      RPCBIND_NETID_TCP);
 		break;
 	case AF_INET6:
 		if (((struct sockaddr_in6 *)addr)->sin6_port != htons(0))
 			xprt_set_bound(xprt);
 
 		INIT_DELAYED_WORK(&transport->connect_worker, xs_tcp_connect_worker6);
-		xs_format_ipv6_peer_addresses(xprt, "tcp", RPCBIND_NETID_TCP6);
+		xs_format_ipv6_peer_addresses(xprt, "tcp",
+					      RPCBIND_NETID_TCP);
 		break;
 	default:
 		kfree(xprt);
 		return ERR_PTR(-EAFNOSUPPORT);
 	}
 
+	xprt->bind_timeout = XS_BIND_TO;
+	xprt->connect_timeout = XS_TCP_CONN_TO;
+	xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
+	xprt->idle_timeout = XS_IDLE_DISC_TO;
+
+	xprt->ops = &xs_tcp_ops;
+
+out:
 	dprintk("RPC:       set up transport to address %s\n",
 			xprt->address_strings[RPC_DISPLAY_ALL]);
 
-- 
1.6.3

