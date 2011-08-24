Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33348 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753626Ab1HXSh2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Aug 2011 14:37:28 -0400
Date: Wed, 24 Aug 2011 14:37:27 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd4: fix seqid_mutating_error
Message-ID: <20110824183727.GE31959@fieldses.org>
References: <20110819172416.GA1112@fieldses.org>
 <1313788373.26701.1.camel@lade.trondhjem.org>
 <20110823214141.GC25350@fieldses.org>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AC9E4FB@SACMVEXC2-PRD.hq.netapp.com>
 <20110824012248.GA26561@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110824012248.GA26561@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Aug 23, 2011 at 09:22:48PM -0400, J. Bruce Fields wrote:
> On Tue, Aug 23, 2011 at 03:58:05PM -0700, Myklebust, Trond wrote:
> > > -----Original Message-----
> > > From: J. Bruce Fields [mailto:bfields@fieldses.org]
> > > diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> > > index 76f99e8..b875b03 100644
> > > --- a/include/linux/nfs4.h
> > > +++ b/include/linux/nfs4.h
> > > @@ -373,6 +373,22 @@ enum nfsstat4 {
> > >  	NFS4ERR_DELEG_REVOKED	= 10087,	/* deleg./layout revoked
> > */
> > >  };
> > > 
> > > +static inline bool seqid_mutating_err(u32 err)
> > > +{
> > > +	/* rfc 3530 section 8.1.5: */
> > > +	switch (err) {
> > > +	case NFS4ERR_STALE_CLIENTID:
> > > +	case NFS4ERR_STALE_STATEID:
> > > +	case NFS4ERR_BAD_STATEID:
> > > +	case NFS4ERR_BAD_SEQID:
> > > +	case NFS4ERR_BADXDR:
> > > +	case NFS4ERR_RESOURCE:
> > > +	case NFS4ERR_NOFILEHANDLE:
> > > +		return false;
> > > +	};
> > > +	return true;
> > > +}
> > > +
> > >  /*
> > >   * Note: NF4BAD is not actually part of the protocol; it is just used
> > >   * internally by nfsd.
> > 
> > Should we make it take a 's32' rather than a 'u32' argument? We do
> > usually expect those errors to be signed.
> 
> On the server side it's unsigned--bigendian in fact.  The caller is:
> 
> > > +	if (seqid_mutating_err(ntohl(nfserr)) && stateowner) { 	\
> 
> I put this in nfs4.h which is mostly protocol constants, and I figure
> u32 is the type closest to the relevant xdr, and we should convert as
> necessary in callers.  I dunno.

(Translation: "I dunno" == "I have no strong opinion, but I'm sticking
with this patch unless you want to write another".)

--b.
