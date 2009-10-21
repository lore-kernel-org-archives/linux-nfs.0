From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCHSET 0/5] nfsd: Cleanup nfsd/pnfsd headers and code placment
Date: Wed, 21 Oct 2009 10:10:23 +0200
Message-ID: <4ADEC1EF.8040107@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Benny Halevy <bhalevy@gmail.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	Trond Myklebust <Trond.Myk
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:62429 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751918AbZJUIKX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Oct 2009 04:10:23 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


In motivation to better organize pnfs code and have minimal impact
on the rest of the nfsd code-base, I've done some cleanups and code
movements. The begging of which was done by Andy in the last round.

The first needed thing was to re-introduce some sense into nfsd
headers. I've taken all include/linux/nfsd/*.h files, one by one,
and included them as first header in a .c file. Then fixed any
missing includes from that header.

Here is current state after this patchset:

// Still BAD
#include <linux/nfsd/const.h> 
	/* NEEDS #include <linux/types.h> in linux/sunrpc/msg_prot.h */
#include <linux/nfsd/export.h> 
	/* NEEDS #include <linux/nfsd/nfsfh.h> */
#include <linux/nfsd/syscall.h> /* Broken because of export.h above */

[Should I fix those too?]

// GOOD or fixed
#include <linux/nfsd/cache.h>
#include <linux/nfsd/debug.h>
#include <linux/nfsd/nfs4layoutxdr.h>
#include <linux/nfsd/nfs4pnfsdlm.h>
#include <linux/nfsd/nfsd4_pnfs.h>
#include <linux/nfsd/nfsd.h>
#include <linux/nfsd/nfsfh.h>
#include <linux/nfsd/pnfsd.h>
#include <linux/nfsd/state.h>
#include <linux/nfsd/stats.h>
#include <linux/nfsd/xdr.h>
#include <linux/nfsd/xdr3.h>
#include <linux/nfsd/xdr4.h>

I then proceeded to re-arrange some pnfs code/definitions into
pnfsd specific files.

And finally all files thouched in this round where include-cleaned

Here are the list of patches:

[PATCH 1/5] sunrpc: Clean never used include files

	This one is for Trond, include-cleaning

[PATCH 2/5] nfsd: Fix independence of a few nfsd related headers
[PATCH 3/5] nfsd: Fix independence of linux/nfsd/ headers

	These two fix nfsd headers independence. As explained above.
	(Should I squash these together)

[PATCH 4/5] SQUASHME pnfsd: Move pnfsd code out of nfs4state.c/h

	Now it is much easier to do this one.

[PATCH 5/5] nfsd: Remove lots of un-needed includes

	And some more include-cleaning

TODO: Some more of above magic done to more nfsd files

Thanks
Boaz
