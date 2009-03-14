Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58901 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752237AbZCNET6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 14 Mar 2009 00:19:58 -0400
Subject: Re: [PATCH 29/30] SUNRPC: Add a sysctl to control the duration of
 the socket linger timeout
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20090314031937.GA7166@fieldses.org>
References: <20090311184105.5578.22131.stgit@heimdal.trondhjem.org>
	 <20090311184110.5578.89380.stgit@heimdal.trondhjem.org>
	 <20090314031937.GA7166@fieldses.org>
Content-Type: text/plain
Date: Sat, 14 Mar 2009 00:18:56 -0400
Message-Id: <1237004336.7265.103.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2009-03-13 at 23:19 -0400, J. Bruce Fields wrote:
> Out of curiosity: how would a user decide what to set this to?

Most people would want to set it to a large value. The only ones who
would really care would be those who have broken servers, and they would
probably want to tune it so as to provide a decent interactive response
when pressing ^C....

Trond


> --b.
> 
> On Wed, Mar 11, 2009 at 02:41:10PM -0400, Trond Myklebust wrote:
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > ---
> > 
> >  net/sunrpc/xprtsock.c |   13 +++++++++++--
> >  1 files changed, 11 insertions(+), 2 deletions(-)
> > 
> > 
> > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > index b51f58b..42222b4 100644
> > --- a/net/sunrpc/xprtsock.c
> > +++ b/net/sunrpc/xprtsock.c
> > @@ -50,6 +50,7 @@ unsigned int xprt_min_resvport = RPC_DEF_MIN_RESVPORT;
> >  unsigned int xprt_max_resvport = RPC_DEF_MAX_RESVPORT;
> >  
> >  #define XS_TCP_LINGER_TO	(15U * HZ)
> > +static unsigned int xs_tcp_fin_timeout __read_mostly = XS_TCP_LINGER_TO;
> >  
> >  /*
> >   * We can register our own files under /proc/sys/sunrpc by
> > @@ -119,6 +120,14 @@ static ctl_table xs_tunables_table[] = {
> >  		.extra2		= &xprt_max_resvport_limit
> >  	},
> >  	{
> > +		.procname	= "tcp_fin_timeout",
> > +		.data		= &xs_tcp_fin_timeout,
> > +		.maxlen		= sizeof(xs_tcp_fin_timeout),
> > +		.mode		= 0644,
> > +		.proc_handler	= &proc_dointvec_jiffies,
> > +		.strategy	= sysctl_jiffies
> > +	},
> > +	{
> >  		.ctl_name = 0,
> >  	},
> >  };
> > @@ -1222,7 +1231,7 @@ static void xs_tcp_state_change(struct sock *sk)
> >  		clear_bit(XPRT_CONNECTED, &xprt->state);
> >  		clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
> >  		smp_mb__after_clear_bit();
> > -		xs_tcp_schedule_linger_timeout(xprt, XS_TCP_LINGER_TO);
> > +		xs_tcp_schedule_linger_timeout(xprt, xs_tcp_fin_timeout);
> >  		break;
> >  	case TCP_CLOSE_WAIT:
> >  		/* The server initiated a shutdown of the socket */
> > @@ -1239,7 +1248,7 @@ static void xs_tcp_state_change(struct sock *sk)
> >  		break;
> >  	case TCP_LAST_ACK:
> >  		set_bit(XPRT_CLOSING, &xprt->state);
> > -		xs_tcp_schedule_linger_timeout(xprt, XS_TCP_LINGER_TO);
> > +		xs_tcp_schedule_linger_timeout(xprt, xs_tcp_fin_timeout);
> >  		smp_mb__before_clear_bit();
> >  		clear_bit(XPRT_CONNECTED, &xprt->state);
> >  		smp_mb__after_clear_bit();
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
