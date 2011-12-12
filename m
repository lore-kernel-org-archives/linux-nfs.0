Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35019 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752402Ab1LLXHK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Dec 2011 18:07:10 -0500
Date: Mon, 12 Dec 2011 18:07:10 -0500
To: Tigran Mkrtchyan <kofemann@googlemail.com>
Cc: linux-nfs@vger.kernel.org, Tigran Mkrtchyan <kofemann@gmail.com>
Subject: Re: [PATH v4 0/3] nfsd41: current state id processing
Message-ID: <20111212230710.GF22927@fieldses.org>
References: <1323723627-413-1-git-send-email-tigran.mkrtchyan@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1323723627-413-1-git-send-email-tigran.mkrtchyan@desy.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 12, 2011 at 10:00:24PM +0100, Tigran Mkrtchyan wrote:
> From: Tigran Mkrtchyan <kofemann@gmail.com>
> 
> 
> Yet another update (v4) of current stateid handling
> 
> difference with v3:
> 
> Patches re-organized to only add functionality, e.g. there
> are no patches fixing other patches. Operation flags are
> not used any more. Existence of a corresponding function
> pointer is enough.
> 
> 
> Let me know if you want to see updates less often.
> 
> Tigran.
> 
> currently tested to work in a single compound:
> 
>  OPEN+CLOSE
>  LOCK+WRITE+LOCKU+CLOSE
> 
> On the way (not tested yet):
>  OPEN+LAYOUTGET
> 
> TODO:
>  dispose current stateid on operations which provide CFH, but do not provide stateid.

We also need to go through the list of operations that might set or use
current stateid and make sure we've got them all.  On a quick glance, in
addition to the above, maybe these?:

	COMMIT
	DELETRETURN
	LOCKT
	OPEN_DOWNGRADE
	READ
	SAFEFH/RESTOREFH
	SETATTR
	FREE_STATEID
	TEST_STATEID
	WANT_DELEGATION (?? does it set current_stateid in the case
				where it returns one?)

> 
> Internals:
>  1. struct nfsd4_compound_state contains pointer to current stateid
>  2. during compound processing before operation execution current stateid copied into
>   operations stateid if it's equal to corresponding value ( 0, 1).
>  3. after operation execution current stateid changed to:
>     a) point to stateid of last operation
>     or
>     b) point to NULL, if operation is marked to do so.
> 
> Probably all patches have to be squashed into a single one before merged
> as none of the changes makes sense without others.

I think it's probably OK to do operations (or groups of operations) at a
time, as you have been.  Any operations that remain unfixed will
continue returning EXPIRED, as they have before, so we won't be making
things any worse.

In any case, just make sure the layout stuff is kept separate, as we
want to sort out the current stateid before merging pnfs.

--b.

> 
> Tigran.
> 
> 
> Tigran Mkrtchyan (3):
>   nfsd41: handle current stateid in open and close
>   nfsd41: handle current stateid on lock and locku
>   nfsd41: consume current stateid on read and write
> 
>  fs/nfsd/current_stateid.h |   22 +++++++++++++++
>  fs/nfsd/nfs4proc.c        |   39 +++++++++++++++++++++++---
>  fs/nfsd/nfs4state.c       |   66 +++++++++++++++++++++++++++++++++++++++++++++
>  fs/nfsd/xdr4.h            |    1 +
>  4 files changed, 123 insertions(+), 5 deletions(-)
>  create mode 100644 fs/nfsd/current_stateid.h
> 
> -- 
> 1.7.7.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
