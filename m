From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH v2 05/12] nfsd41: Backchannel: callback infrastructure
Date: Tue, 15 Sep 2009 11:10:48 -0400
Message-ID: <20090915151048.GA19339@fieldses.org>
References: <20090914163535.GE30806@fieldses.org> <20090914164951.GA32757@fieldses.org> <4AAE7C19.7070600@panasas.com> <20090914200423.GE1658@fieldses.org> <1252959452.6866.92.camel@heimdal.trondhjem.org> <20090914203910.GF1658@fieldses.org> <1252961253.6866.98.camel@heimdal.trondhjem.org> <20090914205648.GG1658@fieldses.org> <1252962546.6866.102.camel@heimdal.trondhjem.org> <1252962982.6866.104.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benny Halevy <bhalevy@panasas.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48856 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754680AbZIOPKt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Sep 2009 11:10:49 -0400
In-Reply-To: <1252962982.6866.104.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 14, 2009 at 05:16:22PM -0400, Trond Myklebust wrote:
> On Mon, 2009-09-14 at 17:09 -0400, Trond Myklebust wrote:
> 
> > I suppose we could. Alternatively, why not just call it once and for all
> > when you start the NFSv4 server? The one cred will work on all
> > rpc_clients.
> 
> (This is correct...)
> 
> > You just have to remember to bump the reference count
> > before using it in an RPC call...
> 
> Oops! Sorry, this is incorrect. The RPC engine will take care of bumping
> the ref count for you if necessary...

OK, on another look: I create a generic cred with
rpc_lookup_machine_cred().  The gss cred then gets created by something
like:

	rpc_call_async
	  rpc_run_task
	    rpc_new_task
	      rpc_init_task
	        rpcauth_bindcred
		  cred->cr_ops->crbind == generic_bind_cred
		    gss_auth->au_ops->lookup_cred(auth, acred, 0)
		      rpcauth_lookup_credcache(gss_auth, acred, 0)

But rpcauth_lookup_credcache ends up calling cr_init (gss_cred_init) and
waiting synchronously for the gss upcall.  I want to avoid that.  Should
I be setting up the cred differently, or could the rpc task
initialization process be tweaked somehow?  (Or am I just
misunderstanding the code?)

--b.
