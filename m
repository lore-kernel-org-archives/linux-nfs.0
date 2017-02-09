Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:53099 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753488AbdBIQC3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Feb 2017 11:02:29 -0500
Date: Thu, 9 Feb 2017 17:01:58 +0100
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>, chucklever@gmail.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: restore owner override for truncate
Message-ID: <20170209160158.GA16386@lst.de>
References: <20170209142238.5322-1-hch@lst.de> <20170209160131.GE17622@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170209160131.GE17622@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 09, 2017 at 11:01:31AM -0500, J. Bruce Fields wrote:
> On Thu, Feb 09, 2017 at 03:22:38PM +0100, Christoph Hellwig wrote:
> > The switch to vfs_truncate in nfsd_setattr dropped the owner override
> > used for NFS permissions.  Add a copy of vfs_truncate with it restored
> > to the nfsd code for now as it's very late in the cycle, but there
> > should be a way to consolidate it back in the future.
> 
> This also needs:

Yes, indeed.
