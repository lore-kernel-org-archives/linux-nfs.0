Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:53729 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755314AbaIDUOZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2014 16:14:25 -0400
Date: Thu, 4 Sep 2014 13:14:24 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 05/17] locks: generic_delete_lease doesn't need a
 file_lock at all
Message-ID: <20140904201424.GB26054@infradead.org>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
 <1409834323-7171-6-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1409834323-7171-6-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 04, 2014 at 08:38:31AM -0400, Jeff Layton wrote:
> Ensure that it's OK to pass in a NULL file_lock double pointer on
> a F_UNLCK request and convert the vfs_setlease F_UNLCK callers to
> do just that.
> 
> Finally, turn the BUG_ON in generic_setlease into a WARN_ON_ONCE
> with an error return. That's a problem we can handle without
> crashing the box if it occurs.

Can we just make generic_delete_lease (maye renamed to vfs_delete_lease)
the interface for deleting leases instead of going through a useless
multiplex and file operation?

