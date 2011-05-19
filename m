Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34943 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933429Ab1ESQaw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 May 2011 12:30:52 -0400
Date: Thu, 19 May 2011 12:30:51 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 1/2] NFSD: added FREE_STATEID operation
Message-ID: <20110519163051.GB976@fieldses.org>
References: <1305575021-2841-1-git-send-email-bjschuma@netapp.com>
 <1305575021-2841-2-git-send-email-bjschuma@netapp.com>
 <20110518225609.GA26545@fieldses.org>
 <4DD53864.1010401@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4DD53864.1010401@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, May 19, 2011 at 11:33:56AM -0400, Bryan Schumaker wrote:
> On 05/18/2011 06:56 PM, J. Bruce Fields wrote:
> > On Mon, May 16, 2011 at 03:43:40PM -0400, bjschuma@netapp.com wrote:
> >> +static __be32
> >> +nfsd4_free_file_stateid(stateid_t *stateid)
> >> +{
> >> +	struct nfs4_stateid *stp = search_for_stateid(stateid);
> >> +	if (!stp)
> >> +		return nfserr_bad_stateid;
> >> +	if (stateid->si_generation != 0) {
> >> +		if (stateid->si_generation < stp->st_stateid.si_generation)
> >> +			return nfserr_old_stateid;
> >> +		if (stateid->si_generation > stp->st_stateid.si_generation)
> >> +			return nfserr_bad_stateid;
> >> +	}
> >> +
> >> +	if (check_for_locks(stp->st_file, stp->st_stateowner))
> >> +		return nfserr_locks_held;
> > 
> > I think this catches a lock stateid, but not an open stateid that has
> > associated lock stateid's that in turn hold locks.
> > 
> > Hm, also:
> > 
> > 	"The FREE_STATEID operation is used to free a stateid that no
> > 	longer has any associated locks (including opens, byte-range
> > 	locks, delegations, and layouts)"
> > 
> > So an open stateid also shouldn't be freeable as long as there are opens
> > associated with it.
> 
> So having an open stateid doesn't necessarily mean that the file is open?

Looking back at it.... Sorry, you're right, open stateid's are destroyed
on close, so like delegation stateid's they should just never be
freeable.

> and having a lock stateid doesn't mean that the file is locked?

Here we don't know whether the file's locked or not, so we do have to
check.

> I'll look at making a "check_for_opens()" function to help with this check.

So actually I think it's really simple: always fail opens and
delegations, but check for locks.  (Except I'm not sure if
check_for_locks() does the right things, as it operates on a stateowner
not a stateid--I'm forgetting how those work....  If there's a unique
lock stateid per (stateowner,file) pair then check_for_locks() should do
what you want.)

--b.

> 
> > 
> > Also I guess a client shouldn't be permitted to free a delegation that
> > it still holds.  That means we'll always just return nfserr_locks for
> > delegation stateid's.  I assume free_stateid is only useful in this case
> 
> Sounds simple enough.
> 
> > for the case where a server forcibly revokes part of the client's state
> > and leaves some "stub" stateid's around in place of the revoked ones.
> > 
> > --b.
> 
