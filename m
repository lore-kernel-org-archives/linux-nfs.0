Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60805 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754174AbaIDRuP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2014 13:50:15 -0400
Date: Thu, 4 Sep 2014 10:50:14 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 11/17] locks: move freeing of leases outside of i_lock
Message-ID: <20140904175014.GE16935@infradead.org>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
 <1409834323-7171-12-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1409834323-7171-12-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 04, 2014 at 08:38:37AM -0400, Jeff Layton wrote:
> There was only one place where we still could free a file_lock while
> holding the i_lock -- lease_modify. Add a new list_head argument to the
> lm_change operation, pass in a private list when calling it, and fix
> those callers to dispose of the list once the lock has been dropped.

As mentioned I don't see a real need for this, but it does look correct
to me.

Reviewed-by: Christoph Hellwig <hch@lst.de>
