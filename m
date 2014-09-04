Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60515 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753306AbaIDRtl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2014 13:49:41 -0400
Date: Thu, 4 Sep 2014 10:49:40 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 09/17] locks: define a lm_setup handler for leases
Message-ID: <20140904174940.GD16935@infradead.org>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
 <1409834323-7171-10-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1409834323-7171-10-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 04, 2014 at 08:38:35AM -0400, Jeff Layton wrote:
> ...and move the fasync setup into it for fcntl lease calls. At the same
> time, change the semantics of how the file_lock double-pointer is
> handled. Up until now, on a successful lease return you got a pointer to
> the lock on the list. This is bad, since that pointer can no longer be
> relied on as valid once the inode->i_lock has been released.
> 
> Change the code to instead just zero out the pointer if the lease we
> passed in ended up being used. Then the callers can just check to see
> if it's NULL after the call and free it if it isn't.
> 
> The priv argument has the same semantics. The lm_setup function can
> zero the pointer out to signal to the caller that it should not be
> freed after the function returns.

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
