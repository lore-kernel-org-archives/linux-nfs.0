Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:60980 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750925AbdLKG3u (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Dec 2017 01:29:50 -0500
Date: Mon, 11 Dec 2017 06:29:47 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: NeilBrown <neilb@suse.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Amir Goldstein <amir73il@gmail.com>,
        lkml <linux-kernel@vger.kernel.org>,
        Lennart Poettering <lennart@poettering.net>
Subject: Re: [PATCH 1/4] fs/notify: fdinfo can report unsupported file
 handles.
Message-ID: <20171211062946.GX21978@ZenIV.linux.org.uk>
References: <151297214390.7818.7216826079527521005.stgit@noble>
 <151297224512.7818.18333908109878259066.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <151297224512.7818.18333908109878259066.stgit@noble>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 11, 2017 at 05:04:05PM +1100, NeilBrown wrote:
> @@ -385,7 +385,9 @@ int exportfs_encode_inode_fh(struct inode *inode, struct fid *fid,
>  {
>  	const struct export_operations *nop = inode->i_sb->s_export_op;
>  
> -	if (nop && nop->encode_fh)
> +	if (nop)
> +		return FILEID_INVALID;
> +	if (nop->encode_fh)
>  		return nop->encode_fh(inode, fid->raw, max_len, parent);

This might as well have been

	if (nop)
		return FILEID_INVALID;
	BUG();

Have you ever tested that?
