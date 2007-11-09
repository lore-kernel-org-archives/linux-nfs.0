From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH 4/7] SUNRPC: Use shutdown() instead of close()
 when	disconnecting a TCP socket
Date: Fri, 09 Nov 2007 08:38:23 -0500
Message-ID: <EXNANE01FapNuT1FM1J000008fe@exnane01.hq.netapp.com>
References: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>
	<20071107003956.13713.51521.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, Chuck Lever <Chuck.Lever@oracle.com>,
	Tom Talpey <Thomas.Talpey@netapp.com>, nfs@lists.sourceforge.net
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IqU40-0001xH-SK
	for nfs@lists.sourceforge.net; Fri, 09 Nov 2007 05:38:24 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IqU46-0001I6-De
	for nfs@lists.sourceforge.net; Fri, 09 Nov 2007 05:38:30 -0800
In-Reply-To: <20071107003956.13713.51521.stgit@heimdal.trondhjem.org>
References: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>
	<20071107003956.13713.51521.stgit@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

At 07:39 PM 11/6/2007, Trond Myklebust wrote:
>From: Trond Myklebust <Trond.Myklebust@netapp.com>
>
>By using shutdown() rather than close() we allow the RPC client to wait
>for the TCP close handshake to complete before we start trying to reconnect
>using the same port.
>We use shutdown(SHUT_WR) only instead of shutting down both directions,
>however we wait until the server has closed the connection on its side.
>
>Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>---
>
> net/sunrpc/xprtsock.c |   53 +++++++++++++++++++++++++++++++++++++++++++------
> 1 files changed, 46 insertions(+), 7 deletions(-)
>
>diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>index 99c0166..d610d28 100644
>--- a/net/sunrpc/xprtsock.c
>+++ b/net/sunrpc/xprtsock.c
>@@ -614,6 +614,34 @@ static int xs_udp_send_request(struct rpc_task *task)
> 	return status;
> }
> 
>+static int xs_shutdown(struct socket *sock, int how)
>+{
>+	/*
>+	* Note: 'how - 1' trick converts
>+	*        RCV_SHUTDOWN -> SHUT_RD = 0
>+	*        SEND_SHUTDOWN -> SHUT_WR = 1
>+	*        RCV_SHUTDOWN|SEND_SHUTDOWN -> SHUT_RDWR = 2
>+	*/
>+	return sock->ops->shutdown(sock, how - 1);

These #defines might be better if they had XPRT_ or RPCXPRT_ in front
of them to make it clear they're flags for an RPC API. All by themselves
they kind of look like a standard networking component.

Tom.

>+}
>+
>+/**
>+ * xs_tcp_shutdown - gracefully shut down a TCP socket
>+ * @xprt: transport
>+ *
>+ * Initiates a graceful shutdown of the TCP socket by calling the
>+ * equivalent of shutdown(SHUT_WR);
>+ */
>+static void xs_tcp_shutdown(struct rpc_xprt *xprt)
>+{
>+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
>+	struct socket *sock = transport->sock;
>+
>+	if (sock != NULL)
>+		xs_shutdown(sock, SEND_SHUTDOWN);
>+	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
>+}
>+
> static inline void xs_encode_tcp_record_marker(struct xdr_buf *buf)
> {
> 	u32 reclen = buf->len - sizeof(rpc_fraghdr);
>@@ -691,7 +719,7 @@ static int xs_tcp_send_request(struct rpc_task *task)
> 	default:
> 		dprintk("RPC:       sendmsg returned unrecognized error %d\n",
> 			-status);
>-		xprt_disconnect(xprt);
>+		xs_tcp_shutdown(xprt);
> 		break;
> 	}
> 
>@@ -1627,8 +1655,7 @@ static void xs_tcp_connect_worker4(struct 
>work_struct *work)
> 				break;
> 			default:
> 				/* get rid of existing socket, and retry */
>-				xs_close(xprt);
>-				break;
>+				xs_tcp_shutdown(xprt);
> 		}
> 	}
> out:
>@@ -1687,8 +1714,7 @@ static void xs_tcp_connect_worker6(struct 
>work_struct *work)
> 				break;
> 			default:
> 				/* get rid of existing socket, and retry */
>-				xs_close(xprt);
>-				break;
>+				xs_tcp_shutdown(xprt);
> 		}
> 	}
> out:
>@@ -1735,6 +1761,19 @@ static void xs_connect(struct rpc_task *task)
> 	}
> }
> 
>+static void xs_tcp_connect(struct rpc_task *task)
>+{
>+	struct rpc_xprt *xprt = task->tk_xprt;
>+
>+	/* Initiate graceful shutdown of the socket if not already done */
>+	if (!test_bit(XPRT_CONNECTING, &xprt->state))
>+		xs_tcp_shutdown(xprt);
>+	/* Exit if we need to wait for socket shutdown to complete */
>+	if (test_bit(XPRT_CLOSING, &xprt->state))
>+		return;
>+	xs_connect(task);
>+}
>+
> /**
>  * xs_udp_print_stats - display UDP socket-specifc stats
>  * @xprt: rpc_xprt struct containing statistics
>@@ -1805,12 +1844,12 @@ static struct rpc_xprt_ops xs_tcp_ops = {
> 	.release_xprt		= xs_tcp_release_xprt,
> 	.rpcbind		= rpcb_getport_async,
> 	.set_port		= xs_set_port,
>-	.connect		= xs_connect,
>+	.connect		= xs_tcp_connect,
> 	.buf_alloc		= rpc_malloc,
> 	.buf_free		= rpc_free,
> 	.send_request		= xs_tcp_send_request,
> 	.set_retrans_timeout	= xprt_set_retrans_timeout_def,
>-	.close			= xs_close,
>+	.close			= xs_tcp_shutdown,
> 	.destroy		= xs_destroy,
> 	.print_stats		= xs_tcp_print_stats,
> };
>
>
>-------------------------------------------------------------------------
>This SF.net email is sponsored by: Splunk Inc.
>Still grepping through log files to find problems?  Stop.
>Now Search log events and configuration files using AJAX and a browser.
>Download your FREE copy of Splunk now >> http://get.splunk.com/
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
