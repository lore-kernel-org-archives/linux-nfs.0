Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55189 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752688AbbDFTvy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Apr 2015 15:51:54 -0400
Date: Mon, 6 Apr 2015 15:51:54 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: clear NFSEXP_PNFS flags if not supports pnfs in
 kernel
Message-ID: <20150406195154.GC3363@fieldses.org>
References: <55215117.2050504@gmail.com>
 <20150406120247.GB13634@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150406120247.GB13634@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 06, 2015 at 05:02:47AM -0700, Christoph Hellwig wrote:
> On Sun, Apr 05, 2015 at 11:13:27PM +0800, Kinglong Mee wrote:
> > nfsd should not show "pnfs" flag in proc file if the filesystem
> > does not support pnfs.
> 
> Hmm, do we want to silently clear or reject it?  Either way the
> !CONFIG_NFSD_PNFS stub needs to do the same.

There's a note:

	/* quietly ignore unknown words and anything
	 * following. Newer user-space can try to set
	 * new values, then see what the result was.
	 */

Not sure if that's the best approach, but I guess we should stick with
it.

--b.
