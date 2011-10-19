Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48240 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751556Ab1JSQnQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Oct 2011 12:43:16 -0400
Date: Wed, 19 Oct 2011 12:42:16 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: agruen@kernel.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk,
        dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V7 08/26] vfs: Add new file and directory create
 permission flags
Message-ID: <20111019164216.GC30864@fieldses.org>
References: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1318951981-5508-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1318951981-5508-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 18, 2011 at 09:02:43PM +0530, Aneesh Kumar K.V wrote:
> From: Andreas Gruenbacher <agruen@kernel.org>
> 
> Some permission models distinguish between the permission to create a
> non-directory and a directory.  Pass this information down to
> inode_permission() as mask flags
...
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index f3ebf86..60361c6 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -67,6 +67,8 @@ struct inodes_stat_t {
>  #define MAY_CHDIR		0x00000040
>  /* called from RCU mode, don't block */
>  #define MAY_NOT_BLOCK		0x00000080
> +#define MAY_CREATE_FILE		0x00000100
> +#define MAY_CREATE_DIR		0x00000200

Hm, are the flags in fs/nfsd/vfs.h going to need fixing up?

Looking at the nfsd code....  No, I guess it's OK, nfsd does

	err = inode_permission(inode, acc & (MAY_READ|MAY_WRITE|MAY_EXEC));

So we can wait to fix up any collisions until we need to pass these
extra bits.

--b.
