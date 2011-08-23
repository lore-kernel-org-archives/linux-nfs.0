Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:65278 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754432Ab1HWW6J convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Aug 2011 18:58:09 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: [PATCH] nfsd4: fix seqid_mutating_error
Date: Tue, 23 Aug 2011 15:58:05 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AC9E4FB@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <20110823214141.GC25350@fieldses.org>
References: <20110819172416.GA1112@fieldses.org> <1313788373.26701.1.camel@lade.trondhjem.org> <20110823214141.GC25350@fieldses.org>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org]
> Sent: Tuesday, August 23, 2011 5:42 PM
> To: Myklebust, Trond
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: [PATCH] nfsd4: fix seqid_mutating_error
> 
> On Fri, Aug 19, 2011 at 05:12:53PM -0400, Trond Myklebust wrote:
> > On Fri, 2011-08-19 at 13:24 -0400, J. Bruce Fields wrote:
> > > +static bool seqid_mutating_err(__be32 err)
> > > +{
> > > +	/* rfc 3530 section 8.1.5: */
> > > +	return	err != nfserr_stale_clientid &&
> > > +		err != nfserr_stale_stateid &&
> > > +		err != nfserr_bad_stateid &&
> > > +		err != nfserr_bad_seqid &&
> > > +		err != nfserr_bad_xdr &&
> > > +		err != nfserr_resource &&
> > > +		err != nfserr_nofilehandle;
> >
> > Any reason not to convert the above into a switch() statement while
> you
> > are at it?
> 
> It would be more straightforward without the negatives.
> 
> Also, we've got two copies of this list.  How about something like
> this?
> 
> --b.
> 
> commit 9ee2cabf7a814d48798380bc2cb8516645d1d0dc
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Tue Aug 23 15:43:04 2011 -0400
> 
>     nfsd4: cleanup and consolidate seqid_mutating_err
> 
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index 1ec1a85..1a652a0 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -13,30 +13,6 @@
> 
>  struct idmap;
> 
> -/*
> - * In a seqid-mutating op, this macro controls which error return
> - * values trigger incrementation of the seqid.
> - *
> - * from rfc 3010:
> - * The client MUST monotonically increment the sequence number for
the
> - * CLOSE, LOCK, LOCKU, OPEN, OPEN_CONFIRM, and OPEN_DOWNGRADE
> - * operations.  This is true even in the event that the previous
> - * operation that used the sequence number received an error.  The
> only
> - * exception to this rule is if the previous operation received one
of
> - * the following errors: NFSERR_STALE_CLIENTID, NFSERR_STALE_STATEID,
> - * NFSERR_BAD_STATEID, NFSERR_BAD_SEQID, NFSERR_BADXDR,
> - * NFSERR_RESOURCE, NFSERR_NOFILEHANDLE.
> - *
> - */
> -#define seqid_mutating_err(err)       \
> -(((err) != NFSERR_STALE_CLIENTID) &&  \
> - ((err) != NFSERR_STALE_STATEID)  &&  \
> - ((err) != NFSERR_BAD_STATEID)    &&  \
> - ((err) != NFSERR_BAD_SEQID)      &&  \
> - ((err) != NFSERR_BAD_XDR)        &&  \
> - ((err) != NFSERR_RESOURCE)       &&  \
> - ((err) != NFSERR_NOFILEHANDLE))
> -
>  enum nfs4_client_state {
>  	NFS4CLNT_MANAGER_RUNNING  = 0,
>  	NFS4CLNT_CHECK_LEASE,
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 78c792f..04ad9a2 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1623,18 +1623,6 @@ static void write_cinfo(__be32 **p, struct
> nfsd4_change_info *c)
>  								\
>  	save = resp->p;
> 
> -static bool seqid_mutating_err(__be32 err)
> -{
> -	/* rfc 3530 section 8.1.5: */
> -	return	err != nfserr_stale_clientid &&
> -		err != nfserr_stale_stateid &&
> -		err != nfserr_bad_stateid &&
> -		err != nfserr_bad_seqid &&
> -		err != nfserr_bad_xdr &&
> -		err != nfserr_resource &&
> -		err != nfserr_nofilehandle;
> -}
> -
>  /*
>   * Routine for encoding the result of a "seqid-mutating" NFSv4
> operation.  This
>   * is where sequence id's are incremented, and the replay cache is
> filled.
> @@ -1643,7 +1631,7 @@ static bool seqid_mutating_err(__be32 err)
>   */
> 
>  #define ENCODE_SEQID_OP_TAIL(stateowner) do {
\
> -	if (seqid_mutating_err(nfserr) && stateowner) { 	\
> +	if (seqid_mutating_err(ntohl(nfserr)) && stateowner) { 	\
>  		stateowner->so_seqid++;				\
>  		stateowner->so_replay.rp_status = nfserr;   	\
>  		stateowner->so_replay.rp_buflen = 		\
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index 76f99e8..b875b03 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -373,6 +373,22 @@ enum nfsstat4 {
>  	NFS4ERR_DELEG_REVOKED	= 10087,	/* deleg./layout revoked
*/
>  };
> 
> +static inline bool seqid_mutating_err(u32 err)
> +{
> +	/* rfc 3530 section 8.1.5: */
> +	switch (err) {
> +	case NFS4ERR_STALE_CLIENTID:
> +	case NFS4ERR_STALE_STATEID:
> +	case NFS4ERR_BAD_STATEID:
> +	case NFS4ERR_BAD_SEQID:
> +	case NFS4ERR_BADXDR:
> +	case NFS4ERR_RESOURCE:
> +	case NFS4ERR_NOFILEHANDLE:
> +		return false;
> +	};
> +	return true;
> +}
> +
>  /*
>   * Note: NF4BAD is not actually part of the protocol; it is just used
>   * internally by nfsd.

Should we make it take a 's32' rather than a 'u32' argument? We do
usually expect those errors to be signed.

Cheers
  Trond
