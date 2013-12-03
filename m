Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51172 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755098Ab3LCUym (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Dec 2013 15:54:42 -0500
Date: Tue, 3 Dec 2013 15:54:33 -0500
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org,
        xfs@oss.sgi.com, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] fs: fix iversion handling
Message-ID: <20131203205433.GB2648@fieldses.org>
References: <20131119151707.GA13412@infradead.org>
 <20131202173636.GA17724@infradead.org>
 <529DA5C6.7040403@panasas.com>
 <20131203094507.GD4906@infradead.org>
 <529DB536.7050008@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <529DB536.7050008@panasas.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 03, 2013 at 12:40:54PM +0200, Boaz Harrosh wrote:
> On 12/03/2013 11:45 AM, Christoph Hellwig wrote:
> > On Tue, Dec 03, 2013 at 11:35:02AM +0200, Boaz Harrosh wrote:
> >> Hi Christoph
> >>
> >> What happens with all other filesystems exported under KNFSD?
> >>
> >> As I understand inode_inc_iversion() is used in NFSv4 and up,
> >> what will increment the inode-version on changed attributes
> >> for them?
> > 
> > It's used by the filesystem for the change attribute that NFSDd
> > can optionally use.  Most filesystsems don't support it and work
> > okay enough when NFS exported.  No other filesystem will need
> > to adopt for this patch specificly, given that no other filesystem
> > uses this infrastructure.
> > 
> 
> OK Thanks, I did not know that. I assumed change-attribute is
> naturally supported.
> 
> I will look at ext4 example and wire up exofs. Because it is very
> important for me to support the change-attribute properly.

Just please don't follow ext4's example of making support dependent on a
mount option.

--b.
