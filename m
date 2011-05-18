Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45886 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754968Ab1ERW4K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 May 2011 18:56:10 -0400
Date: Wed, 18 May 2011 18:56:09 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: bjschuma@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 1/2] NFSD: added FREE_STATEID operation
Message-ID: <20110518225609.GA26545@fieldses.org>
References: <1305575021-2841-1-git-send-email-bjschuma@netapp.com>
 <1305575021-2841-2-git-send-email-bjschuma@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1305575021-2841-2-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, May 16, 2011 at 03:43:40PM -0400, bjschuma@netapp.com wrote:
> +static __be32
> +nfsd4_free_file_stateid(stateid_t *stateid)
> +{
> +	struct nfs4_stateid *stp = search_for_stateid(stateid);
> +	if (!stp)
> +		return nfserr_bad_stateid;
> +	if (stateid->si_generation != 0) {
> +		if (stateid->si_generation < stp->st_stateid.si_generation)
> +			return nfserr_old_stateid;
> +		if (stateid->si_generation > stp->st_stateid.si_generation)
> +			return nfserr_bad_stateid;
> +	}
> +
> +	if (check_for_locks(stp->st_file, stp->st_stateowner))
> +		return nfserr_locks_held;

I think this catches a lock stateid, but not an open stateid that has
associated lock stateid's that in turn hold locks.

Hm, also:

	"The FREE_STATEID operation is used to free a stateid that no
	longer has any associated locks (including opens, byte-range
	locks, delegations, and layouts)"

So an open stateid also shouldn't be freeable as long as there are opens
associated with it.

Also I guess a client shouldn't be permitted to free a delegation that
it still holds.  That means we'll always just return nfserr_locks for
delegation stateid's.  I assume free_stateid is only useful in this case
for the case where a server forcibly revokes part of the client's state
and leaves some "stub" stateid's around in place of the revoked ones.

--b.
