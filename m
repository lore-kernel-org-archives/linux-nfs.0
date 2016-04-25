Return-Path: <bfields@fieldses.org>
Date: Mon, 25 Apr 2016 17:22:38 -0400
To: Benjamin Coddington <bcodding@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfsd delays between svc_recv and gss_check_seq_num
Message-ID: <20160425212238.GB21879@fieldses.org>
References: <alpine.OSX.2.19.9992.1604100724080.44797@planck>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.OSX.2.19.9992.1604100724080.44797@planck>
From: bfields@fieldses.org (J. Bruce Fields)
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Apr 10, 2016 at 07:44:45AM -0400, Benjamin Coddington wrote:
> My client hangs on xfstests generic/074 on a krb5 mount, and I've found that
> the linux server is silently discarding one or more RPCs because the GSS
> sequence numbers are outside the sequence window.
> 
> The reason is that sometimes one of the nfsd threads takes a long time
> between receiving the RPC and then checking if the sequence is within the
> window.  That delay allows the other nfsd threads to quickly move the window
> forward out of range.
> 
> If the server discards the RPC then that causes then the client to wait
> forever for a response or until the connection is reset.
> 
> By inserting tracepoints, I think I found two sources of delay:
> 
>  1) gss_svc_searchbyctx() uses dup_to_netobj() which has a kmemdup with
> GFP_KERNEL.  It does this because presumabely it doesn't know how big the
> context handle should be.
> 
>  2) gss_verify_mic() uses make_checksum() which eventually gets to
> crypto_alloc_hash() with GFP_KERNEL.
> 
> For the first delay, can we assume the context handles are all going to be
> the same size?  It looks like the handle is assigned by the server, so it
> seems like we should be able to know beforehand how large they are.
> 
> For the second allocation -- I haven't thrown a lot of thought into what
> could be done to fix it.. seems a bit tricker.  I'll think about both of
> these a bit more, but I thought in the meantime to ask if anyone has
> thoughts about this problem.  Maybe we can to the sequence check before
> verify_mic -- but then a message that fails verification could flip the
> sequence bit..

Yes.

It would be better to allocate the crypto context at the time we create
the gss context, instead of each time we need to use it.

The problem is that we could then use that crypto context concurrently
from multiple tasks.  And it could have some state--it did when we first
wrote this code, at least.  But I'm sure we could work around that
somehow if it were worth it.

Looking at the code now--I don't think the original crypto api had this
separate ahash_request_alloc step.  If all the state's in there, then we
should be able to allocate the crypto_ahash once when we create the
krb5_ctx, and then only need the ahash_request_alloc for each operation.
Does that help?

--b.
