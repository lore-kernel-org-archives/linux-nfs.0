Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45905 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756510Ab0KPSU2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Nov 2010 13:20:28 -0500
Date: Tue, 16 Nov 2010 13:20:26 -0500
To: Mark Hills <mark@pogo.org.uk>
Cc: linux-nfs@vger.kernel.org, neilb@suse.de
Subject: Re: Listen backlog set to 64
Message-ID: <20101116182026.GA3971@fieldses.org>
References: <alpine.NEB.2.01.1011151822270.17883@jrf.vwaro.pbz>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.NEB.2.01.1011151822270.17883@jrf.vwaro.pbz>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Nov 15, 2010 at 06:43:52PM +0000, Mark Hills wrote:
> I am looking into an issue of hanging clients to a set of NFS servers, on 
> a large HPC cluster.
> 
> My investigation took me to the RPC code, svc_create_socket().
> 
> 	if (protocol == IPPROTO_TCP) {
> 		if ((error = kernel_listen(sock, 64)) < 0)
> 			goto bummer;
> 	}
> 
> A fixed backlog of 64 connections at the server seems like it could be too 
> low on a cluster like this, particularly when the protocol opens and 
> closes the TCP connection.
> 
> I wondered what is the rationale is behind this number, particuarly as it 
> is a fixed value. Perhaps there is a reason why this has no effect on 
> nfsd, or is this a FAQ for people on large systems?
> 
> The servers show overflow of a listening queue, which I imagine is 
> related.
> 
>   $ netstat -s
>   [...]
>   TcpExt:
>     6475 times the listen queue of a socket overflowed
>     6475 SYNs to LISTEN sockets ignored
> 
> The affected servers are old, kernel 2.6.9. But this limit of 64 is 
> consistent across that and the latest kernel source.

Looks like the last time that was touched was 8 years ago, by Neil (below, from
historical git archive).

I'd be inclined to just keep doubling it until people don't complain,
unless it's very expensive.  (How much memory (or whatever else) does a
pending connection tie up?)

The clients should be retrying, though, shouldn't they?

--b.

commit df0afc51f2f74756135c8bc08ec01134eb6de287
Author: Neil Brown <neilb@cse.unsw.edu.au>
Date:   Thu Aug 22 21:21:39 2002 -0700

    [PATCH] Fix two problems with multiple concurrent nfs/tcp connects.
    
    1/ connect requests would be get lost...
      As the comment at the top of svcsock.c says when discussing
      SK_CONN:
     *          after a set, svc_sock_enqueue must be called.
    
      We didn't and so lost conneciton requests.
    
    2/ set the max accept backlog to a more reasonable number to cope
       with bursts of lots of connection requests.

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index ab28937..bbeee09 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -679,6 +679,8 @@ svc_tcp_accept(struct svc_sock *svsk)
                goto failed;            /* aborted connection or whatever */
        }
        set_bit(SK_CONN, &svsk->sk_flags);
+       svc_sock_enqueue(svsk);
+
        slen = sizeof(sin);
        err = ops->getname(newsock, (struct sockaddr *) &sin, &slen, 1);
        if (err < 0) {
@@ -1220,7 +1222,7 @@ svc_create_socket(struct svc_serv *serv, int protocol, str
        }
 
        if (protocol == IPPROTO_TCP) {
-               if ((error = sock->ops->listen(sock, 5)) < 0)
+               if ((error = sock->ops->listen(sock, 64)) < 0)
                        goto bummer;
        }

