Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:22339 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752182AbcGAWeJ convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jul 2016 18:34:09 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Rostedt Steven <rostedt@goodmis.org>
CC: LKML <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trondmy@primarydata.com>,
        "Jeff Layton" <jlayton@poochiereds.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Schumaker Anna <anna.schumaker@netapp.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Fields Bruce <bfields@fieldses.org>,
        "Torvalds Linus" <torvalds@linux-foundation.org>
Subject: Re: Revert: SUNRPC: xs_sock_mark_closed() does not need to trigger
 socket autoclose
Date: Fri, 1 Jul 2016 22:34:02 +0000
Message-ID: <0A51DE9E-81B2-474A-BA07-55C3BE19629A@primarydata.com>
References: <20160701172401.3ba89015@gandalf.local.home>
In-Reply-To: <20160701172401.3ba89015@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 1, 2016, at 17:24, Steven Rostedt <rostedt@goodmis.org> wrote:
> 
> A while back, rkhunter reported a "hidden port" on my main server,
> making me nervous that I had been hacked. Doing lots of debugging, I
> found that it was happening from xprt code in NFS. I found a way to
> trigger the bug, which happened because my wife's machine was NFS
> mounting a directory of my main server. She does this to upload her
> photos quickly to gallery2.
> 
>  "Warning: Hidden ports found:
>         Port number: TCP:871"
> 
> A hidden port is one that has no socket connected to it. That is, it's
> a dead resource. Nothing can ever use that port. It's not something
> that is "reserved", it's just a leaked bit of info. rkhunter treats
> this as a possible root kit attack.

No, it’s not leaked at all; it is still being tracked by the RPC layer.

Furthermore, you haven’t unmounted the NFS partition, so it is a port that can and SHOULD, according to the NFSv3 rules be reused by the same NFS client when it reconnects. The server attaches a duplicate reply cache to the source IP address and port number and expects RPC calls that were lost by the server to be replayed through the same IP address and port number.


> 
> I did a bisect and found the culprit and worked with the NFS folks who
> came up with a fix that made rkhunter happy again.
> 
> Link: http://lkml.kernel.org/r/20150611234929.7b48d314@gandalf.local.home
> 
> The previous fix was 4876cc779ff5 ("SUNRPC: Ensure we release the TCP
> socket once it has been closed")
> 
> Recently, after traveling with my wife, she decided to upload pictures
> again and mounted the directory, and lo and behold the hidden port
> re-appeared. I noticed that the mounting of the NFS directory caused
> this to happen again. I did lots of debugging to see why and asked for
> help from the NFS folks again. But this time I didn't receive much help.
> 
> Link: http://lkml.kernel.org/r/20160630085950.61e5c7e0@gandalf.local.home
> 
> Frustrated, I spent all day bisecting this, and found that this bug was
> created in the next release. And I even found the commit that causes
> this bug: 4b0ab51db32e ("SUNRPC: xs_sock_mark_closed() does not need to
> trigger socket autoclose"). This commit states:
> 
>   "Under all conditions, it should be quite sufficient just to mark
>    the socket as disconnected. It will then be closed by the
>    transport shutdown or reconnect code."
> 
> Well, this isn't quite correct. And doing a little git blaming, the
> line that it removed was added by the first commit above that
> previously fixed my issue.
> 
> Reverting this commit makes rkhunter and myself quite happy again.
> 
> I consider this userland breakage, as rkhunter is a userland tool and
> this commit causes it to report a problem that does not exist.
> 
> Fixes: 4b0ab51db32e ("SUNRPC: xs_sock_mark_closed() does not need to trigger socket autoclose")
> Cc: stable@vger.kernel.org # v4.3+
> Signed-off-by: Steven Rostedt <rostedt@goodmis.org>
> ---
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 7e2b2fa189c3..5579d13e253f 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -768,6 +768,7 @@ static void xs_sock_mark_closed(struct rpc_xprt *xprt)
> 	xs_sock_reset_connection_flags(xprt);
> 	/* Mark transport as closed and wake up all pending tasks */
> 	xprt_disconnect_done(xprt);
> +	xprt_force_disconnect(xprt);
> }

NACK. This ocde was removed on purpose because it is dangerous to have the TCP state change callbacks queue up a new close(). The connect code sometimes has to close sockets that are misbehaving, and so we’ve seen races whereby the old socket closes and triggers an autoclose for the new socket while it is connecting.

Trond

