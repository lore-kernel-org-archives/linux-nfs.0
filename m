Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59245 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933043Ab2EXLIo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 May 2012 07:08:44 -0400
Date: Thu, 24 May 2012 07:08:44 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Simo Sorce <simo@redhat.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] SUNRPC: Use gssproxy upcall for nfsd's RPCGSS
 authentication.
Message-ID: <20120524110844.GB19875@fieldses.org>
References: <1337087550-9821-1-git-send-email-simo@redhat.com>
 <1337087550-9821-5-git-send-email-simo@redhat.com>
 <20120522224818.GA6435@fieldses.org>
 <1337833911.16840.223.camel@willson.li.ssimo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1337833911.16840.223.camel@willson.li.ssimo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 24, 2012 at 12:31:51AM -0400, Simo Sorce wrote:
> On Tue, 2012-05-22 at 18:48 -0400, J. Bruce Fields wrote:
> > On Tue, May 15, 2012 at 09:12:30AM -0400, Simo Sorce wrote:
> 
> > > +static inline int
> > > +gss_read_proxy_verf(struct svc_rqst *rqstp,
> > > +		    struct rpc_gss_wire_cred *gc, __be32 *authp,
> > > +		    struct xdr_netobj *in_handle,
> > > +		    struct gssp_in_token *in_token)
> > > +{
> [..]
> > > +	/* FIXME: change argv to point to the end of in_token ? */
> > 
> > There's nothing left to read, so it looks like there's no problem here;
> > drop the comment?
> 
> Dropping, was a reminder while I was working and it is not necessary
> anymore indeed.
>   
> > > +static int gss_proxy_save_rsc(struct cache_detail *cd,
> > > +				struct gssp_upcall_data *ud,
> > > +				struct xdr_netobj *handle)
> > > +{
> > > +	struct rsc rsci, *rscp = NULL;
> > > +	static atomic64_t ctxhctr;
> > > +	long long ctxh;
> > > +	struct gss_api_mech *gm = NULL;
> > > +	time_t expiry;
> > > +	char *c;
> > > +	int status = -EINVAL;
> > > +
> > > +	memset(&rsci, 0, sizeof(rsci));
> > > +	/* context handle */
> > > +	status = -ENOMEM;
> > > +	/* the handle needs to be just a unique id,
> > > +	 * use a static counter */
> > > +	ctxh = atomic64_inc_return(&ctxhctr);
> > > +	handle->data = kmemdup(&ctxh, sizeof(ctxh), GFP_KERNEL);
> > 
> > Looks like you use this only to dup again immediately below in
> > dup_to_netobj, so you should just be able to make that:
> 
> No this is duplicated on handle->data, where handle is a pointer passed
> to us by the caller.

Obviously I can't read.

> 
> It is later passed to gss_write_init_verf() and finally freed when
> svcauth_gss_proxy_init exits, so no leak.
> 
> > 	handle->data = &ctxh;
> > 
> > That's simpler and looks like it avoids a leak on exit.
> > 
> > > +	if (handle->data == NULL)
> > > +		goto out;
> > > +	handle->len = sizeof(ctxh);
> > > +	if (dup_to_netobj(&rsci.handle, handle->data, handle->len))

But why do we need two copies of the thing?

Would it be simpler to pass the new rsc back to the caller?

> > > +		goto out;
> > > +
> > > +	rscp = rsc_lookup(cd, &rsci);
> > > +	if (!rscp)
> > > +		goto out;
> > > +
> > > +	/* creds */
> > > +	if (!ud->creds) {
> > > +		dprintk("RPC:       No creds found, marking Negative!\n");
> > > +		set_bit(CACHE_NEGATIVE, &rsci.h.flags);
> > 
> > When does this happen, out of curiosity?
> 
> Actually it shouldn't happen, but I maintained the same code structure
> that was previously in place.
> I think that with the latest changes now I always return (uid = -1, gid
> = -1, no additional groups if a mapping can't be found).
> However on the off chance that user space does not return a credential
> struct we catch it here.

So the result will be to return success to the client on the
init_sec_context call but then to fail their future attempts to use that
handle?

If so, seems like it would be better to return an error and not bother
adding a negative entry to the cache.

--b.

> 
> > > +	/* Perform synchronous upcall to gss-proxy */
> > > +	status = gssp_accept_sec_context_upcall(&ud);
> > > +	if (status) {
> > > +		goto out;
> > > +	}
> > 
> > Ditch the {}'s.
> 
> ok
> 
> Will include these changes in the next patchset, as soon as I can test
> that I made no regressions with the latest kmalloc rearrangements.
> 
> Simo.
> 
> -- 
> Simo Sorce * Red Hat, Inc * New York
> 
