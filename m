Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:52016 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825Ab3LLVFF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Dec 2013 16:05:05 -0500
Date: Thu, 12 Dec 2013 13:05:02 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Andreas Gruenbacher <andreas.gruenbacher@linbit.com>
Cc: Christoph Hellwig <hch@infradead.org>, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-mtd@lists.infradead.org, Mark Fasheh <mfasheh@suse.com>,
        Joel Becker <jlbec@evilplan.org>, reiserfs-devel@vger.kernel.org,
        xfs@oss.sgi.com, jfs-discussion@lists.sourceforge.net,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 05/18] fs: make posix_acl_chmod more useful
Message-ID: <20131212210502.GB27686@infradead.org>
References: <20131211104243.148113893@bombadil.infradead.org>
 <20131211104527.223923019@bombadil.infradead.org>
 <389888733.69110.1386875240679.JavaMail.zimbra@linbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <389888733.69110.1386875240679.JavaMail.zimbra@linbit.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 12, 2013 at 08:07:20PM +0100, Andreas Gruenbacher wrote:
> Christoph,
> 
> > +int
> > +posix_acl_chmod(struct inode *inode)
> > +{
> > +	struct posix_acl *acl;
> > +	int ret = 0;
> > +
> > +	if (S_ISLNK(inode->i_mode) || !inode->i_op->set_acl)
> > +		return -EOPNOTSUPP;
> 
> Symlinks never have get_acl callbacks, so I would remove the S_ISLNK() check here.

Yeah, will simplify it.  Same for the other places where we have both
checks.
