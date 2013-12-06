Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:54038 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758023Ab3LFTrW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Dec 2013 14:47:22 -0500
Date: Fri, 6 Dec 2013 11:47:20 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Steven Whitehouse <swhiteho@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, viro@zeniv.linux.org.uk,
        xfs@oss.sgi.com, reiserfs-devel@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, cluster-devel@redhat.com,
        linux-mtd@lists.infradead.org, jfs-discussion@lists.sourceforge.net,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org
Subject: Re: [Cluster-devel] [PATCH 16/18] gfs2: use generic posix ACL
 infrastructure
Message-ID: <20131206194720.GB32122@infradead.org>
References: <20131201115903.910559036@bombadil.infradead.org>
 <20131201120656.539995924@bombadil.infradead.org>
 <1386159157.2711.11.camel@menhir>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1386159157.2711.11.camel@menhir>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 04, 2013 at 12:12:37PM +0000, Steven Whitehouse wrote:
> >  		error = posix_acl_equiv_mode(acl, &mode);
> > +		if (error < 0)
> >  
> Andy Price has pointed out a missing "return error;" here
> 
> > -		if (error <= 0) {
> > -			posix_acl_release(acl);
> > +		if (error == 0)
> >  			acl = NULL;
> >  
> > -			if (error < 0)
> > -				return error;
> > -		}
> > -
> 
> Also, there seems to be a white space error in the xfs patch around line
> 170 in fs/xfs/xfs_iops.c where there is an added "if (default_acl)" with
> a space before the tab,

I'll take care of these for the next version.
