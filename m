Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42561 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933481AbaAFWxr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Jan 2014 17:53:47 -0500
Date: Mon, 6 Jan 2014 17:53:46 -0500
From: Dr Fields James Bruce <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: fix a memory leak for tcp NFSv4.1 backchannel
Message-ID: <20140106225346.GB3342@fieldses.org>
References: <52CA7862.1020203@gmail.com>
 <20140106184926.GC31764@fieldses.org>
 <24D159B0-C13D-43A6-B307-2B967E154353@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <24D159B0-C13D-43A6-B307-2B967E154353@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 06, 2014 at 05:40:03PM -0500, Trond Myklebust wrote:
> 
> On Jan 6, 2014, at 13:49, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> > On Mon, Jan 06, 2014 at 05:33:22PM +0800, Kinglong Mee wrote:
> >> xs_setup_bc_tcp may return an existing xprt with non-NULL servername.
> >> xprt_create_transport should not kstrdup servername for it.
> >> Otherwise, those memory for servername will be leaked.
> > 
> > OK.  Applying to my tree if Trond has no objection.
> 
> Actually. Why do we go through all this code at all if xs_setup_bc_tcp() returns args->bc_xprt->xpt_bc_xprt? I’m assuming that is the only case where xprt->servername != NULL, right?
> 
> For instance, won’t calling INIT_WORK() be a source of problems?

Huh.  Looking at the history....  There used to be a

	if (test_and_set_bit(XPRT_INITIALIZED, &xprt->state))
		/* ->setup returned a pre-initialized xprt: */
		return xprt;

here, but it got removed by 21de0a955f3af29fa1100d96f66e6adade89e77a
"SUNRPC: Clean up the slot table allocation", which looks otherwise
unrelated.  Was that just some kind of rebasing mistake, or was there a
reason for that?

--b.


> 
> > 
> > --b.
> > 
> >> 
> >> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> >> ---
> >> net/sunrpc/xprt.c | 6 +++++-
> >> 1 file changed, 5 insertions(+), 1 deletion(-)
> >> 
> >> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> >> index ddd198e..6fa966f 100644
> >> --- a/net/sunrpc/xprt.c
> >> +++ b/net/sunrpc/xprt.c
> >> @@ -1339,7 +1339,11 @@ found:
> >> 		xprt_destroy(xprt);
> >> 		return ERR_PTR(-EINVAL);
> >> 	}
> >> -	xprt->servername = kstrdup(args->servername, GFP_KERNEL);
> >> +
> >> +	/* servername may not be NULL for tcp NFSv4.1 backchannel */
> >> +	if (xprt->servername == NULL)
> >> +		xprt->servername = kstrdup(args->servername, GFP_KERNEL);
> >> +
> >> 	if (xprt->servername == NULL) {
> >> 		xprt_destroy(xprt);
> >> 		return ERR_PTR(-ENOMEM);
> >> -- 
> >> 1.8.4.2
> 
