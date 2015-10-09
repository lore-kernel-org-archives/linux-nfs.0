Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:43609 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751678AbbJIRED (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Oct 2015 13:04:03 -0400
Date: Fri, 9 Oct 2015 19:04:00 +0200
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH] nfsd/blocklayout: accept any minlength
Message-ID: <20151009170400.GA7482@lst.de>
References: <1444395806-32111-1-git-send-email-hch@lst.de> <20151009152803.GC6825@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151009152803.GC6825@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 09, 2015 at 11:28:03AM -0400, J. Bruce Fields wrote:
> OK, planning to apply for 4.3 just on the assumption that you know what
> you're doing, but: I don't get it--it looks like the worst that can
> happen here is we just reuturn LAYOUTUNAVAILABLE to LAYOUTGET.
> Shouldn't the client then just fall back on normal NFS IO?  Why the
> hang?

I've just retested with Trond's latest tree and can't reproduce the
hang anymore.  It used to fence the client due to a lack of response,
but that might have been a different client bug that has now been fixed.
