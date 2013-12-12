Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zimbra13.linbit.com ([212.69.166.240]:55736 "EHLO
	zimbra13.linbit.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752196Ab3LLTHW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Dec 2013 14:07:22 -0500
Date: Thu, 12 Dec 2013 20:07:20 +0100 (CET)
From: Andreas Gruenbacher <andreas.gruenbacher@linbit.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        reiserfs-devel@vger.kernel.org, xfs@oss.sgi.com,
        jfs-discussion@lists.sourceforge.net, cluster-devel@redhat.com,
        linux-nfs@vger.kernel.org, Jan Kara <jack@suse.cz>
Message-ID: <389888733.69110.1386875240679.JavaMail.zimbra@linbit.com>
In-Reply-To: <20131211104527.223923019@bombadil.infradead.org>
References: <20131211104243.148113893@bombadil.infradead.org> <20131211104527.223923019@bombadil.infradead.org>
Subject: Re: [PATCH 05/18] fs: make posix_acl_chmod more useful
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Christoph,

> +int
> +posix_acl_chmod(struct inode *inode)
> +{
> +	struct posix_acl *acl;
> +	int ret = 0;
> +
> +	if (S_ISLNK(inode->i_mode) || !inode->i_op->set_acl)
> +		return -EOPNOTSUPP;

Symlinks never have get_acl callbacks, so I would remove the S_ISLNK() check here.

Andreas
