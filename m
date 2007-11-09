From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [NFS] [PATCH 4/7] SUNRPC: Use shutdown() instead of close()
	when	disconnecting a TCP socket
Date: Fri, 09 Nov 2007 08:51:34 -0500
Message-ID: <1194616294.7459.18.camel@heimdal.trondhjem.org>
References: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>
	<20071107003956.13713.51521.stgit@heimdal.trondhjem.org>
	<EXNANE01FapNuT1FM1J000008fe@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Chuck Lever <Chuck.Lever@oracle.com>,
	nfsv4@linux-nfs.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <EXNANE01FapNuT1FM1J000008fe@exnane01.hq.netapp.com>
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


On Fri, 2007-11-09 at 08:38 -0500, Talpey, Thomas wrote:
> At 07:39 PM 11/6/2007, Trond Myklebust wrote:
> >From: Trond Myklebust <Trond.Myklebust@netapp.com>
> >
> >By using shutdown() rather than close() we allow the RPC client to wait
> >for the TCP close handshake to complete before we start trying to reconnect
> >using the same port.
> >We use shutdown(SHUT_WR) only instead of shutting down both directions,
> >however we wait until the server has closed the connection on its side.
> >
> >Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> >---
> >
> > net/sunrpc/xprtsock.c |   53 +++++++++++++++++++++++++++++++++++++++++++------
> > 1 files changed, 46 insertions(+), 7 deletions(-)
> >
> >diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> >index 99c0166..d610d28 100644
> >--- a/net/sunrpc/xprtsock.c
> >+++ b/net/sunrpc/xprtsock.c
> >@@ -614,6 +614,34 @@ static int xs_udp_send_request(struct rpc_task *task)
> > 	return status;
> > }
> > 
> >+static int xs_shutdown(struct socket *sock, int how)
> >+{
> >+	/*
> >+	* Note: 'how - 1' trick converts
> >+	*        RCV_SHUTDOWN -> SHUT_RD = 0
> >+	*        SEND_SHUTDOWN -> SHUT_WR = 1
> >+	*        RCV_SHUTDOWN|SEND_SHUTDOWN -> SHUT_RDWR = 2
> >+	*/
> >+	return sock->ops->shutdown(sock, how - 1);
> 
> These #defines might be better if they had XPRT_ or RPCXPRT_ in front
> of them to make it clear they're flags for an RPC API. All by themselves
> they kind of look like a standard networking component.

They're not #defines, but just a comment...

However yesterday I did submit a patch to clean this up by providing the
proper functionality in the networking layer. See

   http://article.gmane.org/gmane.linux.network/77163

Cheers
  Trond
