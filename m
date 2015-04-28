Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:42167 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030415AbbD1Rtg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2015 13:49:36 -0400
Date: Tue, 28 Apr 2015 19:49:34 +0200
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>, Jeff Layton <jeff.layton@primarydata.com>,
        linux-nfs@vger.kernel.org,
        Sachin Bhamare <sachin.bhamare@primarydata.com>,
        Jeff Layton <jlayton@primarydata.com>
Subject: Re: [PATCH 2/2] nfsd: fix pNFS return on close semantics
Message-ID: <20150428174934.GA5887@lst.de>
References: <1430139014-28013-1-git-send-email-hch@lst.de> <1430139014-28013-3-git-send-email-hch@lst.de> <20150427203943.GI4083@fieldses.org> <20150427193008.1195d7dd@tlielax.poochiereds.net> <20150428081456.GA21413@lst.de> <20150428160353.GN4083@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150428160353.GN4083@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 28, 2015 at 12:03:53PM -0400, J. Bruce Fields wrote:
> > I'm ok with a cc to stable, but it's a bit borderline.  Note that currently
> > you even applied my two patches to your 4.2 incoming queue, not even 4.1..
> 
> Yeah, those -incoming branches are random works-in-progress and will get
> rebased frequently, I'll move the other to for-4.1 and leave this one
> for 4.2.

I would prefer if we could queue it up for 4.1 if possible.
