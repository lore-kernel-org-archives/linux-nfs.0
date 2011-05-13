Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59552 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757670Ab1EMVjH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 May 2011 17:39:07 -0400
Date: Fri, 13 May 2011 17:39:06 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] NFSD: Added TEST_STATEID opreation
Message-ID: <20110513213906.GC14771@fieldses.org>
References: <1304708255-20464-1-git-send-email-bjschuma@netapp.com>
 <1304708255-20464-3-git-send-email-bjschuma@netapp.com>
 <20110510004951.GC3600@fieldses.org>
 <4DCAB73B.4040700@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4DCAB73B.4040700@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, May 11, 2011 at 12:20:11PM -0400, Bryan Schumaker wrote:
> On 05/09/2011 08:49 PM, J. Bruce Fields wrote:
> > On Fri, May 06, 2011 at 02:57:35PM -0400, bjschuma@netapp.com wrote:
> >> +
> >> +	test_stateid->ts_stateids = nfsd4_alloc_ts_pagearray(test_stateid, sizeof(stateid_t));
> >> +	if (IS_ERR(test_stateid->ts_stateids))
> >> +		return PTR_ERR(test_stateid->ts_stateids);
> >> +
> >> +	test_stateid->ts_valid = nfsd4_alloc_ts_pagearray(test_stateid, sizeof(int));
> > 
> > Will this be freed in every case?  I guess you're assuming the encode
> > function will be called whenever the decode succeeds.  Off the top of my
> > head, I don't think that's true if xdr decoding of a later op fails.
> 
> That was what I was assuming.  What is the best way to free this if a later decode fails?  something in nfsd4_proc_compound()?

I had to look at it again and remind myself....  See defer_free() in
fs/nfsd/nfs4xdr.c.

--b.
