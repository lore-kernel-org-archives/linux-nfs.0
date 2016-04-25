Return-Path: <bfields@fieldses.org>
Date: Mon, 25 Apr 2016 16:10:02 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfsd delays between svc_recv and gss_check_seq_num
Message-ID: <20160425201002.GA21879@fieldses.org>
References: <alpine.OSX.2.19.9992.1604100724080.44797@planck>
 <20160425183802.GA20742@fieldses.org>
 <alpine.OSX.2.19.9992.1604251514050.84171@planck>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.OSX.2.19.9992.1604251514050.84171@planck>
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 25, 2016 at 03:23:56PM -0400, Benjamin Coddington wrote:
> On Mon, 25 Apr 2016, J. Bruce Fields wrote:
> 
> > On Sun, Apr 10, 2016 at 07:44:45AM -0400, Benjamin Coddington wrote:
> > > My client hangs on xfstests generic/074 on a krb5 mount, and I've found that
> > > the linux server is silently discarding one or more RPCs because the GSS
> > > sequence numbers are outside the sequence window.
> > >
> > > The reason is that sometimes one of the nfsd threads takes a long time
> > > between receiving the RPC and then checking if the sequence is within the
> > > window.  That delay allows the other nfsd threads to quickly move the window
> > > forward out of range.
> > >
> > > If the server discards the RPC then that causes then the client to wait
> > > forever for a response or until the connection is reset.
> > >
> > > By inserting tracepoints, I think I found two sources of delay:
> > >
> > >  1) gss_svc_searchbyctx() uses dup_to_netobj() which has a kmemdup with
> > > GFP_KERNEL.  It does this because presumabely it doesn't know how big the
> > > context handle should be.
> > >
> > >  2) gss_verify_mic() uses make_checksum() which eventually gets to
> > > crypto_alloc_hash() with GFP_KERNEL.
> > >
> > > For the first delay, can we assume the context handles are all going to be
> > > the same size?  It looks like the handle is assigned by the server, so it
> > > seems like we should be able to know beforehand how large they are.
> >
> > It's assigned by the server, but I believe that happens in userland,
> > either in svcgssd or gss-proxy.  On a quick look I can't find a limit
> > other than the rpc-imposed limit of 400 bytes for an rpc credential.  So
> > we'd need a documented agreement with svcgssd and gss-proxy for that.
> > Probably easy for the former, not sure about the latter.
> 
> OK, that gives me something to follow up.

Taking a look at the code....  That thing we're allocating is just a
temporary way to pass in the handle that we're looking for, so why not
just something like this?:

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 1095be9c80ab..22886097d8ee 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -569,10 +569,9 @@ gss_svc_searchbyctx(struct cache_detail *cd, struct xdr_netobj *handle)
 	struct rsc *found;
 
 	memset(&rsci, 0, sizeof(rsci));
-	if (dup_to_netobj(&rsci.handle, handle->data, handle->len))
-		return NULL;
+	rsci.handle.data = handle->data;
+	rsci.handle.len = handle->len;
 	found = rsc_lookup(cd, &rsci);
-	rsc_free(&rsci);
 	if (!found)
 		return NULL;
 	if (cache_check(cd, &found->h, NULL))

--b.
