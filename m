Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:42746 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932232AbcBBO3t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Feb 2016 09:29:49 -0500
Date: Tue, 2 Feb 2016 09:29:48 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: nfsd: supports read buffer from multiples pages
Message-ID: <20160202142948.GA14068@fieldses.org>
References: <56AE0302.6050101@gmail.com>
 <20160201183805.GB5499@fieldses.org>
 <20160202092054.GA26701@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160202092054.GA26701@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 02, 2016 at 10:20:54AM +0100, Christoph Hellwig wrote:
> On Mon, Feb 01, 2016 at 01:38:05PM -0500, J. Bruce Fields wrote:
> > This is with the xfs block layout?
> > 
> > Christoph, do we know anything about average or worst-case sizes for
> > that layout update field?
> 
> The average is rather small and fits into a single page, the worst
> case is basically unlimited:
> 
> 	(file size / block size) * sizeof(pnfs_block_extent)
> 
> by the protocol, and about half that for a non-stupid client as
> it would merge consecutive blocks and only trigger something close
> to the worst case for a "block allocated, block hole, block allocated, ..."
> pattern.

OK.  And what's the failure mode if the layoutcommit fails?  I guess the
client returns the layout and redoes IO through the MDS.  For a rare
failure maybe that's not so terrible.

So I guess the right thing to do is take Kinglong's patch for now.

After that, it wouldn't be that hard for nfsd4_block_proc_layoutcommit
to decode from an array of pages.  But does the iomaps array end up
being just as big?

--b.
