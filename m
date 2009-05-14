From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: 2.6.30-rc deadline scheduler performance regression for iozone
	over NFS
Date: Thu, 14 May 2009 13:55:00 -0400
Message-ID: <20090514175500.GB5675@fieldses.org>
References: <x49hc0f79k9.fsf@segfault.boston.devel.redhat.com> <20090508120119.8c93cfd7.akpm@linux-foundation.org> <20090511081415.GL4694@kernel.dk> <x49skjb21b7.fsf@segfault.boston.devel.redhat.com> <20090511165826.GG4694@kernel.dk> <x494ovp4r51.fsf@segfault.boston.devel.redhat.com> <20090512204433.7eb69075.akpm@linux-foundation.org> <x49y6t1rqw0.fsf@segfault.boston.devel.redhat.com> <x49k54ku7i2.fsf@segfault.boston.devel.redhat.com> <1242258338.5407.244.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Moyer <jmoyer@redhat.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Jens Axboe <jens.axboe@oracle.com>,
	linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
	Olga Kornievskaia <aglo@citi.umich.edu>,
	Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1242258338.5407.244.camel@heimdal.trondhjem.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 13, 2009 at 07:45:38PM -0400, Trond Myklebust wrote:
> On Wed, 2009-05-13 at 15:29 -0400, Jeff Moyer wrote:
> > Hi, netdev folks.  The summary here is:
> > 
> > A patch added in the 2.6.30 development cycle caused a performance
> > regression in my NFS iozone testing.  The patch in question is the
> > following:
> > 
> > commit 47a14ef1af48c696b214ac168f056ddc79793d0e
> > Author: Olga Kornievskaia <aglo@citi.umich.edu>
> > Date:   Tue Oct 21 14:13:47 2008 -0400
> > 
> >     svcrpc: take advantage of tcp autotuning
> >  
> > which is also quoted below.  Using 8 nfsd threads, a single client doing
> > 2GB of streaming read I/O goes from 107590 KB/s under 2.6.29 to 65558
> > KB/s under 2.6.30-rc4.  I also see more run to run variation under
> > 2.6.30-rc4 using the deadline I/O scheduler on the server.  That
> > variation disappears (as does the performance regression) when reverting
> > the above commit.
> 
> It looks to me as if we've got a bug in the svc_tcp_has_wspace() helper
> function. I can see no reason why we should stop processing new incoming
> RPC requests just because the send buffer happens to be 2/3 full. If we

I agree, the calculation doesn't look right.  But where do you get the
2/3 number from?

...
> @@ -964,23 +973,14 @@ static int svc_tcp_has_wspace(struct svc_xprt *xprt)
>  	struct svc_sock *svsk =	container_of(xprt, struct svc_sock, sk_xprt);
>  	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
>  	int required;
> -	int wspace;
> -
> -	/*
> -	 * Set the SOCK_NOSPACE flag before checking the available
> -	 * sock space.
> -	 */
> -	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> -	required = atomic_read(&svsk->sk_xprt.xpt_reserved) + serv->sv_max_mesg;
> -	wspace = sk_stream_wspace(svsk->sk_sk);
> -
> -	if (wspace < sk_stream_min_wspace(svsk->sk_sk))
> -		return 0;
> -	if (required * 2 > wspace)
> -		return 0;
>  
> -	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> +	required = (atomic_read(&xprt->xpt_reserved) + serv->sv_max_mesg) * 2;
> +	if (sk_stream_wspace(svsk->sk_sk) < required)

This calculation looks the same before and after--you've just moved the
"*2" into the calcualtion of "required".  Am I missing something?  Maybe
you meant to write:

	required = atomic_read(&xprt->xpt_reserved) + serv->sv_max_mesg * 2;

without the parentheses?

That looks closer, assuming the calculation is meant to be:

		atomic_read(..) == amount of buffer space we think we
			already need
		serv->sv_max_mesg * 2 == space for worst-case request
			and reply?

--b.

> +		goto out_nospace;
>  	return 1;
> +out_nospace:
> +	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> +	return 0;
>  }
