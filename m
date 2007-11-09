From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH 3/7] SUNRPC: Allow the client to detect if the TCP
 connection	is closed
Date: Fri, 09 Nov 2007 09:04:04 -0500
Message-ID: <EXNANE01OMyQlmLFQG100000900@exnane01.hq.netapp.com>
References: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>
	<20071107003950.13713.24126.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, Chuck Lever <Chuck.Lever@oracle.com>,
	Tom Talpey <Thomas.Talpey@netapp.com>, nfs@lists.sourceforge.net
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IqUSs-0004Za-0u
	for nfs@lists.sourceforge.net; Fri, 09 Nov 2007 06:04:06 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IqUSx-0005uE-E8
	for nfs@lists.sourceforge.net; Fri, 09 Nov 2007 06:04:11 -0800
In-Reply-To: <20071107003950.13713.24126.stgit@heimdal.trondhjem.org>
References: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>
	<20071107003950.13713.24126.stgit@heimdal.trondhjem.org>
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
>Add an xprt->state bit to enable the TCP ->state_change() method to signal
>whether or not the TCP connection is in the process of closing down.
>This will to be used by the reconnection logic in a separate patch.
>
>Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>---
>
> include/linux/sunrpc/xprt.h |    1 +
> net/sunrpc/xprtsock.c       |   20 +++++++++++++++++---
> 2 files changed, 18 insertions(+), 3 deletions(-)
>
>diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
>index 6f524a9..afb9e6a 100644
>--- a/include/linux/sunrpc/xprt.h
>+++ b/include/linux/sunrpc/xprt.h
>@@ -257,6 +257,7 @@ void			xprt_force_disconnect(struct rpc_xprt *xprt);
> #define XPRT_CLOSE_WAIT		(3)
> #define XPRT_BOUND		(4)
> #define XPRT_BINDING		(5)
>+#define XPRT_CLOSING		(6)
> 
> static inline void xprt_set_connected(struct rpc_xprt *xprt)
> {
>diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>index 5a83a40..99c0166 100644
>--- a/net/sunrpc/xprtsock.c
>+++ b/net/sunrpc/xprtsock.c
>@@ -758,7 +758,9 @@ static void xs_close(struct rpc_xprt *xprt)
> 	sock_release(sock);
> clear_close_wait:
> 	smp_mb__before_clear_bit();
>+	clear_bit(XPRT_CONNECTED, &xprt->state);
> 	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
>+	clear_bit(XPRT_CLOSING, &xprt->state);
> 	smp_mb__after_clear_bit();
> }
> 
>@@ -1114,13 +1116,25 @@ static void xs_tcp_state_change(struct sock *sk)
> 		}
> 		spin_unlock_bh(&xprt->transport_lock);
> 		break;
>-	case TCP_SYN_SENT:
>-	case TCP_SYN_RECV:

Why are you removing these states from the switch?

>+	case TCP_FIN_WAIT1:
>+		/* The client initiated a shutdown of the socket */

If the client initiated this, why does the bit management need to wait
for TCP to change state? I think what this means is that the client
initiated a FIN, *and* the server has acked it. Both these bits could
have been set when the FIN was sent, basically. Or is there some
subtlety here, in which case the comment should say more.

Tom.


>+		set_bit(XPRT_CLOSING, &xprt->state);
>+		smp_mb__before_clear_bit();
>+		clear_bit(XPRT_CONNECTED, &xprt->state);
>+		smp_mb__after_clear_bit();
> 		break;
> 	case TCP_CLOSE_WAIT:
>+		/* The server initiated a shutdown of the socket */
>+		set_bit(XPRT_CLOSING, &xprt->state);
>+		smp_mb__before_clear_bit();
>+		clear_bit(XPRT_CONNECTED, &xprt->state);
>+		smp_mb__after_clear_bit();
> 		xprt_force_disconnect(xprt);
>-	default:
>+		break;
>+	case TCP_CLOSE:
>+		/* Mark transport as closed and wake up all pending tasks */
> 		xprt_disconnect(xprt);
>+		clear_bit(XPRT_CLOSING, &xprt->state);
> 	}
>  out:
> 	read_unlock(&sk->sk_callback_lock);
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
