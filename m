Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:40871 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753947Ab0JVPVM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Oct 2010 11:21:12 -0400
Date: Fri, 22 Oct 2010 10:20:52 -0500
From: bpm@sgi.com
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] xs_bind retry binding forever
Message-ID: <20101022152052.GA11980@sgi.com>
References: <20101021183203.12776.28469.stgit@lady3jane.americas.sgi.com> <20101021183337.12776.18768.stgit@lady3jane.americas.sgi.com> <1287689917.9144.84.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1287689917.9144.84.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hey Trond,

On Thu, Oct 21, 2010 at 03:38:37PM -0400, Trond Myklebust wrote:
> On Thu, 2010-10-21 at 13:33 -0500, Ben Myers wrote:
> > Retry bind for reserved source ports forever.  Add an error message when we
> > have a hard time binding one.
> 
> NACK. This approach leads to the process spinning forever in that loop,
> which is exactly why we introduced the limit in the first place. See all
> the old archived bug report emails about 'rpciod taking 100% cpu'.

Ok, fair enough.  ;)

Do you feel it is reasonable to try and return some kind of easily
understandable error code (or message) to the user?  I can testify to
the fact that something like this isn't trivial to debug unless you know
what to look for ahead of time.  If you're interested in that I can
spend some time on it.

Thanks!
-Ben

> 
> Cheers
>   Trond
> 
> > Signed-off-by: Ben Myers <bpm@sgi.com>
> > ---
> >  net/sunrpc/xprtsock.c |   22 ++++++++++++++++++----
> >  1 files changed, 18 insertions(+), 4 deletions(-)
> > 
> > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > index b6309db..79a001b 100644
> > --- a/net/sunrpc/xprtsock.c
> > +++ b/net/sunrpc/xprtsock.c
> > @@ -1560,9 +1560,16 @@ static int xs_bind4(struct sock_xprt *transport, struct socket *sock)
> >  		}
> >  		last = port;
> >  		port = xs_next_srcport(transport, sock, port);
> > -		if (port > last)
> > +		if (port > last) {
> > +			if (nloop > 2 && net_ratelimit()) {
> > +				printk("RPC: %s %pI4: Cannot bind reserved "
> > +				       "source port.  Consider decreasing "
> > +				       "min_resvport.\n",
> > +				       __func__, &myaddr.sin_addr);
> > +			}
> >  			nloop++;
> > -	} while (err == -EADDRINUSE && nloop != 2);
> > +		}
> > +	} while (err == -EADDRINUSE);
> >  	dprintk("RPC:       %s %pI4:%u: %s (%d)\n",
> >  			__func__, &myaddr.sin_addr,
> >  			port, err ? "failed" : "ok", err);
> > @@ -1593,9 +1600,16 @@ static int xs_bind6(struct sock_xprt *transport, struct socket *sock)
> >  		}
> >  		last = port;
> >  		port = xs_next_srcport(transport, sock, port);
> > -		if (port > last)
> > +		if (port > last) {
> > +			if (nloop > 2 && net_ratelimit()) {
> > +				printk("RPC: %s %pI6: Cannot bind reserved "
> > +				       "source port.  Consider decreasing "
> > +				       "min_resvport.\n",
> > +					__func__, &myaddr.sin6_addr);
> > +			}
> >  			nloop++;
> > -	} while (err == -EADDRINUSE && nloop != 2);
> > +		}
> > +	} while (err == -EADDRINUSE);
> >  	dprintk("RPC:       xs_bind6 %pI6:%u: %s (%d)\n",
> >  		&myaddr.sin6_addr, port, err ? "failed" : "ok", err);
> >  	return err;
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
