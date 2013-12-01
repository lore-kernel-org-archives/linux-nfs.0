Return-Path: linux-nfs-owner@vger.kernel.org
Received: from alt-proxy27.mail.unifiedlayer.com ([69.89.19.24]:47145 "HELO
	alt-proxy27.mail.unifiedlayer.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750900Ab3LANlt convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 1 Dec 2013 08:41:49 -0500
Subject: Re: [PATCH 10/18] hfsplus: use generic posix ACL infrastructure
Mime-Version: 1.0 (Apple Message framework v1085)
Content-Type: text/plain; charset=us-ascii
From: Vyacheslav Dubeyko <slava@dubeyko.com>
In-Reply-To: <20131201120655.410590428@bombadil.infradead.org>
Date: Sun, 1 Dec 2013 17:36:51 +0300
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        reiserfs-devel@vger.kernel.org, xfs@oss.sgi.com,
        jfs-discussion@lists.sourceforge.net, cluster-devel@redhat.com,
        linux-nfs@vger.kernel.org
Message-Id: <3F8D73A0-9449-42FB-8CFA-D1E4C86FF0B2@dubeyko.com>
References: <20131201115903.910559036@bombadil.infradead.org> <20131201120655.410590428@bombadil.infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 1, 2013, at 2:59 PM, Christoph Hellwig wrote:

> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
> fs/hfsplus/acl.h       |    9 +--
> fs/hfsplus/dir.c       |    1 +
> fs/hfsplus/inode.c     |    3 +-
> fs/hfsplus/posix_acl.c |  161 +++++-------------------------------------------
> fs/hfsplus/xattr.c     |    5 +-
> fs/hfsplus/xattr.h     |    2 -
> 6 files changed, 24 insertions(+), 157 deletions(-)
> 

Reviewed-by: Vyacheslav Dubeyko <slava@dubeyko.com>

The patch looks correct. I think only that it makes sense to add debug messages
in hfsplus_get_posix_acl() and hfsplus_set_posix_acl(). Previously, debug
messages were in hfsplus_xattr_get_posix_acl() and hfsplus_xattr_set_posix_acl()
but the patch removes these methods.

Thanks,
Vyacheslav Dubeyko.

