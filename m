Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:36705 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449AbaIDSIT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2014 14:08:19 -0400
Date: Thu, 4 Sep 2014 11:08:18 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 15/17] locks: give lm_break a return value
Message-ID: <20140904180818.GB11232@infradead.org>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
 <1409834323-7171-16-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1409834323-7171-16-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 04, 2014 at 08:38:41AM -0400, Jeff Layton wrote:
> Christoph suggests:
> 
>    "Add a return value to lm_break so that the lock manager can tell the
>     core code "you can delete this lease right now".  That gets rid of
>     the games with the timeout which require all kinds of race avoidance
>     code in the users."
> 
> Do that here and have the nfsd lease break routine use it when it detects
> that there was a race between setting up the lease and it being broken.

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
