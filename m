Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58710 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757066Ab3BVPiD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Feb 2013 10:38:03 -0500
Date: Fri, 22 Feb 2013 10:38:01 -0500
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] NFSDv4.2: Added NFS v4.2 support to the NFS server
Message-ID: <20130222153801.GD20588@fieldses.org>
References: <1361484911-17537-1-git-send-email-steved@redhat.com>
 <1361484911-17537-3-git-send-email-steved@redhat.com>
 <20130222152548.GB10157@pad.fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9235DBFBA@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9235DBFBA@SACEXCMBX04-PRD.hq.netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 22, 2013 at 03:30:08PM +0000, Myklebust, Trond wrote:
> On Fri, 2013-02-22 at 10:26 -0500, J. Bruce Fields wrote:
> > On Thu, Feb 21, 2013 at 05:15:11PM -0500, Steve Dickson wrote:
> > > This enable NFSv4.2 support for the server. To enable this
> > > code do the following:
> > >   echo "+4.2" >/proc/fs/nfsd/versions
> > > 
> > > after the nfsd kernel module is loaded.
> > > 
> > > Signed-off-by: Steve Dickson <steved@redhat.com>
> > > ---
> > >  fs/nfsd/nfs4xdr.c | 1 +
> > >  fs/nfsd/nfsd.h    | 2 +-
> > >  2 files changed, 2 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> > > index d2ae8db..86be853 100644
> > > --- a/fs/nfsd/nfs4xdr.c
> > > +++ b/fs/nfsd/nfs4xdr.c
> > > @@ -1621,6 +1621,7 @@ struct nfsd4_minorversion_ops {
> > >  static struct nfsd4_minorversion_ops nfsd4_minorversion[] = {
> > >  	[0] = { nfsd4_dec_ops, ARRAY_SIZE(nfsd4_dec_ops) },
> > >  	[1] = { nfsd41_dec_ops, ARRAY_SIZE(nfsd41_dec_ops) },
> > > +	[2] = { nfsd41_dec_ops, ARRAY_SIZE(nfsd41_dec_ops) },
> > >  };
> > >  
> > >  static __be32
> > > diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
> > > index 26a457b..0e3ccd1 100644
> > > --- a/fs/nfsd/nfsd.h
> > > +++ b/fs/nfsd/nfsd.h
> > > @@ -24,7 +24,7 @@
> > >  /*
> > >   * nfsd version
> > >   */
> > > -#define NFSD_SUPPORTED_MINOR_VERSION	1
> > > +#define NFSD_SUPPORTED_MINOR_VERSION	2
> > >  /*
> > >   * Maximum blocksizes supported by daemon under various circumstances.
> > >   */
> > 
> > Looks OK to me, except this should be behind a config for now.
> > 
> > On a grep for "minorversion" I notice two oversights, below: one just a
> > comment, one might result in getting the wrong minorversion on
> > callbacks.
> > 
> > --b.
> > 
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 503e15e..b86cf07 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -1665,7 +1665,7 @@ out_new:
> >  		status = nfserr_jukebox;
> >  		goto out;
> >  	}
> > -	new->cl_minorversion = 1;
> > +	new->cl_minorversion = cstate->minorversion;
> >  
> >  	gen_clid(new);
> >  	add_to_unconfirmed(new, strhashval);
> > diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> > index e036894..28d41ef 100644
> > --- a/fs/nfsd/state.h
> > +++ b/fs/nfsd/state.h
> > @@ -108,7 +108,7 @@ struct nfs4_cb_conn {
> >  	u32                     cb_prog; /* used only in 4.0 case;
> >  					    per-session otherwise */
> >  	u32                     cb_ident;	/* minorversion 0 only */
> > -	struct svc_xprt		*cb_xprt;	/* minorversion 1 only */
> > +	struct svc_xprt		*cb_xprt;	/* minorversion >=1 only */
> 
> Tagging things as being particlar to a give minorversion means that
> we'll never stop having to change the comments.

I don't see how "minorversion >=1 only" is likely to become untrue.  Are
we really expecting to remove the session back channel in a future minor
version?

> Why not just label it as being the session back channel?

I don't really care.  Happy to take alternate text if you want to
suggest something.

--b.
