From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [NFS] [PATCH 3/7] SUNRPC: Allow the client to detect if the
	TCP connection	is closed
Date: Fri, 09 Nov 2007 09:33:26 -0500
Message-ID: <1194618806.7459.44.camel@heimdal.trondhjem.org>
References: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>
	<20071107003950.13713.24126.stgit@heimdal.trondhjem.org>
	<EXNANE01OMyQlmLFQG100000900@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Chuck Lever <Chuck.Lever@oracle.com>,
	nfsv4@linux-nfs.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <EXNANE01OMyQlmLFQG100000900@exnane01.hq.netapp.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>


On Fri, 2007-11-09 at 09:04 -0500, Talpey, Thomas wrote:
> At 07:39 PM 11/6/2007, Trond Myklebust wrote:
> >From: Trond Myklebust <Trond.Myklebust@netapp.com>
> >
> >Add an xprt->state bit to enable the TCP ->state_change() method to signal
> >whether or not the TCP connection is in the process of closing down.
> >This will to be used by the reconnection logic in a separate patch.
> >
> >Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> >---
> >
> > include/linux/sunrpc/xprt.h |    1 +
> > net/sunrpc/xprtsock.c       |   20 +++++++++++++++++---
> > 2 files changed, 18 insertions(+), 3 deletions(-)
> >
> >diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> >index 6f524a9..afb9e6a 100644
> >--- a/include/linux/sunrpc/xprt.h
> >+++ b/include/linux/sunrpc/xprt.h
> >@@ -257,6 +257,7 @@ void			xprt_force_disconnect(struct rpc_xprt *xprt);
> > #define XPRT_CLOSE_WAIT		(3)
> > #define XPRT_BOUND		(4)
> > #define XPRT_BINDING		(5)
> >+#define XPRT_CLOSING		(6)
> > 
> > static inline void xprt_set_connected(struct rpc_xprt *xprt)
> > {
> >diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> >index 5a83a40..99c0166 100644
> >--- a/net/sunrpc/xprtsock.c
> >+++ b/net/sunrpc/xprtsock.c
> >@@ -758,7 +758,9 @@ static void xs_close(struct rpc_xprt *xprt)
> > 	sock_release(sock);
> > clear_close_wait:
> > 	smp_mb__before_clear_bit();
> >+	clear_bit(XPRT_CONNECTED, &xprt->state);
> > 	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
> >+	clear_bit(XPRT_CLOSING, &xprt->state);
> > 	smp_mb__after_clear_bit();
> > }
> > 
> >@@ -1114,13 +1116,25 @@ static void xs_tcp_state_change(struct sock *sk)
> > 		}
> > 		spin_unlock_bh(&xprt->transport_lock);
> > 		break;
> >-	case TCP_SYN_SENT:
> >-	case TCP_SYN_RECV:
> 
> Why are you removing these states from the switch?

There is no need for any special handling for these states, so just fall
through.

> >+	case TCP_FIN_WAIT1:
> >+		/* The client initiated a shutdown of the socket */
> 
> If the client initiated this, why does the bit management need to wait
> for TCP to change state? I think what this means is that the client
> initiated a FIN, *and* the server has acked it. Both these bits could
> have been set when the FIN was sent, basically. Or is there some
> subtlety here, in which case the comment should say more.

No. TCP_FIN_WAIT1 is the standard name in TCP parlance for the state
where the client has sent a FIN to the server, and is waiting for an ACK
and/or a FIN in reply. See one of Stevens' famous TCP state diagrams.

The TCP layer is therefore notifying us of this state change via the
socket's sk->sk_state_change() callback. All we're doing in response is
therefore to set the flags in the struct xprt to indicate that we have
initiated a shutdown of the socket.

> >+		set_bit(XPRT_CLOSING, &xprt->state);
> >+		smp_mb__before_clear_bit();
> >+		clear_bit(XPRT_CONNECTED, &xprt->state);
> >+		smp_mb__after_clear_bit();
> > 		break;
> > 	case TCP_CLOSE_WAIT:
> >+		/* The server initiated a shutdown of the socket */
> >+		set_bit(XPRT_CLOSING, &xprt->state);
> >+		smp_mb__before_clear_bit();
> >+		clear_bit(XPRT_CONNECTED, &xprt->state);
> >+		smp_mb__after_clear_bit();
> > 		xprt_force_disconnect(xprt);
> >-	default:
> >+		break;
> >+	case TCP_CLOSE:
> >+		/* Mark transport as closed and wake up all pending tasks */
> > 		xprt_disconnect(xprt);
> >+		clear_bit(XPRT_CLOSING, &xprt->state);
> > 	}
> >  out:
> > 	read_unlock(&sk->sk_callback_lock);
> >
> >
> >-------------------------------------------------------------------------
> >This SF.net email is sponsored by: Splunk Inc.
> >Still grepping through log files to find problems?  Stop.
> >Now Search log events and configuration files using AJAX and a browser.
> >Download your FREE copy of Splunk now >> http://get.splunk.com/
> >_______________________________________________
> >NFS maillist  -  NFS@lists.sourceforge.net
> >https://lists.sourceforge.net/lists/listinfo/nfs
> _______________________________________________
> NFSv4 mailing list
> NFSv4@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
