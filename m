Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55853 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754728Ab3CEWU3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Mar 2013 17:20:29 -0500
Date: Tue, 5 Mar 2013 17:20:27 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/5] nfsd: add a reply_cache_stats file to nfsd for
 tracking DRC performance
Message-ID: <20130305222027.GG15816@fieldses.org>
References: <1362423400-24380-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1362423400-24380-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 04, 2013 at 01:56:35PM -0500, Jeff Layton wrote:
> This patchset adds some stats tracking to the DRC to hopefully allow
> us to make better-informed decisions in the future on performance
> improvements.
> 
> Some of these I've already posted, but reposting them now as a set
> to allow Bruce to more easily merge them. I think these would be good
> for 3.9, but they're obviously not critical.

OK, thanks.  I'll queue them up for 3.10.

--b.

> 
> Jeff Layton (5):
>   nfsd: break out comparator into separate function
>   nfsd: track memory utilization in the DRC
>   nfsd: add new reply_cache_stats file in nfsdfs
>   nfsd: keep track of the max and average time to search the cache
>   nfsd: keep stats on worst hash balancing seen so far
> 
>  fs/nfsd/cache.h    |   1 +
>  fs/nfsd/nfscache.c | 144 ++++++++++++++++++++++++++++++++++++++++++++++-------
>  fs/nfsd/nfsctl.c   |   9 ++++
>  3 files changed, 137 insertions(+), 17 deletions(-)
> 
> -- 
> 1.7.11.7
> 
