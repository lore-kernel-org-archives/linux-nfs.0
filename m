From: Kasparek Tomas <kasparek@fit.vutbr.cz>
Subject: Re: [PATCH 0/3] NFS regression in 2.6.26?, "task blocked for more
	than 120 seconds"
Date: Tue, 16 Dec 2008 13:10:11 +0100
Message-ID: <20081216121011.GT47559@fit.vutbr.cz>
References: <1227737539.31008.2.camel@localhost.localdomain> <1228090631.7112.11.camel@heimdal.trondhjem.org> <1228091380.7112.17.camel@heimdal.trondhjem.org> <20081202152256.GI47559@fit.vutbr.cz> <1228232222.3090.5.camel@heimdal.trondhjem.org> <20081202162625.GM47559@fit.vutbr.cz> <1228241407.3090.7.camel@heimdal.trondhjem.org> <20081204102314.GW47559@fit.vutbr.cz> <1229284201.6463.98.camel@heimdal.trondhjem.org> <20081216120547.GS47559@fit.vutbr.cz>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0lnxQi9hkpPO77W3"
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from kazi.fit.vutbr.cz ([147.229.8.12]:64556 "EHLO kazi.fit.vutbr.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752479AbYLPMKP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Dec 2008 07:10:15 -0500
In-Reply-To: <20081216120547.GS47559@fit.vutbr.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--0lnxQi9hkpPO77W3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Dec 16, 2008 at 01:05:47PM +0100, Kasparek Tomas wrote:
> On Sun, Dec 14, 2008 at 02:50:01PM -0500, Trond Myklebust wrote:
> > On Thu, 2008-12-04 at 11:23 +0100, Kasparek Tomas wrote:
> > > On Tue, Dec 02, 2008 at 01:10:07PM -0500, Trond Myklebust wrote:
> > > > On Tue, 2008-12-02 at 17:26 +0100, Kasparek Tomas wrote:
> > > > 
> > > > > Did tried. The number should be seconds and defaults to 60, These
> > > > > connections are still there after several hours. Changing it to 10 (sec)
> > > > > and same behaviour. (BTW The server did not changed in last several months)
> > > > 
> > > > Are you seeing the same behaviour with 'netstat -t'?
> > > 
> > > yes:
> > > 
> > > root@pckasparek: ~# ssh root@pcnlp1 'netstat -pan | grep WAIT' | cut -c-85
> > > tcp    0   0 147.229.12.146:989          147.229.176.14:2049 FIN_WAIT2
> > > root@pckasparek: ~# ssh root@pcnlp1 'netstat -t | grep WAIT' | cut -c-85
> > > tcp    0   0 pcnlp1.fit.vutbr.:ftps-data eva.fit.vutbr.cz:nfs FIN_WAIT2
> > > 
> > > but it should be the same, did't it? -t just selects TCP connections and
> > > this is TCP connection so it shows the same
> > 
> > Right, but the point is that the client is in the state FIN_WAIT2, which
> > means that it has closed the socket on its end, and is waiting for the
> > server to close on its end. The fact that the server is failing to do
> > this is a server bug.
> > 
> > That said, we can't wait forever for buggy servers. I see now why the
> > linger2 stuff isn't working. I believe that the appended patch should
> > help...
> 
> Hm, not happy to say that but it still does not work after some time. Now
> the problem is opposite there are no connections to the server according to
> netstat on client, just time to time there is
> 
> pcnlp1.fit.vutbr.cz.15234 > kazi.fit.vutbr.cz.nfs: 40 null
> kazi.fit.vutbr.cz.nfs > pcnlp1.fit.vutbr.cz.15234: reply ok 24 null
> 
> (kazi is server). Will try to investigate more details.
> 
> (just to remember the same kernel with reversed
> e06799f958bf7f9f8fae15f0c6f519953fb0257c works fine - exact patch is
> included - it was slightly modified to fit 2.6.27.x kernels)
> 
> Thank you very much for your help so far.

just the forgoten patch promised.

--   

  Tomas Kasparek, PhD student  E-mail: kasparek@fit.vutbr.cz
  CVT FIT VUT Brno, L127       Web:    http://www.fit.vutbr.cz/~kasparek
  Bozetechova 1, 612 66        Fax:    +420 54114-1270
  Brno, Czech Republic         Phone:  +420 54114-1220

  jabber: tomas.kasparek-2ASvDZBniIelVyrhU4qvOw@public.gmane.org
  GPG: 2F1E 1AAF FD3B CFA3 1537  63BD DCBE 18FF A035 53BC


--0lnxQi9hkpPO77W3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="linux-2.6.git-e06799f958bf7f9f8fae15f0c6f519953fb0257c-own-modified.patch"

diff -ruN linux-2.6.27.4/net/sunrpc/xprtsock.c linux-2.6.27.4-64/net/sunrpc/xprtsock.c
--- linux-2.6.27.4/net/sunrpc/xprtsock.c	2008-11-04 14:30:26.000000000 +0100
+++ linux-2.6.27.4-64/net/sunrpc/xprtsock.c	2008-11-25 19:11:34.000000000 +0100
@@ -615,22 +615,6 @@
 	return status;
 }
 
