Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60040 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159Ab3I2MVb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Sep 2013 08:21:31 -0400
Date: Sun, 29 Sep 2013 05:21:30 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 05/49] pnfsd: introduce pnfsd header files
Message-ID: <20130929122130.GI21083@infradead.org>
References: <52447EA0.7070004@primarydata.com>
 <1380220810-12909-1-git-send-email-bhalevy@primarydata.com>
 <20130929114327.GB25750@infradead.org>
 <52481939.7060405@primarydata.com>
 <20130929121345.GA21083@infradead.org>
 <52481B11.2080407@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <52481B11.2080407@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Sep 29, 2013 at 03:20:33PM +0300, Benny Halevy wrote:
> Bruce - are you ok with moving the pnfs interface definitions to
> include/linux/exportfs.h along with struct export_operations?
> 
> In fact we can actually extend struct export_operations rather
> than adding pnfs_export_operations...

Yes, it probably should go into the export ops, although the actual
method signatures might need to be made a litle less nfs-specific for
that.

