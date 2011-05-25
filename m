Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58079 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932176Ab1EYPFL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 May 2011 11:05:11 -0400
Date: Wed, 25 May 2011 11:05:10 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] NFSD: added FREE_STATEID operation
Message-ID: <20110525150510.GB11166@fieldses.org>
References: <1305922380-8162-1-git-send-email-bjschuma@netapp.com>
 <1305922380-8162-2-git-send-email-bjschuma@netapp.com>
 <4DD6CC12.1020705@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4DD6CC12.1020705@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, May 20, 2011 at 04:16:18PM -0400, Bryan Schumaker wrote:
> On 05/20/2011 04:12 PM, bjschuma@netapp.com wrote:
> > From: Bryan Schumaker <bjschuma@netapp.com>
> > +static __be32
> > +nfsd4_free_delegation_stateid(stateid_t *stateid)
> > +{
> > +	struct nfs4_delegation *dp = search_for_delegation(stateid);
> > +	if (dp)
> > +		return nfserr_locks_held;
> > +	return nfserr_bad_stateid;
> > +}
> > +
> > +static __be32
> > +nfsd4_free_lock_stateid(stateid_t *stateid, struct nfs4_stateid *stp)
> > +{
> > +	if (check_for_locks(stp->st_file, stp->st_stateowner))
> 
> I'm not sure if stateids are unique to (file, stateowner), but I'm not sure how else to check for locks at the moment.

Actually, looking... there's a one-to-one lockowner<->lockstateid
correspondance.  Which is dumb.

The server's handling of lock state needs more serious help than I
realized!

I think your patch is OK now, though.

--b.
