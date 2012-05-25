Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41639 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752432Ab2EYOFC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 May 2012 10:05:02 -0400
Date: Fri, 25 May 2012 10:05:01 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Simo Sorce <simo@redhat.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] SUNRPC: Use gssproxy upcall for nfsd's RPCGSS
 authentication.
Message-ID: <20120525140501.GB28842@fieldses.org>
References: <1337087550-9821-1-git-send-email-simo@redhat.com>
 <1337087550-9821-5-git-send-email-simo@redhat.com>
 <20120522224818.GA6435@fieldses.org>
 <1337833911.16840.223.camel@willson.li.ssimo.org>
 <20120524110844.GB19875@fieldses.org>
 <1337865566.16840.234.camel@willson.li.ssimo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1337865566.16840.234.camel@willson.li.ssimo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 24, 2012 at 09:19:26AM -0400, Simo Sorce wrote:
> On Thu, 2012-05-24 at 07:08 -0400, J. Bruce Fields wrote:
> > On Thu, May 24, 2012 at 12:31:51AM -0400, Simo Sorce wrote:
> > > On Tue, 2012-05-22 at 18:48 -0400, J. Bruce Fields wrote:
> > > > On Tue, May 15, 2012 at 09:12:30AM -0400, Simo Sorce wrote:
> > > 
> > > > > +static inline int
> > > > > +gss_read_proxy_verf(struct svc_rqst *rqstp,
> > > > > +		    struct rpc_gss_wire_cred *gc, __be32 *authp,
> > > > > +		    struct xdr_netobj *in_handle,
> > > > > +		    struct gssp_in_token *in_token)
> > > > > +{
> > > [..]
> > > > > +	/* FIXME: change argv to point to the end of in_token ? */
> > > > 
> > > > There's nothing left to read, so it looks like there's no problem here;
> > > > drop the comment?
> > > 
> > > Dropping, was a reminder while I was working and it is not necessary
> > > anymore indeed.
> > >   
> > > > > +static int gss_proxy_save_rsc(struct cache_detail *cd,
> > > > > +				struct gssp_upcall_data *ud,
> > > > > +				struct xdr_netobj *handle)
> > > > > +{
> > > > > +	struct rsc rsci, *rscp = NULL;
> > > > > +	static atomic64_t ctxhctr;
> > > > > +	long long ctxh;
> > > > > +	struct gss_api_mech *gm = NULL;
> > > > > +	time_t expiry;
> > > > > +	char *c;
> > > > > +	int status = -EINVAL;
> > > > > +
> > > > > +	memset(&rsci, 0, sizeof(rsci));
> > > > > +	/* context handle */
> > > > > +	status = -ENOMEM;
> > > > > +	/* the handle needs to be just a unique id,
> > > > > +	 * use a static counter */
> > > > > +	ctxh = atomic64_inc_return(&ctxhctr);
> > > > > +	handle->data = kmemdup(&ctxh, sizeof(ctxh), GFP_KERNEL);
> > > > 
> > > > Looks like you use this only to dup again immediately below in
> > > > dup_to_netobj, so you should just be able to make that:
> > > 
> > > No this is duplicated on handle->data, where handle is a pointer passed
> > > to us by the caller.
> > 
> > Obviously I can't read.
> > 
> > > 
> > > It is later passed to gss_write_init_verf() and finally freed when
> > > svcauth_gss_proxy_init exits, so no leak.
> > > 
> > > > 	handle->data = &ctxh;
> > > > 
> > > > That's simpler and looks like it avoids a leak on exit.
> > > > 
> > > > > +	if (handle->data == NULL)
> > > > > +		goto out;
> > > > > +	handle->len = sizeof(ctxh);
> > > > > +	if (dup_to_netobj(&rsci.handle, handle->data, handle->len))
> > 
> > But why do we need two copies of the thing?
> 
> Yeah no great reason to, seemed the most expedient way at the time I
> modified the function to get a unique handle, given the existing
> prototype I had.
> 
> > Would it be simpler to pass the new rsc back to the caller?
> 
> I guess we could do that, I didn't because I am not sure if there is any
> chance the rsc cache can be removed by another thread while we hold a
> pointer to this data.
> In the gss_write_init_verf() funciotn we use that handle to find again
> the same rsc cache we just created, but I can't change that as it is the
> same code used in the legacy upcall which needs to search it in there.
> So the current approach seemed the least invasive and simpler.
> 
> However what I can do, perhaps is to pass in a static netobj allocated
> on the callers stack, so we do not need the kmalloc, after all it is a
> very small buffer so it wouldn't cause issues to put it on the stack,
> what do you think ?

Whatever results in the easier-to-understand code at the end.

> > > > > +		goto out;
> > > > > +
> > > > > +	rscp = rsc_lookup(cd, &rsci);
> > > > > +	if (!rscp)
> > > > > +		goto out;
> > > > > +
> > > > > +	/* creds */
> > > > > +	if (!ud->creds) {
> > > > > +		dprintk("RPC:       No creds found, marking Negative!\n");
> > > > > +		set_bit(CACHE_NEGATIVE, &rsci.h.flags);
> > > > 
> > > > When does this happen, out of curiosity?
> > > 
> > > Actually it shouldn't happen, but I maintained the same code structure
> > > that was previously in place.
> > > I think that with the latest changes now I always return (uid = -1, gid
> > > = -1, no additional groups if a mapping can't be found).
> > > However on the off chance that user space does not return a credential
> > > struct we catch it here.
> > 
> > So the result will be to return success to the client on the
> > init_sec_context call but then to fail their future attempts to use that
> > handle?
> 
> > If so, seems like it would be better to return an error and not bother
> > adding a negative entry to the cache.
> 
> Well if we do not add the negative cache we end up looping to user space
> each time the client attempts to call in. If the result was just a fluke
> in user space, then it will not be a problem, but if user space is
> somehow misbehaving I would rather have the kernel 'blacklist' this
> client for a while, no ?

Since this would be a bug in our code (kernel or userspace), let's do
whatever makes it most obvious it's a bug.  At a minimum, a /* userspace
is buggy */ comment there.

--b.
