Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60131 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754501AbaIDRsx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2014 13:48:53 -0400
Date: Thu, 4 Sep 2014 10:48:53 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 08/17] locks: plumb a "priv" pointer into the setlease
 routines
Message-ID: <20140904174853.GC16935@infradead.org>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
 <1409834323-7171-9-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1409834323-7171-9-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 04, 2014 at 08:38:34AM -0400, Jeff Layton wrote:
> In later patches, we're going to add a new lock_manager_operation to
> finish setting up the lease while still holding the i_lock.  To do
> this, we'll need to pass a little bit of info in the fcntl setlease
> case (primarily an fasync structure). Plumb the extra pointer into
> there in advance of that.
> 
> We declare this pointer as a void ** to make it clear that this is
> private info, and that the caller isn't required to set this unless
> the lm_setup specifically requires it.

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
