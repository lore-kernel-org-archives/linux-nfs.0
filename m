Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:45199 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751566AbaAMNe6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jan 2014 08:34:58 -0500
Received: by mail-ie0-f178.google.com with SMTP id x13so1205334ief.23
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jan 2014 05:34:57 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH] nfs: don't update isize when NFS_INO_LAYOUTCOMMITTING in nfs_update_inode
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <1389599759-2711-1-git-send-email-shaobingqing@bwstor.com.cn>
Date: Mon, 13 Jan 2014 08:34:54 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org
Message-Id: <C689DB34-AC0A-49CF-94DC-74ACB1CB177F@primarydata.com>
References: <n> <1389599759-2711-1-git-send-email-shaobingqing@bwstor.com.cn>
To: shaobingqing <shaobingqing@bwstor.com.cn>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 13, 2014, at 2:55, shaobingqing <shaobingqing@bwstor.com.cn> wrote:

> When a file is in NFS_INO_LAYOUTCOMMITING status, its isize perhaps has not been 
> transferred to the metadate server. So the isize getting from the metadata server
> perhaps is out of date and cannot be used to update the isize of the client.
> 
> Signed-off-by: shaobingqing <shaobingqing@bwstor.com.cn>
> ---
> fs/nfs/inode.c |    3 ++-
> 1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index ebeb94c..caf50a1 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -1402,7 +1402,8 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
> 		if (new_isize != cur_isize) {
> 			/* Do we perhaps have any outstanding writes, or has
> 			 * the file grown beyond our last write? */
> -			if ((nfsi->npages == 0 && !test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) ||
> +			if ((nfsi->npages == 0 && !test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags) &&
> +			     !test_bit(NFS_INO_LAYOUTCOMMITTING, &nfsi->flags)) ||
> 			     new_isize > cur_isize) {
> 				i_size_write(inode, new_isize);
> 				invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;

Ugh. Is there any reason why we can’t just keep NFS_INO_LAYOUTCOMMIT set until the layout commit operation is finished instead of multiplying the tests for it in generic NFS code paths such as nfs_update_inode?

--
Trond Myklebust
Linux NFS client maintainer

