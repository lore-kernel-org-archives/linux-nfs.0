Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:30153 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753944Ab3JaN3l convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Oct 2013 09:29:41 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: NeilBrown <neilb@suse.de>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: close a rare race in xs_tcp_setup_socket.
Date: Thu, 31 Oct 2013 13:29:40 +0000
Message-ID: <1383226179.18107.8.camel@leira.trondhjem.org>
References: <20131031161436.22969327@notabene.brown>
In-Reply-To: <20131031161436.22969327@notabene.brown>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-10-31 at 16:14 +-1100, NeilBrown wrote:
+AD4- 
+AD4- We have one report of a crash in xs+AF8-tcp+AF8-setup+AF8-socket.
+AD4- The call path to the crash is:
+AD4- 
+AD4-   xs+AF8-tcp+AF8-setup+AF8-socket -+AD4- inet+AF8-stream+AF8-connect -+AD4- lock+AF8-sock+AF8-nested.
+AD4- 
+AD4- The 'sock' passed to that last function is NULL.
+AD4- 
+AD4- The only way I can see this happening is a concurrent call to
+AD4- xs+AF8-close:
+AD4- 
+AD4-   xs+AF8-close -+AD4- xs+AF8-reset+AF8-transport -+AD4- sock+AF8-release -+AD4- inet+AF8-release
+AD4- 
+AD4- inet+AF8-release sets:
+AD4-    sock-+AD4-sk +AD0- NULL+ADs-
+AD4- inet+AF8-stream+AF8-connect calls
+AD4-    lock+AF8-sock(sock-+AD4-sk)+ADs-
+AD4- which gets NULL.
+AD4- 
+AD4- All calls to xs+AF8-close are protected by XPRT+AF8-LOCKED as are most
+AD4- activations of the workqueue which runs xs+AF8-tcp+AF8-setup+AF8-socket.
+AD4- The exception is xs+AF8-tcp+AF8-schedule+AF8-linger+AF8-timeout.
+AD4- 
+AD4- So presumably the timeout queued by the later fires exactly when some
+AD4- other code runs xs+AF8-close().
+AD4- 
+AD4- To protect against this we can move the cancel+AF8-delayed+AF8-work+AF8-sync()
+AD4- call from xs+AF8-destory() to xs+AF8-close().
+AD4- 
+AD4- As xs+AF8-close is never called from the worker scheduled on
+AD4- -+AD4-connect+AF8-worker, this can never deadlock.
+AD4- 
+AD4- Signed-off-by: NeilBrown +ADw-neilb+AEA-suse.de+AD4-
+AD4- 
+AD4- diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
+AD4- index ee03d35677d9..b19ba535ae1a 100644
+AD4- --- a/net/sunrpc/xprtsock.c
+AD4- +-+-+- b/net/sunrpc/xprtsock.c
+AD4- +AEAAQA- -835,6 +-835,8 +AEAAQA- static void xs+AF8-close(struct rpc+AF8-xprt +ACo-xprt)
+AD4-  
+AD4-  	dprintk(+ACI-RPC:       xs+AF8-close xprt +ACU-p+AFw-n+ACI-, xprt)+ADs-
+AD4-  
+AD4- +-	cancel+AF8-delayed+AF8-work+AF8-sync(+ACY-transport-+AD4-connect+AF8-worker)+ADs-
+AD4- +-
+AD4-  	xs+AF8-reset+AF8-transport(transport)+ADs-
+AD4-  	xprt-+AD4-reestablish+AF8-timeout +AD0- 0+ADs-
+AD4-  
+AD4- +AEAAQA- -869,12 +-871,8 +AEAAQA- static void xs+AF8-local+AF8-destroy(struct rpc+AF8-xprt +ACo-xprt)
+AD4-   +ACo-/
+AD4-  static void xs+AF8-destroy(struct rpc+AF8-xprt +ACo-xprt)
+AD4-  +AHs-
+AD4- -	struct sock+AF8-xprt +ACo-transport +AD0- container+AF8-of(xprt, struct sock+AF8-xprt, xprt)+ADs-
+AD4- -
+AD4-  	dprintk(+ACI-RPC:       xs+AF8-destroy xprt +ACU-p+AFw-n+ACI-, xprt)+ADs-
+AD4-  
+AD4- -	cancel+AF8-delayed+AF8-work+AF8-sync(+ACY-transport-+AD4-connect+AF8-worker)+ADs-
+AD4- -
+AD4-  	xs+AF8-local+AF8-destroy(xprt)+ADs-
+AD4-  +AH0-
+AD4-  

Hi Neil,

I noticed one small issue when applying: transport-+AD4-connect+AF8-worker is
not initialised for the AF+AF8-LOCAL case. I therefore added a dummy
initialiser to xs+AF8-setup+AF8-local().

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
