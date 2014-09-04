Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:33110 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753217AbaIDRvd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2014 13:51:33 -0400
Date: Thu, 4 Sep 2014 10:51:32 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 13/17] locks: remove i_have_this_lease check from
 __break_lease
Message-ID: <20140904175132.GG16935@infradead.org>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
 <1409834323-7171-14-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1409834323-7171-14-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 04, 2014 at 08:38:39AM -0400, Jeff Layton wrote:
> I think that the intent of this code was to ensure that a process won't
> deadlock if it has one fd open with a lease on it and then breaks that
> lease by opening another fd. In that case it'll treat the __break_lease
> call as if it were non-blocking.
> 
> This seems wrong -- the process could (for instance) be multithreaded
> and managing different fds via different threads. I also don't see any
> mention of this limitation in the (somewhat sketchy) documentation.
> 
> Remove the check and the non-blocking behavior when i_have_this_lease
> is true.

This looks reasonable to me, but I'm always very worried about changing
userspace exposed behavior..

