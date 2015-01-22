Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:49638 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752975AbbAVUUf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jan 2015 15:20:35 -0500
Date: Thu, 22 Jan 2015 21:20:34 +0100
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>, Jeff Layton <jlayton@primarydata.com>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        xfs@oss.sgi.com
Subject: Re: a simple and scalable pNFS block layout server V2
Message-ID: <20150122202033.GA14817@lst.de>
References: <1421925006-24231-1-git-send-email-hch@lst.de> <20150122200618.GI898@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150122200618.GI898@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 22, 2015 at 03:06:18PM -0500, J. Bruce Fields wrote:
> By the way, Jeff, do you consider the lock changes are ready?  Would you
> mind if I pulled or cherry-picked them into the nfsd tree just to
> simplify merging this stuff for 3.20?  (Assuming it's going to be
> ready.)

I did the rebase because he mentioned he wanted to get it into 3.20.

Note that the conflicts were fairly trivial, so it's something we
could just ignore and let Linus handle the merge in the worst case.
