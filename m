From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: possible module refcount leak with auth_gss
Date: Wed, 17 Dec 2008 14:20:47 -0500
Message-ID: <20081217192047.GL4614@fieldses.org>
References: <20081208102855.30081708@tleilax.poochiereds.net>
	<20081208173706.GE16628@fieldses.org>
	<20081209153849.6605559a@tleilax.poochiereds.net>
	<4d569c330812091521s6b9405faq910cb94f067f3b@mail.gmail.com>
	<20081210112506.2b2d2c3a@tleilax.poochiereds.net>
	<20081210163136.GB28263@fieldses.org>
	<20081216164532.22cab9d6@tleilax.poochiereds.net>
	<20081216214051.51019f51@tupile.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Kevin Coffman <kwc@umich.edu>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20081216214051.51019f51@tupile.poochiereds.net>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 16, 2008 at 09:40:51PM -0500, Jeff Layton wrote:
> On Tue, 16 Dec 2008 16:45:32 -0500
> Jeff Layton <jlayton@redhat.com> wrote:
> > I took some time today to dig into this. Here's some debug output from
> > the RPC_GSS_PROC_DESTROY request on the client:
> > 
> > RPC:     0 holding RPCSEC_GSS cred ffff880011579bb8
> > RPC:       new task initialized, procpid 2846
> > RPC:       allocated task ffff88001e110000
> > RPC:    11 __rpc_execute flags=0x281
> > RPC:    11 call_start nfs4 proc NULL (async)
> > RPC:    11 call_reserve (status 0)
> > RPC:    11 call_refresh (status 0)
> > RPC:    11 refreshing RPCSEC_GSS cred ffff880011579bb8
> > RPC:    11 call_refreshresult (status -13)
> > RPC:    11 return 0, status -13
> > RPC:    11 release task
> > RPC:    11 releasing RPCSEC_GSS cred ffff880011579bb8
> > 
> > ...looks like we're trying to refresh the credentials before sending the
> > call but that's failing. That's as far as I've gotten with it so far
> > though.
> > 
> 
> I see why this is occuring, but I'm afraid I don't understand the code
> well enough to understand why it's written this way...
> 
> gss_destroying_context() does this:
> 
>         if (gss_cred->gc_ctx == NULL ||
>             test_and_clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags) == 0)
>                 return 0;
> 
>         gss_cred->gc_ctx->gc_proc = RPC_GSS_PROC_DESTROY;
>         cred->cr_ops = &gss_nullops;
> 
> ...and then it does the rpc NULL call. The problem is that we're clearing
> RPCAUTH_CRED_UPTODATE and then setting cr_ops to gss_nullops. The rpc
> call is done, call_reserve checks the RPCAUTH_CRED_UPTODATE bit, and calls
> call_refresh because it's not set.
> 
> call_refresh calls rpcauth_refreshcred which calls the crrefresh op. That's
> now gss_refresh_null, and that just returns -EACCES. The RPC call then
> fails w/o ever being sent.
> 
> It seems like we either need to not clear the UPTODATE bit for the cred, or
> not set the cr_ops to the nullops before doing the call. Any thoughts?

We certainly shouldn't be really refreshing the cred--that'd end up
creating a new gss context when what we're trying to do is destroy one.
So leaving cr_ops set to gss_credops() doesn't sound right.

Maybe that gss_refresh_null() should just return 0 and pretend the
cred's fine, instead of returning -EACCES?

--b.
