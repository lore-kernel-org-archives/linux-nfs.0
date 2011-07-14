Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:52016
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754455Ab1GNWb2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jul 2011 18:31:28 -0400
Date: Thu, 14 Jul 2011 18:31:26 -0400
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Alex Elder <aelder@sgi.com>, xfs-masters@oss.sgi.com, xfs@oss.sgi.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] xfs: failure mapping nfs fh to inode should return ESTALE
Message-ID: <20110714223126.GA28694@infradead.org>
References: <20110714205036.GA19457@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110714205036.GA19457@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jul 14, 2011 at 04:50:36PM -0400, J. Bruce Fields wrote:
> From: J. Bruce Fields <bfields@redhat.com>
> 
> On xfs exports, nfsd is incorrectly returning ENOENT instead of ESTALE
> on attempts to use a filehandle of a deleted file (spotted with pynfs
> test PUTFH3).  The ENOENT was coming from xfs_iget.

With that you mean the ip->i_d.di_mode checks?  Given that we should
only be bale to get these from NFS or the handle ioctls I suspect just
turning them into ESTALE should be fine.

