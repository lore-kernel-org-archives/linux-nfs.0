Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:38351 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932500AbbFCTDT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Jun 2015 15:03:19 -0400
Received: by igblz2 with SMTP id lz2so22213203igb.1
        for <linux-nfs@vger.kernel.org>; Wed, 03 Jun 2015 12:03:18 -0700 (PDT)
Date: Wed, 3 Jun 2015 15:03:11 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux-MM <linux-mm@kvack.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Mel Gorman <mgorman@suse.de>, Jerome Marchand <jmarchan@redhat.com>
Subject: Re: [PATCH v2 5/5] sunrpc: turn swapper_enable/disable functions
 into rpc_xprt_ops
Message-ID: <20150603150311.29688337@tlielax.poochiereds.net>
In-Reply-To: <C4DF995C-4064-4DFD-99DD-8F397D394334@oracle.com>
References: <1433342632-16173-1-git-send-email-jeff.layton@primarydata.com>
	<1433342632-16173-6-git-send-email-jeff.layton@primarydata.com>
	<CAHQdGtQGeVRTfv-hvZj_bHqgb5Cs84TY-ScFqzJ3qQOZy2qLcQ@mail.gmail.com>
	<20150603110158.0d21844d@synchrony.poochiereds.net>
	<C4DF995C-4064-4DFD-99DD-8F397D394334@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 3 Jun 2015 13:07:34 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Jun 3, 2015, at 11:01 AM, Jeff Layton <jlayton@poochiereds.net> wrote:
