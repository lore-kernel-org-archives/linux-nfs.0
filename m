Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zimbra13.linbit.com ([212.69.166.240]:55771 "EHLO
	zimbra13.linbit.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752053Ab3LLTHz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Dec 2013 14:07:55 -0500
Date: Thu, 12 Dec 2013 20:07:54 +0100 (CET)
From: Andreas Gruenbacher <andreas.gruenbacher@linbit.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        reiserfs-devel@vger.kernel.org, xfs@oss.sgi.com,
        jfs-discussion@lists.sourceforge.net, cluster-devel@redhat.com,
        linux-nfs@vger.kernel.org, Jan Kara <jack@suse.cz>
Message-ID: <1342716144.69126.1386875274180.JavaMail.zimbra@linbit.com>
In-Reply-To: <20131211104527.044064384@bombadil.infradead.org>
References: <20131211104243.148113893@bombadil.infradead.org> <20131211104527.044064384@bombadil.infradead.org>
Subject: Re: [PATCH 04/18] fs: add generic xattr_acl handlers
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Christoph,

> +static int
> +posix_acl_xattr_set(struct dentry *dentry, const char *name,
> +		const void *value, size_t size, int flags, int type)
> +{
> +	struct inode *inode = dentry->d_inode;
> +	struct posix_acl *acl = NULL;
> +	int ret;
> +
> +	if (!IS_POSIXACL(inode))
> +		return -EOPNOTSUPP;
> +	if (S_ISLNK(inode->i_mode) || !inode->i_op->set_acl)
> +		return -EOPNOTSUPP;

Sama here, I would remove the S_ISLNK() check.

Andreas
