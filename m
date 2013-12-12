Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:52027 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797Ab3LLVFd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Dec 2013 16:05:33 -0500
Date: Thu, 12 Dec 2013 13:05:31 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Andreas Gruenbacher <andreas.gruenbacher@linbit.com>
Cc: Christoph Hellwig <hch@infradead.org>, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-mtd@lists.infradead.org, Mark Fasheh <mfasheh@suse.com>,
        Joel Becker <jlbec@evilplan.org>, reiserfs-devel@vger.kernel.org,
        xfs@oss.sgi.com, jfs-discussion@lists.sourceforge.net,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 16/18] gfs2: use generic posix ACL infrastructure
Message-ID: <20131212210531.GC27686@infradead.org>
References: <20131211104243.148113893@bombadil.infradead.org>
 <20131211104529.142731540@bombadil.infradead.org>
 <966512490.69128.1386875318581.JavaMail.zimbra@linbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <966512490.69128.1386875318581.JavaMail.zimbra@linbit.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 12, 2013 at 08:08:38PM +0100, Andreas Gruenbacher wrote:
> Christoph,
> 
> gfs2 has a left-over get_acl callback in gfs2_symlink_iops in
> fs/gfs2/inode.c, from a long time ago, which should be removed
> as well.

Ok, will fix.
