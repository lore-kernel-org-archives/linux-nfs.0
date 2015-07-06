Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:39213 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753124AbbGFB05 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 5 Jul 2015 21:26:57 -0400
Date: Mon, 6 Jul 2015 11:26:47 +1000
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: handle -EAGAIN from socket writes better.
Message-ID: <20150706112647.2d4c3780@noble>
In-Reply-To: <1435931379-6654-1-git-send-email-trond.myklebust@primarydata.com>
References: <20150629142623.5afc0e6d@noble>
	<1435931379-6654-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri,  3 Jul 2015 09:49:37 -0400 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

> Hi Neil,
> 
> There should already be a handler for ENOBUFS in call_status, but
> I can see that it has a couple of flaws. What say we try to fix that
> instead?
> 
> Cheers
>   Trond
> 

Hi Trond,
 your patches make sense I think, but they are only part of a solution.
In the problem case the error comes from sk_stream_wait_memory, and
that returns EAGAIN, never ENOBUFS.  So fixing the handling of ENOBUFS
won't be enough.

The call path is
xs_tcp_send_request -> xs_sendpages -> xs_send_pagedata ->
   (sock->ops->sendpage == tcp_sendpage) -> do_tcp_sendpage ->  
     sk_stream_wait_memory

and EAGAIN travels all the way from bottom to top unmolested.

We could possibly change sk_stream_wait_memory to return ENOBUFS if
vm_wait is != 0, but:
  - that could have other consequences so needs to go through netdev
    and probably isn't a quick fix
  - there could be other paths that don't return ENOBUFS - it really
    don't seem that ENOBUFS appears all that much in 'net/' in places
    where it would need to...

Maybe we could check and translate the error in xs_sendpages:

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 66891e32c5e3..8474d79ec2b2 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -431,6 +431,14 @@ out:
 	if (err > 0) {
 		*sent_p += err;
 		err = 0;
+	} else if (err == -EAGAIN) {
+		/* Might be wrong error code. */
+		if (sock->sk->sk_write_space == xs_tcp_write_space &&
+		    sk_stream_is_writeable(sock->sk))
+			err = -ENOBUFS;
+		if (sock->sk->sk_write_space == xs_udp_write_space &&
+		    sock_writeable(sock->sk))
+			err = -ENOBUFS;
 	}
 	return err;
 }


Though that is a bit of a hack.  If/when net-dev gets the correct error
returns, we can then remove that.

Though I'm beginning to wonder if ENOBUFS is the correct error code
anyway. "man 2 send" suggests ENOMEM, with ENOBUFS meaning:

       The output queue for a network interface was full.   This
       generally  indicates that the interface has stopped send-
       ing, but may be caused by  transient  congestion.   (Nor-
       mally,  this  does  not occur in Linux.  Packets are just
       silently dropped when a device queue overflows.)

So I'm not sure I feel to comfortable about relying on the exact error
code.

What do you think?

Thanks,
NeilBrown
