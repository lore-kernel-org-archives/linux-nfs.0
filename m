From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [NFS] [PATCH 4/7] SUNRPC: Use shutdown() instead of
	close()	when disconnecting a TCP socket
Date: Wed, 07 Nov 2007 18:59:13 -0500
Message-ID: <1194479953.7962.8.camel@heimdal.trondhjem.org>
References: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>
	<20071107003956.13713.51521.stgit@heimdal.trondhjem.org>
	<47324628.4080306@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
To: chuck.lever@oracle.com, sfrench@samba.org, Paul.Clements@steeleye.com
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <47324628.4080306@oracle.com>
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


On Wed, 2007-11-07 at 18:11 -0500, Chuck Lever wrote:
> Trond Myklebust wrote:
> > From: Trond Myklebust <Trond.Myklebust@netapp.com>
> > 
> > By using shutdown() rather than close() we allow the RPC client to wait
> > for the TCP close handshake to complete before we start trying to reconnect
> > using the same port.
> > We use shutdown(SHUT_WR) only instead of shutting down both directions,
> > however we wait until the server has closed the connection on its side.
> 
> Yeah, that seems like a more friendly and nuanced behavior, and is 
> probably one of the more important features of this set of changes.
> 
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > ---
> > 
> >  net/sunrpc/xprtsock.c |   53 +++++++++++++++++++++++++++++++++++++++++++------
> >  1 files changed, 46 insertions(+), 7 deletions(-)
> > 
> > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > index 99c0166..d610d28 100644
> > --- a/net/sunrpc/xprtsock.c
> > +++ b/net/sunrpc/xprtsock.c
> > @@ -614,6 +614,34 @@ static int xs_udp_send_request(struct rpc_task *task)
> >  	return status;
> >  }
> >  
> > +static int xs_shutdown(struct socket *sock, int how)
> > +{
> > +	/*
> > +	 * Note: 'how - 1' trick converts
> > +	 *        RCV_SHUTDOWN -> SHUT_RD = 0
> > +	 *        SEND_SHUTDOWN -> SHUT_WR = 1
> > +	 *        RCV_SHUTDOWN|SEND_SHUTDOWN -> SHUT_RDWR = 2
> > +	 */
> > +	return sock->ops->shutdown(sock, how - 1);
> > +}
> > +
> > +/**
> > + * xs_tcp_shutdown - gracefully shut down a TCP socket
> > + * @xprt: transport
> > + *
> > + * Initiates a graceful shutdown of the TCP socket by calling the
> > + * equivalent of shutdown(SHUT_WR);
> > + */
> > +static void xs_tcp_shutdown(struct rpc_xprt *xprt)
> > +{
> > +	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
> > +	struct socket *sock = transport->sock;
> > +
> > +	if (sock != NULL)
> > +		xs_shutdown(sock, SEND_SHUTDOWN);
> 
> I'm not sure why simply
> 
> 		sock->ops->shutdown(sock, SHUT_WR);
> 
> isn't adequate here.

trondmy@heimdal:~/devel/git/linux/kernel-2.6.x/linux-2.6$ git grep SHUT_WR
arch/um/os-Linux/file.c:#ifndef SHUT_WR
arch/um/os-Linux/file.c:#define SHUT_WR 1
arch/um/os-Linux/file.c:        else if(w) what = SHUT_WR;
net/sctp/socket.c: *               SHUT_WR

I suppose I could define SHUT_WR, but that would have to be part of a
separate patch, perhaps as part of a definition of a
kernel_sock_shutdown() wrapper. I wanted to get the RPC code right
first, then send in the cleanup via davem.

BTW: Both CIFS and NBD appear to be calling sock->ops->shutdown() with a
SEND_SHUTDOWN argument. From what I can read in inet_shutdown() that is
incorrect. (Ccing Steve and Paul).

> > +	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
> > +}
> > +
> >  static inline void xs_encode_tcp_record_marker(struct xdr_buf *buf)
> >  {
> >  	u32 reclen = buf->len - sizeof(rpc_fraghdr);
> > @@ -691,7 +719,7 @@ static int xs_tcp_send_request(struct rpc_task *task)
> >  	default:
> >  		dprintk("RPC:       sendmsg returned unrecognized error %d\n",
> >  			-status);
> > -		xprt_disconnect(xprt);
> > +		xs_tcp_shutdown(xprt);
> 
> Hrm.  I would have thought this case was handled adequately by 
> xprt_release_write?

Nope. We really do want to get rid of xprt_disconnect(). The
XPRT_CONNECTED flag needs to be managed by the transport, and the
transport alone. See Patch 7.

> >  		break;
> >  	}
> >  
> > @@ -1627,8 +1655,7 @@ static void xs_tcp_connect_worker4(struct work_struct *work)
> >  				break;
> >  			default:
> >  				/* get rid of existing socket, and retry */
> > -				xs_close(xprt);
> > -				break;
> > +				xs_tcp_shutdown(xprt);
> >  		}
> >  	}
> >  out:
> > @@ -1687,8 +1714,7 @@ static void xs_tcp_connect_worker6(struct work_struct *work)
> >  				break;
> >  			default:
> >  				/* get rid of existing socket, and retry */
> > -				xs_close(xprt);
> > -				break;
> > +				xs_tcp_shutdown(xprt);
> >  		}
> >  	}
> >  out:
> > @@ -1735,6 +1761,19 @@ static void xs_connect(struct rpc_task *task)
> >  	}
> >  }
> >  
> > +static void xs_tcp_connect(struct rpc_task *task)
> > +{
> > +	struct rpc_xprt *xprt = task->tk_xprt;
> > +
> > +	/* Initiate graceful shutdown of the socket if not already done */
> > +	if (!test_bit(XPRT_CONNECTING, &xprt->state))
> > +		xs_tcp_shutdown(xprt);
> > +	/* Exit if we need to wait for socket shutdown to complete */
> > +	if (test_bit(XPRT_CLOSING, &xprt->state))
> > +		return;
> > +	xs_connect(task);
> > +}
> > +
> >  /**
> >   * xs_udp_print_stats - display UDP socket-specifc stats
> >   * @xprt: rpc_xprt struct containing statistics
> 
> Adding xs_tcp_connect will allow a lot more clean up in xs_connect, 
> especially simplifying UDP transport connects.

Yup.

> > @@ -1805,12 +1844,12 @@ static struct rpc_xprt_ops xs_tcp_ops = {
> >  	.release_xprt		= xs_tcp_release_xprt,
> >  	.rpcbind		= rpcb_getport_async,
> >  	.set_port		= xs_set_port,
> > -	.connect		= xs_connect,
> > +	.connect		= xs_tcp_connect,
> >  	.buf_alloc		= rpc_malloc,
> >  	.buf_free		= rpc_free,
> >  	.send_request		= xs_tcp_send_request,
> >  	.set_retrans_timeout	= xprt_set_retrans_timeout_def,
> > -	.close			= xs_close,
> > +	.close			= xs_tcp_shutdown,
> >  	.destroy		= xs_destroy,
> >  	.print_stats		= xs_tcp_print_stats,
> >  };
