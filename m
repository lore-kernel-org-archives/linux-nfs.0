From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen-pxSi+dnQzZMxHbG02/KK1g@public.gmane.org>
Subject: Re: [PATCH] net/sunrpc/xprtsock.c: some common code found
Date: Sat, 7 Feb 2009 00:58:44 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0902070040530.31875@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0902062247500.31842@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0902062251501.31842@wrl-59.cs.helsinki.fi>
 <20090206212043.GA1216@fieldses.org> <20090206.140714.201930500.davem@davemloft.net>
 <CAF18546-B024-40C9-8276-8FCD89C98E72@oracle.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary=Apple-Mail-9-102147012
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond@netapp.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50206 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbZBFW6q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Feb 2009 17:58:46 -0500
In-Reply-To: <CAF18546-B024-40C9-8276-8FCD89C98E72@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--Apple-Mail-9-102147012
Content-Type: TEXT/PLAIN; charset=ISO-8859-1; format=flowed; delsp=yes
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0902070040532.31875-x/A8LOkYjdVsRR2hCrRKtT03IgOmwywn@public.gmane.org>

On Fri, 6 Feb 2009, Chuck Lever wrote:

> On Feb 6, 2009, at Feb 6, 2009, 5:07 PM, David Miller wrote:
> >From: "J. Bruce Fields" <bfields@fieldses.org>
> >Date: Fri, 6 Feb 2009 16:20:43 -0500
> >
> > >On Fri, Feb 06, 2009 at 10:53:32PM +0200, Ilpo Järvinen wrote:
> > > >Grr, forgot to cc sunrpc maintainer... Added. Just ask if somebody wants
> > > >a complete resend.
> > >
> > >You probably wanted Trond, actually.  (And did this patch have a
> > >changelog?)
> >
> >Open your eyes :-)  That first "diff" you see is part of the
> >commit message not the patch itself.
> 
> There needs to be an explanation (in English not in source code)

Hmm, so you didn't heed Dave's warning... :-D

I think your "English" is too strict requirement. There's patch title 
which tells what is found, in plain English. And _the explanation_ is 
there too, but using two tools (and their names are certainly 
self-explanary): diff-funcs and codiff. The output of the tools shows why 
this is useful (and every developer capable of reviewing patches in the 
first place should be able to understand the output format of the tools in 
question). If you don't care the output but dismiss that as "source code" 
there's nothing I can do to help you _to review_ the patch by writing 
paragraphs of text about the change. But just to make it even easier for 
you I've added one sentence more, in English before codiff ;-).

> of why this change is needed, even if you are simply refactoring code or 
> correcting a comment.

It's there. Read again :-).

> A short description that starts with "SUNRPC: " is also recommended, and
> please copy linux-nfs@vger.kernel.org when submitting RPC-related patches.

Well, I've changed the title now to please all. :-)

--
[PATCH] SUNRPC: some common code found in xprtsock.c; call to that

$ diff-funcs xs_udp_write_space net/sunrpc/xprtsock.c
net/sunrpc/xprtsock.c xs_tcp_write_space
 --- net/sunrpc/xprtsock.c:xs_udp_write_space()
 +++ net/sunrpc/xprtsock.c:xs_tcp_write_space()
@@ -1,4 +1,4 @@
- * xs_udp_write_space - callback invoked when socket buffer space
+ * xs_tcp_write_space - callback invoked when socket buffer space
  *                             becomes available
  * @sk: socket whose state has changed
  *
@@ -7,12 +7,12 @@
  * progress, otherwise we'll waste resources thrashing kernel_sendmsg
  * with a bunch of small requests.
  */
-static void xs_udp_write_space(struct sock *sk)
+static void xs_tcp_write_space(struct sock *sk)
 {
 	read_lock(&sk->sk_callback_lock);

-	/* from net/core/sock.c:sock_def_write_space */
-	if (sock_writeable(sk)) {
+	/* from net/core/stream.c:sk_stream_write_space */
+	if (sk_stream_wspace(sk) >= sk_stream_min_wspace(sk)) {
 		struct socket *sock;
 		struct rpc_xprt *xprt;

Besides less copy-paste, some space savings (measured allmodconfig 
x86_64) after the change:

$ codiff net/sunrpc/xprtsock.o net/sunrpc/xprtsock.o.new
net/sunrpc/xprtsock.c:
  xs_tcp_write_space | -163
  xs_udp_write_space | -163
 2 functions changed, 326 bytes removed

net/sunrpc/xprtsock.c:
  xs_write_space | +179
 1 function changed, 179 bytes added

net/sunrpc/xprtsock.o.new:
 3 functions changed, 179 bytes added, 326 bytes removed, diff: -147

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen-pxSi+dnQzZMxHbG02/KK1g@public.gmane.org>
---
 net/sunrpc/xprtsock.c |   53 +++++++++++++++++++-----------------------------
 1 files changed, 21 insertions(+), 32 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 5cbb404..b49e434 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1215,6 +1215,23 @@ out:
 	read_unlock(&sk->sk_callback_lock);
 }
 
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
 /**
  * xs_udp_write_space - callback invoked when socket buffer space
  *                             becomes available
@@ -1230,23 +1247,9 @@ static void xs_udp_write_space(struct sock *sk)
 	read_lock(&sk->sk_callback_lock);
 
 	/* from net/core/sock.c:sock_def_write_space */
-	if (sock_writeable(sk)) {
-		struct socket *sock;
-		struct rpc_xprt *xprt;
-
-		if (unlikely(!(sock = sk->sk_socket)))
-			goto out;
-		clear_bit(SOCK_NOSPACE, &sock->flags);
-
-		if (unlikely(!(xprt = xprt_from_sock(sk))))
-			goto out;
-		if (test_and_clear_bit(SOCK_ASYNC_NOSPACE, &sock->flags) == 0)
-			goto out;
-
-		xprt_write_space(xprt);
-	}
+	if (sock_writeable(sk))
+		xs_write_space(sk);
 
- out:
 	read_unlock(&sk->sk_callback_lock);
 }
 
@@ -1265,23 +1268,9 @@ static void xs_tcp_write_space(struct sock *sk)
 	read_lock(&sk->sk_callback_lock);
 
 	/* from net/core/stream.c:sk_stream_write_space */
-	if (sk_stream_wspace(sk) >= sk_stream_min_wspace(sk)) {
-		struct socket *sock;
-		struct rpc_xprt *xprt;
-
-		if (unlikely(!(sock = sk->sk_socket)))
-			goto out;
-		clear_bit(SOCK_NOSPACE, &sock->flags);
+	if (sk_stream_wspace(sk) >= sk_stream_min_wspace(sk))
+		xs_write_space(sk);
 
-		if (unlikely(!(xprt = xprt_from_sock(sk))))
-			goto out;
-		if (test_and_clear_bit(SOCK_ASYNC_NOSPACE, &sock->flags) == 0)
-			goto out;
-
-		xprt_write_space(xprt);
-	}
-
- out:
 	read_unlock(&sk->sk_callback_lock);
 }
 
-- 
1.5.6.5
--Apple-Mail-9-102147012--
