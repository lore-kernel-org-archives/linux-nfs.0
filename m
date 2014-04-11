Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:38248 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831AbaDKUyk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Apr 2014 16:54:40 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH] nfs-rdma: Fix for FMR leaks
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <002e01cf5444$a58c2c10$f0a48430$@cox.net>
Date: Fri, 11 Apr 2014 16:54:15 -0400
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
Message-Id: <36E0E306-3227-4F42-AD1F-9A8B2AFB574E@oracle.com>
References: <nyc61n00p3VzoHe01yc7ug> <002e01cf5444$a58c2c10$f0a48430$@cox.net>
To: Allen Andrews <allen.andrews@cox.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Allen-

I reviewed and tested your patch. Comments inline below.


On Apr 9, 2014, at 6:40 PM, Allen Andrews <allen.andrews@cox.net> wrote:

> Two memory region leaks iwere found during testing:
> 
> 1. rpcrdma_buffer_create: While allocating RPCRDMA_FRMR's ib_alloc_fast_reg_mr is called and then ib_alloc_fast_reg_page_list is called.  If ib_alloc_fast_reg_page_list returns an error it bails out of the routine dropping the last ib_alloc_fast_reg_mr frmr region creating a memory leak.  Added code to dereg the last frmr if ib_alloc_fast_reg_page_list fails.
> 
> 2. rpcrdma_buffer_destroy: While cleaning up, the routine will only free the MR's on the rb_mws list if there are rb_send_bufs present.  However, in rpcrdma_buffer_create while the rb_mws list is being built if one of the MR allocation requests fail after some MR's have been allocated on the rb_mws list the routine never gets to create any rb_send_bufs but instead jumps to the rpcrdma_buffer_destroy routine which will never free the MR's on rb_mws
> list because the rb_send_bufs were never created.   This leaks all the MR's
> on the rb_mws list that were created prior to one of the MR allocations failing.
> 
> Issue(2) was seen during testing. Our adapter had a finite number of MR's available and we created enough connections to where we saw an MR allocation failure on our Nth NFS connection request. After the kernel cleaned up the resources it had allocated for the Nth connection we noticed that FMR's had been leaked due to the coding error described above.
> 
> Issue(1) was seen during a code review while debugging issue(2).
> 
> Signed-off-by: Allen Andrews <allen.andrews@emulex.com>
> ---
> 
> net/sunrpc/xprtrdma/verbs.c |   79 ++++++++++++++++++++++++-------------------
> 1 files changed, 44 insertions(+), 35 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c index 9372656..54f592d 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -1058,6 +1058,14 @@ rpcrdma_buffer_create(struct rpcrdma_buffer *buf, struct rpcrdma_ep *ep,
> 				dprintk("RPC:       %s: "
> 					"ib_alloc_fast_reg_page_list "
> 					"failed %i\n", __func__, rc);
> +
> +				rc = ib_dereg_mr(r->r.frmr.fr_mr);

This clears “rc,” wiping the error returned by ib_alloc_fast_reg_page_list().

Then rpcrdma_buffer_create() returns zero, even though it failed, and xprtrdma thinks the
transport is set up and ready for use. Panic.

I think you can safely ignore the return code from ib_dereg_mr() here.


> +				if (rc)
> +					dprintk("RPC:       %s:"
> +						" ib_dereg_mr"
> +						" failed %i\n",
> +						__func__, rc);
> +
> 				goto out;
> 			}
> 			list_add(&r->mw_list, &buf->rb_mws); @@ -1194,41 +1202,6 @@ rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)

This line is broken: the “@@“ should start on the next line. Some kind of e-mail snafu?


> 			kfree(buf->rb_recv_bufs[i]);
> 		}
> 		if (buf->rb_send_bufs && buf->rb_send_bufs[i]) {
> -			while (!list_empty(&buf->rb_mws)) {
> -				r = list_entry(buf->rb_mws.next,
> -					struct rpcrdma_mw, mw_list);
> -				list_del(&r->mw_list);
> -				switch (ia->ri_memreg_strategy) {
> -				case RPCRDMA_FRMR:
> -					rc = ib_dereg_mr(r->r.frmr.fr_mr);
> -					if (rc)
> -						dprintk("RPC:       %s:"
> -							" ib_dereg_mr"
> -							" failed %i\n",
> -							__func__, rc);
> -					ib_free_fast_reg_page_list(r->r.frmr.fr_pgl);
> -					break;
> -				case RPCRDMA_MTHCAFMR:
> -					rc = ib_dealloc_fmr(r->r.fmr);
> -					if (rc)
> -						dprintk("RPC:       %s:"
> -							" ib_dealloc_fmr"
> -							" failed %i\n",
> -							__func__, rc);
> -					break;
> -				case RPCRDMA_MEMWINDOWS_ASYNC:
> -				case RPCRDMA_MEMWINDOWS:
> -					rc = ib_dealloc_mw(r->r.mw);
> -					if (rc)
> -						dprintk("RPC:       %s:"
> -							" ib_dealloc_mw"
> -							" failed %i\n",
> -							__func__, rc);
> -					break;
> -				default:
> -					break;
> -				}
> -			}
> 			rpcrdma_deregister_internal(ia,
> 					buf->rb_send_bufs[i]->rl_handle,
> 					&buf->rb_send_bufs[i]->rl_iov);
> @@ -1236,6 +1209,42 @@ rpcrdma_buffer_destroy(struct rpcrdma_buffer *buf)
> 		}
> 	}
> 
> +	while (!list_empty(&buf->rb_mws)) {
> +		r = list_entry(buf->rb_mws.next,
> +			struct rpcrdma_mw, mw_list);
> +		list_del(&r->mw_list);
> +		switch (ia->ri_memreg_strategy) {
> +		case RPCRDMA_FRMR:
> +			rc = ib_dereg_mr(r->r.frmr.fr_mr);
> +			if (rc)
> +				dprintk("RPC:       %s:"
> +					" ib_dereg_mr"
> +					" failed %i\n",
> +					__func__, rc);
> +			ib_free_fast_reg_page_list(r->r.frmr.fr_pgl);
> +			break;
> +		case RPCRDMA_MTHCAFMR:
> +			rc = ib_dealloc_fmr(r->r.fmr);
> +			if (rc)
> +				dprintk("RPC:       %s:"
> +					" ib_dealloc_fmr"
> +					" failed %i\n",
> +					__func__, rc);
> +			break;
> +		case RPCRDMA_MEMWINDOWS_ASYNC:
> +		case RPCRDMA_MEMWINDOWS:
> +			rc = ib_dealloc_mw(r->r.mw);
> +			if (rc)
> +				dprintk("RPC:       %s:"
> +					" ib_dealloc_mw"
> +					" failed %i\n",
> +					__func__, rc);
> +			break;
> +		default:
> +			break;
> +		}
> +	}
> +
> 	kfree(buf->rb_pool);
> }
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



