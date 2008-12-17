From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: possible module refcount leak with auth_gss
Date: Wed, 17 Dec 2008 15:10:31 -0500
Message-ID: <1229544631.7257.117.camel@heimdal.trondhjem.org>
References: <20081209153849.6605559a@tleilax.poochiereds.net>
	 <4d569c330812091521s6b9405faq910cb94f067f3b@mail.gmail.com>
	 <20081210112506.2b2d2c3a@tleilax.poochiereds.net>
	 <20081210163136.GB28263@fieldses.org>
	 <20081216164532.22cab9d6@tleilax.poochiereds.net>
	 <20081216214051.51019f51@tupile.poochiereds.net>
	 <20081217192047.GL4614@fieldses.org>
	 <20081217143458.080aa9be@tleilax.poochiereds.net>
	 <20081217194127.GN4614@fieldses.org>
	 <1229543651.7257.107.camel@heimdal.trondhjem.org>
	 <20081217200701.GP4614@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jeff Layton <jlayton@redhat.com>, Kevin Coffman <kwc@umich.edu>,
	linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	Trond Myklebust <trond@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:59274 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751275AbYLQUKm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Dec 2008 15:10:42 -0500
In-Reply-To: <20081217200701.GP4614@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-12-17 at 15:07 -0500, J. Bruce Fields wrote:
> On Wed, Dec 17, 2008 at 02:54:11PM -0500, Trond Myklebust wrote:
> > On Wed, 2008-12-17 at 14:41 -0500, J. Bruce Fields wrote:
> > > It looks like the CRED_UPTODATE is just being used as a signal to decide
> > > whether the PROC_DESTROY has already been sent; the test_and_clear_bit
> > > ensures that the null call is made just once.  Maybe a separate flag
> > > would be simpler.
> > 
> > Just make a separate gss_destroy_cred() which doesn't call
> > gss_destroying_context() and stick it into gss_nullops.
> 
> Lost you there.  So you're thinking the current end of
> gss_destroy_cred():
> 
> 	rcu_assign_pointer(gss_cred->gc_ctx, NULL);
> 	call_rcu(&cred->cr_rcu, gss_free_cred_callback);
> 	if (ctx)
> 		gss_put_ctx(ctx);
> 	kref_put(&gss_auth->kref,
> 	gss_free_callback);
> 
> should go into a separate gss_nullops.crdestroy, and the real work of
> gss_destroying_context() (rpc_call_null, etc.) should be done
> unconditionally?

Not unconditionally. If the session has already expired, there is no
point in sending a GSS_DESTROY. In that case, and that case only, you
jump straight to the gss_nullops.crdestroy() code.

> (And presumably the rpc code already ensures that ->crdestroy is called
> exactly once?)

Yes.

Trond

