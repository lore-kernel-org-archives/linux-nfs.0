Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:31211 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753223Ab3LBWNH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Dec 2013 17:13:07 -0500
Message-ID: <529D05AB.7080306@oracle.com>
Date: Mon, 02 Dec 2013 16:11:55 -0600
From: Dave Kleikamp <dave.kleikamp@oracle.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>, viro@zeniv.linux.org.uk
CC: xfs@oss.sgi.com, Mark Fasheh <mfasheh@suse.com>,
        reiserfs-devel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        cluster-devel@redhat.com, linux-mtd@lists.infradead.org,
        Joel Becker <jlbec@evilplan.org>, jfs-discussion@lists.sourceforge.net,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org
Subject: Re: [Jfs-discussion] [PATCH 15/18] jfs: use generic posix ACL infrastructure
References: <20131201115903.910559036@bombadil.infradead.org> <20131201120656.391407780@bombadil.infradead.org>
In-Reply-To: <20131201120656.391407780@bombadil.infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/01/2013 05:59 AM, Christoph Hellwig wrote:
> Copy the scheme I introduced to btrfs many years ago to only use the
> xattr handler for ACLs, but pass plain attrs straight through.

Looks good.

> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Dave Kleikamp <dave.kleikamp@oracle.com>

> ---
>  fs/jfs/acl.c       |  105 ++++++++++++++++++++------------------------------
>  fs/jfs/file.c      |    4 +-
>  fs/jfs/jfs_acl.h   |    7 +---
>  fs/jfs/jfs_xattr.h |    2 +
>  fs/jfs/namei.c     |    1 +
>  fs/jfs/super.c     |    2 +
>  fs/jfs/xattr.c     |  108 ++++++++++++++++++----------------------------------
>  7 files changed, 89 insertions(+), 140 deletions(-)