-/**
- * xs_tcp_shutdown - gracefully shut down a TCP socket
- * @xprt: transport
- *
- * Initiates a graceful shutdown of the TCP socket by calling the
- * equivalent of shutdown(SHUT_WR);
- */
-static void xs_tcp_shutdown(struct rpc_xprt *xprt)
-{
-	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
-	struct socket *sock = transport->sock;
-
-	if (sock != NULL)
-		kernel_sock_shutdown(sock, SHUT_WR);
-}
-
 static inline void xs_encode_tcp_record_marker(struct xdr_buf *buf)
 {
 	u32 reclen = buf->len - sizeof(rpc_fraghdr);
@@ -709,7 +693,8 @@
 		dprintk("RPC:       sendmsg returned unrecognized error %d\n",
 			-status);
 		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
-		xs_tcp_shutdown(xprt);
+ 		xprt_disconnect_done(xprt);
+        break;
 	}
 
 	return status;
@@ -1670,7 +1655,8 @@
 				break;
 			default:
 				/* get rid of existing socket, and retry */
-				xs_tcp_shutdown(xprt);
+				xs_close(xprt);
+				break;
 		}
 	}
 out:
@@ -1729,7 +1715,8 @@
 				break;
 			default:
 				/* get rid of existing socket, and retry */
-				xs_tcp_shutdown(xprt);
+				xs_close(xprt);
+				break;
 		}
 	}
 out:
@@ -1776,19 +1763,6 @@
 	}
 }
 
-static void xs_tcp_connect(struct rpc_task *task)
-{
-	struct rpc_xprt *xprt = task->tk_xprt;
-
-	/* Initiate graceful shutdown of the socket if not already done */
-	if (test_bit(XPRT_CONNECTED, &xprt->state))
-		xs_tcp_shutdown(xprt);
-	/* Exit if we need to wait for socket shutdown to complete */
-	if (test_bit(XPRT_CLOSING, &xprt->state))
-		return;
-	xs_connect(task);
-}
-
 /**
  * xs_udp_print_stats - display UDP socket-specifc stats
  * @xprt: rpc_xprt struct containing statistics
@@ -1859,12 +1833,12 @@
 	.release_xprt		= xs_tcp_release_xprt,
 	.rpcbind		= rpcb_getport_async,
 	.set_port		= xs_set_port,
-	.connect		= xs_tcp_connect,
+	.connect		= xs_connect,
 	.buf_alloc		= rpc_malloc,
 	.buf_free		= rpc_free,
 	.send_request		= xs_tcp_send_request,
 	.set_retrans_timeout	= xprt_set_retrans_timeout_def,
-	.close			= xs_tcp_shutdown,
+	.close			= xs_close,
 	.destroy		= xs_destroy,
 	.print_stats		= xs_tcp_print_stats,
 };

--0lnxQi9hkpPO77W3--
