Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zimbra13.linbit.com ([212.69.166.240]:55710 "EHLO
	zimbra13.linbit.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751902Ab3LLTGN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Dec 2013 14:06:13 -0500
Date: Thu, 12 Dec 2013 20:06:09 +0100 (CET)
From: Andreas Gruenbacher <andreas.gruenbacher@linbit.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        reiserfs-devel@vger.kernel.org, xfs@oss.sgi.com,
        jfs-discussion@lists.sourceforge.net, cluster-devel@redhat.com,
        linux-nfs@vger.kernel.org, Jan Kara <jack@suse.cz>
Message-ID: <1724169901.69108.1386875169382.JavaMail.zimbra@linbit.com>
In-Reply-To: <20131211104526.648135334@bombadil.infradead.org>
References: <20131211104243.148113893@bombadil.infradead.org> <20131211104526.648135334@bombadil.infradead.org>
Subject: Re: [PATCH 02/18] fs: add get_acl helper
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Christoph,

> +struct posix_acl *get_acl(struct inode *inode, int type)
> +{
> +	struct posix_acl *acl;
> +
> +	acl = get_cached_acl(inode, type);
> +	if (acl != ACL_NOT_CACHED)
> +		return acl;
> +
> +	if (!IS_POSIXACL(inode))
> +		return NULL;
> +
> +	/*
> +	 * A filesystem can force a ACL callback by just never filling the
> +	 * ACL cache. But normally you'd fill the cache either at inode
> +	 * instantiation time, or on the first ->get_acl call.
> +	 *
> +	 * If the filesystem doesn't have a get_acl() function at all, we'll
> +	 * just create the negative cache entry.
> +	 */
> +	if (!inode->i_op->get_acl) {
> +		set_cached_acl(inode, type, NULL);
> +		return ERR_PTR(-EAGAIN);

The function should return NULL here.

Andreas
