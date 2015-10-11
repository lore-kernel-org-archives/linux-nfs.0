Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:49068 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751282AbbJKNDV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 Oct 2015 09:03:21 -0400
Date: Sun, 11 Oct 2015 15:03:20 +0200
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org,
        stable@vger.kernel.org
Subject: Re: [PATCH] nfsd/blocklayout: accept any minlength
Message-ID: <20151011130319.GB3726@lst.de>
References: <1444395806-32111-1-git-send-email-hch@lst.de> <20151009152803.GC6825@fieldses.org> <20151009170400.GA7482@lst.de> <20151009174556.GA8188@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151009174556.GA8188@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 09, 2015 at 01:45:56PM -0400, J. Bruce Fields wrote:
> If it affected a released client then it's probably worth it even if
> it's really a client bug.  If it's just something you saw once against
> an -rc1, I'd rather leave it for 4.4.

This one is a server bug uncovered by a client change that went into
4.3-rc.  Additionally when I first reproduced this in Trond's tree it
also caused a hang, but that is now gone.  Given how little activity
the server had around time I'm confident to blame that part on an unknown
client bug.

So yes, we really need it in ASAP and in stable all the way back.
