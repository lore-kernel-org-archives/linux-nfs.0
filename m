Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60192 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755268AbaIZSDO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2014 14:03:14 -0400
Date: Fri, 26 Sep 2014 14:03:13 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: refactor nfsd callback handling
Message-ID: <20140926180313.GB27412@fieldses.org>
References: <1411553959-5280-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1411553959-5280-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 24, 2014 at 12:19:15PM +0200, Christoph Hellwig wrote:
> This series reshuffles the callback code to allow for easier implementation
> of more callback operations.

They look sensible to me, but I got a few pynfs timeouts in overnight
testing, which I can't reproduce.

Almost positive the bug's elsewhere (pynfs, or something broken with my
test machines), but I'll give it a few more tries and then push it out.

Thanks!

--b.
