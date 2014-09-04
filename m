Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:36637 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751523AbaIDSH0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2014 14:07:26 -0400
Date: Thu, 4 Sep 2014 11:07:25 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 14/17] locks: __break_lease cleanup in preparation of
 allowing direct removal of leases
Message-ID: <20140904180725.GA11232@infradead.org>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
 <1409834323-7171-15-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1409834323-7171-15-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 04, 2014 at 08:38:40AM -0400, Jeff Layton wrote:
> Eliminate an unneeded "flock" variable. We can use "fl" as a loop cursor
> everywhere. Add a any_leases_conflict helper function as well to
> consolidate a bit of code.

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

One thing that came to mind after starring at this code for a while and
then seeing your cleanup:

the sleep/wake patterns in __break_lease seem highly suboptimal, as
we always wait for the break time on the first least found, why
don't we simply take the max of the lease break times, and wait for
that?

I guess the case of lots of read leases just isn't common enough to
bother..
