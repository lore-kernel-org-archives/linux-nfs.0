Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:52006 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815Ab3LLVEq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Dec 2013 16:04:46 -0500
Date: Thu, 12 Dec 2013 13:04:39 -0800
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
Subject: Re: [PATCH 02/18] fs: add get_acl helper
Message-ID: <20131212210439.GA27686@infradead.org>
References: <20131211104243.148113893@bombadil.infradead.org>
 <20131211104526.648135334@bombadil.infradead.org>
 <1724169901.69108.1386875169382.JavaMail.zimbra@linbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1724169901.69108.1386875169382.JavaMail.zimbra@linbit.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 12, 2013 at 08:06:09PM +0100, Andreas Gruenbacher wrote:
> > +	/*
> > +	 * A filesystem can force a ACL callback by just never filling the
> > +	 * ACL cache. But normally you'd fill the cache either at inode
> > +	 * instantiation time, or on the first ->get_acl call.
> > +	 *
> > +	 * If the filesystem doesn't have a get_acl() function at all, we'll
> > +	 * just create the negative cache entry.
> > +	 */
> > +	if (!inode->i_op->get_acl) {
> > +		set_cached_acl(inode, type, NULL);
> > +		return ERR_PTR(-EAGAIN);
> 
> The function should return NULL here.

Indeed.  EAGAIN is the convention check_acl() in fs/namei.c uses,
but it will return that automatically if we just return NULL here.
