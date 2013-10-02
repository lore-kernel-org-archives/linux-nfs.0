Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:44204 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753207Ab3JBQF3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Oct 2013 12:05:29 -0400
Date: Wed, 2 Oct 2013 09:05:27 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>, Al Viro <viro@ZenIV.linux.org.uk>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        sandeen@redhat.com
Subject: Re: why is i_ino unsigned long, anyway?
Message-ID: <20131002160527.GB23875@infradead.org>
References: <20130912160324.GE1462@fieldses.org>
 <20130912193328.GP13318@ZenIV.linux.org.uk>
 <20130929115454.GA3953@infradead.org>
 <20131002142527.GD14808@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131002142527.GD14808@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 02, 2013 at 10:25:27AM -0400, J. Bruce Fields wrote:
> If so then it's no huge code duplication to it by hand:
> 
> 	if (inode->i_op->getattr)
> 		inode->i_op->getattr(path->mnt, path->dentry, &stat);
> 	else
> 		generic_fillattr(inode, &stat);

Maybe make that a vfs_getattr_nosec and let vfs_getattr call it?

Including a proper kerneldoc comment explaining when to use it, please.

