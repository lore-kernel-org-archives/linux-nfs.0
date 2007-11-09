From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [NFS] [PATCH 5/7] SUNRPC: xprt_autoclose() should not call
	xprt_disconnect()
Date: Fri, 09 Nov 2007 08:56:35 -0500
Message-ID: <EXNANE01sdAefpGtS79000008ff@exnane01.hq.netapp.com>
References: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>
	<20071107004001.13713.508.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, Chuck Lever <Chuck.Lever@oracle.com>,
	nfs@lists.sourceforge.net
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20071107004001.13713.508.stgit@heimdal.trondhjem.org>
References: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>
	<20071107004001.13713.508.stgit@heimdal.trondhjem.org>
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

At 07:40 PM 11/6/2007, Trond Myklebust wrote:
>From: Trond Myklebust <Trond.Myklebust@netapp.com>
>
>The transport layer should do that itself whenever appropriate.
>
>Note that the RDMA transport already assumes that it needs to call
>xprt_disconnect in xprt_rdma_close().

This was an interesting issue, IIRC. With RDMA, there is no way to
cancel an individual RDMA that might be arrive later from the peer,
you have to break the connection to do so. (Well, there are other
ways but they're expensive and don't make sense when you're about
to close anyway). But if the transport were to simply slam the connection
closed, any other RPC tasks would potentially initiate recovery when
the disconnect event bubbled up.

So, the best solution turned out to be to close the RPC door and the
transport door separately. Except for the order in which it's happening
this is basically what you're coding here, so I'm glad to see it consistent
now. 


Tom.

>For TCP sockets, we want to call xprt_disconnect() only after the
>connection has been closed by both ends.
>
>Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>---
>
> net/sunrpc/xprt.c     |    1 -
> net/sunrpc/xprtsock.c |    3 +--
> 2 files changed, 1 insertions(+), 3 deletions(-)
>
>diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>index 48c5a8b..fcdc4b8 100644
>--- a/net/sunrpc/xprt.c
>+++ b/net/sunrpc/xprt.c
>@@ -568,7 +568,6 @@ static void xprt_autoclose(struct work_struct *work)
> 	struct rpc_xprt *xprt =
> 		container_of(work, struct rpc_xprt, task_cleanup);
> 
>-	xprt_disconnect(xprt);
> 	xprt->ops->close(xprt);
> 	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
> 	xprt_release_write(xprt, NULL);
>diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>index d610d28..c0aa2b4 100644
>--- a/net/sunrpc/xprtsock.c
>+++ b/net/sunrpc/xprtsock.c
>@@ -786,10 +786,10 @@ static void xs_close(struct rpc_xprt *xprt)
> 	sock_release(sock);
> clear_close_wait:
> 	smp_mb__before_clear_bit();
>-	clear_bit(XPRT_CONNECTED, &xprt->state);
> 	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
> 	clear_bit(XPRT_CLOSING, &xprt->state);
> 	smp_mb__after_clear_bit();
>+	xprt_disconnect(xprt);
> }
> 
> /**
>@@ -805,7 +805,6 @@ static void xs_destroy(struct rpc_xprt *xprt)
> 
> 	cancel_rearming_delayed_work(&transport->connect_worker);
> 
>-	xprt_disconnect(xprt);
> 	xs_close(xprt);
> 	xs_free_peer_addresses(xprt);
> 	kfree(xprt->slot);
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
