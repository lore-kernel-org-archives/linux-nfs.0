Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:36489 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753861AbcBBJU4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Feb 2016 04:20:56 -0500
Date: Tue, 2 Feb 2016 10:20:54 +0100
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@lst.de>
Subject: Re: nfsd: supports read buffer from multiples pages
Message-ID: <20160202092054.GA26701@lst.de>
References: <56AE0302.6050101@gmail.com> <20160201183805.GB5499@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160201183805.GB5499@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 01, 2016 at 01:38:05PM -0500, J. Bruce Fields wrote:
> This is with the xfs block layout?
> 
> Christoph, do we know anything about average or worst-case sizes for
> that layout update field?

The average is rather small and fits into a single page, the worst
case is basically unlimited:

	(file size / block size) * sizeof(pnfs_block_extent)

by the protocol, and about half that for a non-stupid client as
it would merge consecutive blocks and only trigger something close
to the worst case for a "block allocated, block hole, block allocated, ..."
pattern.
