Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38062 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752015Ab2BROlF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 18 Feb 2012 09:41:05 -0500
Date: Sat, 18 Feb 2012 09:41:03 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Benny Halevy <bhalevy@tonian.com>
Cc: Benny Halevy <benny@tonian.com>, bfields@redhat.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] nfsd41: implement NFS4_SHARE_WANT_NO_DELEG,
 NFS4_OPEN_DELEGATE_NONE_EXT, why_no_deleg
Message-ID: <20120218144103.GA7997@fieldses.org>
References: <4F3D4F1F.6080502@tonian.com>
 <1329418637-23925-1-git-send-email-bhalevy@tonian.com>
 <20120217221411.GA3627@fieldses.org>
 <4F3F5B30.3000501@tonian.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F3F5B30.3000501@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Feb 18, 2012 at 10:02:56AM +0200, Benny Halevy wrote:
> On 2012-02-18 00:14, J. Bruce Fields wrote:
> > On Thu, Feb 16, 2012 at 08:57:17PM +0200, Benny Halevy wrote:
> >> Respect client request for not getting a delegation in NFSv4.1
> >> Appropriately return delegation "type" NFS4_OPEN_DELEGATE_NONE_EXT
> >> and WND4_NOT_WANTED reason.
> > 
> > These all look fine, just two nits:
> > 
> >> @@ -2903,11 +2903,32 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, int flag)
> >>  	dprintk("NFSD: delegation stateid=" STATEID_FMT "\n",
> >>  		STATEID_VAL(&dp->dl_stid.sc_stateid));
> >>  out:
> >> -	if (open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS
> >> -			&& flag == NFS4_OPEN_DELEGATE_NONE
> >> -			&& open->op_delegate_type != NFS4_OPEN_DELEGATE_NONE)
> >> -		dprintk("NFSD: WARNING: refusing delegation reclaim\n");
> >>  	open->op_delegate_type = flag;
> >> +	if (flag == NFS4_OPEN_DELEGATE_NONE) {
> >> +		if (open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS &&
> >> +		    open->op_delegate_type != NFS4_OPEN_DELEGATE_NONE)
> >> +			dprintk("NFSD: WARNING: refusing delegation reclaim\n");
> >> +
> >> +		if (open->op_deleg_want) {
> >> +			open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE_EXT;
> >> +			if (status == -EAGAIN)
> >> +				open->op_why_no_deleg = WND4_CONTENTION;
> >> +			else {
> >> +				open->op_why_no_deleg = WND4_RESOURCE;
> >> +				switch (open->op_deleg_want) {
> >> +				case NFS4_SHARE_WANT_READ_DELEG:
> >> +				case NFS4_SHARE_WANT_WRITE_DELEG:
> >> +				case NFS4_SHARE_WANT_ANY_DELEG:
> >> +					break;
> >> +				case NFS4_SHARE_WANT_CANCEL:
> >> +					open->op_why_no_deleg = WND4_CANCELLED;
> >> +					break;
> >> +				case NFS4_SHARE_WANT_NO_DELEG:
> >> +					BUG();	/* not supposed to get here */
> >> +				}
> >> +			}
> >> +		}
> >> +	}
> > 
> > This looks like a reasonably well-encapsulated bit of code--could you
> > move it into a helper function?
> > 
> >>  out:
> >> +	/* 4.1 client trying to upgrade/downgrade delegation? */
> >> +	if (open->op_delegate_type == NFS4_OPEN_DELEGATE_NONE && dp &&
> >> +	    open->op_deleg_want) {
> >> +		if (open->op_deleg_want == NFS4_SHARE_WANT_READ_DELEG &&
> >> +		    dp->dl_type == NFS4_OPEN_DELEGATE_WRITE) {
> >> +			open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE_EXT;
> >> +			open->op_why_no_deleg = WND4_NOT_SUPP_DOWNGRADE;
> >> +		} else if (open->op_deleg_want == NFS4_SHARE_WANT_WRITE_DELEG &&
> >> +			   dp->dl_type == NFS4_OPEN_DELEGATE_WRITE) {
> >> +			open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE_EXT;
> >> +			open->op_why_no_deleg = WND4_NOT_SUPP_UPGRADE;
> >> +		}
> >> +		/* Otherwise the client must be confused wanting a delegation
> >> +		 * it already has, therefore we don't return
> >> +		 * NFS4_OPEN_DELEGATE_NONE_EXT and reason.
> >> +		 */
> >> +	}
> > 
> > Ditto for this.
> > 
> > I'll go ahead and apply the previous two patches pending some regression
> > tests.
> 
> Thanks!
> I'm sending two additional patches that refactor these two helpers and add
> some documentation to the commit message.
> 
> I think it might be helpful to keep them separated but let me know otherwise
> and I'll send a squashed patch instead.

Either way's fine.  What I've got so far is pushed out to

	git://linux-nfs.org/~bfields/linux.git for-3.4

--b.