> 
> > On Wed, 3 Jun 2015 10:48:10 -0400
> > Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> > 
> >> On Wed, Jun 3, 2015 at 10:43 AM, Jeff Layton <jlayton@poochiereds.net> wrote:
> >>> RDMA xprts don't have a sock_xprt, but an rdma_xprt, so the
> >>> xs_swapper_enable/disable functions will likely oops when fed an RDMA
> >>> xprt. Turn these functions into rpc_xprt_ops so that that doesn't
> >>> occur. For now the RDMA versions are no-ops.
> >>> 
> >>> Cc: Chuck Lever <chuck.lever@oracle.com>
> >>> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> >>> ---
> >>> include/linux/sunrpc/xprt.h     | 16 ++++++++++++++--
> >>> net/sunrpc/clnt.c               |  4 ++--
> >>> net/sunrpc/xprtrdma/transport.c | 15 ++++++++++++++-
> >>> net/sunrpc/xprtsock.c           | 31 +++++++++++++++++++++++++------
> >>> 4 files changed, 55 insertions(+), 11 deletions(-)
> >>> 
> >>> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> >>> index 26b1624128ec..7eb58610eb94 100644
> >>> --- a/include/linux/sunrpc/xprt.h
> >>> +++ b/include/linux/sunrpc/xprt.h
> >>> @@ -133,6 +133,8 @@ struct rpc_xprt_ops {
> >>>        void            (*close)(struct rpc_xprt *xprt);
> >>>        void            (*destroy)(struct rpc_xprt *xprt);
> >>>        void            (*print_stats)(struct rpc_xprt *xprt, struct seq_file *seq);
> >>> +       int             (*enable_swap)(struct rpc_xprt *xprt);
> >>> +       void            (*disable_swap)(struct rpc_xprt *xprt);
> >>> };
> >>> 
> >>> /*
> >>> @@ -327,6 +329,18 @@ static inline __be32 *xprt_skip_transport_header(struct rpc_xprt *xprt, __be32 *
> >>>        return p + xprt->tsh_size;
> >>> }
> >>> 
> >>> +static inline int
> >>> +xprt_enable_swap(struct rpc_xprt *xprt)
> >>> +{
> >>> +       return xprt->ops->enable_swap(xprt);
> >>> +}
> >>> +
> >>> +static inline void
> >>> +xprt_disable_swap(struct rpc_xprt *xprt)
> >>> +{
> >>> +       xprt->ops->disable_swap(xprt);
> >>> +}
> >>> +
> >>> /*
> >>>  * Transport switch helper functions
> >>>  */
> >>> @@ -345,8 +359,6 @@ void                        xprt_release_rqst_cong(struct rpc_task *task);
> >>> void                   xprt_disconnect_done(struct rpc_xprt *xprt);
> >>> void                   xprt_force_disconnect(struct rpc_xprt *xprt);
> >>> void                   xprt_conditional_disconnect(struct rpc_xprt *xprt, unsigned int cookie);
> >>> -int                    xs_swapper_enable(struct rpc_xprt *xprt);
> >>> -void                   xs_swapper_disable(struct rpc_xprt *xprt);
> >>> 
> >>> bool                   xprt_lock_connect(struct rpc_xprt *, struct rpc_task *, void *);
> >>> void                   xprt_unlock_connect(struct rpc_xprt *, void *);
> >>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> >>> index 804a75e71e84..60d1835edb26 100644
> >>> --- a/net/sunrpc/clnt.c
> >>> +++ b/net/sunrpc/clnt.c
> >>> @@ -2492,7 +2492,7 @@ retry:
> >>>                        goto retry;
> >>>                }
> >>> 
> >>> -               ret = xs_swapper_enable(xprt);
> >>> +               ret = xprt_enable_swap(xprt);
> >>>                xprt_put(xprt);
> >>>        }
> >>>        return ret;
> >>> @@ -2519,7 +2519,7 @@ retry:
> >>>                        goto retry;
> >>>                }
> >>> 
> >>> -               xs_swapper_disable(xprt);
> >>> +               xprt_disable_swap(xprt);
> >>>                xprt_put(xprt);
> >>>        }
> >>> }
> >>> diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
> >>> index 54f23b1be986..e7a157754095 100644
> >>> --- a/net/sunrpc/xprtrdma/transport.c
> >>> +++ b/net/sunrpc/xprtrdma/transport.c
> >>> @@ -682,6 +682,17 @@ static void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
> >>>           r_xprt->rx_stats.bad_reply_count);
> >>> }
> >>> 
> >>> +static int
> >>> +xprt_rdma_enable_swap(struct rpc_xprt *xprt)
> >>> +{
> >>> +       return 0;
> >> 
> >> Shouldn't the function be returning an error here? What does swapon
> >> expect if the device you are trying to enable doesn't support swap?
> >> 
> > 
> > 
> > Chuck suggested making these no-ops for RDMA for now.
> 
> I did indeed. What I meant was that you needn’t worry too much right now
> about how swap-on-NFS/RDMA is supposed to work, just make it not crash, and
> someone (maybe me) will look at it later to ensure it is working correctly
> and then we can claim it is supported. Sorry I was not clear.
> 
> > I'm fine with
> > returning an error, but is it really an error? Maybe RDMA doesn't need
> > any special setup for swapping?
> 
> This sounds a little snarky, but we don’t know for sure that nothing is
> needed until it is tested and reviewed. I think it’s reasonable to assume
> it doesn’t work 100% until we have positive confirmation that it does work.
> 
> Maybe add a comment to that effect in these new xprt methods? And I would
> have it return something like ENOSYS. 
> 
> Likewise, consider the same return code here:
> 
> +#if IS_ENABLED(CONFIG_SUNRPC_SWAP)
> +int rpc_clnt_swap_activate(struct rpc_clnt *clnt);
> +void rpc_clnt_swap_deactivate(struct rpc_clnt *clnt);
> +#else
> +static inline int
> +rpc_clnt_swap_activate(struct rpc_clnt *clnt)
> +{
> +	return 0;
>               ^^^^
> +}
> 
> I’m not familiar enough with the swapon administrative interface to know if
> “swapping on this device is not supported” is a reasonable and expected
> failure mode for swapon. So maybe I’m just full of turtles.
> 

No worries. I'm fine with returning an error if this stuff is disabled.
The manpage seems to indicate that EINVAL is the right error code to
use, but I'll see if I can verify that.

I'll need to look over the code a little more...
-- 
Jeff Layton <jlayton@poochiereds.net>
