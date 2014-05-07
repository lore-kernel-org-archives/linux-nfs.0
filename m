Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49901 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750911AbaEGSqm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 May 2014 14:46:42 -0400
Date: Wed, 7 May 2014 14:46:41 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 26/70] NFSd: Fix delegation revocation
Message-ID: <20140507184641.GA8324@fieldses.org>
References: <1397846704-14567-18-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-19-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-20-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-21-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-22-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-23-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-24-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-25-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-26-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-27-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1397846704-14567-27-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 18, 2014 at 02:44:20PM -0400, Trond Myklebust wrote:
> Ensure that the delegations cannot be found by the laundromat etc once
> we add them to the various 'revoke' lists.

The current code does already attempt to do that...  I guess the point
is that there's a race in that it leaves a window after a delegation is
added to one of the local lists but before it's actually unhashed, as
here:

> @@ -3612,7 +3620,8 @@ nfs4_laundromat(struct nfsd_net *nn)
>  				test_val = u;
>  			break;
>  		}
> -		list_move(&dp->dl_recall_lru, &reaplist);
> +		unhash_delegation_locked(dp);
> +		list_add(&dp->dl_recall_lru, &reaplist);
>  	}
>  	spin_unlock(&state_lock);

where we've been dropping a lock with the thing still hashed.

OK, good, but maybe the changelog could be a little more precise about
what's being fixed.

Also it would be nice if this could be done earlier in the series as
it's a bugfix that people will probably want backported.

--b.
