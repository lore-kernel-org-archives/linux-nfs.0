Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:37168 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753540AbbCBVFI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Mar 2015 16:05:08 -0500
Received: by iecrl12 with SMTP id rl12so51509097iec.4
        for <linux-nfs@vger.kernel.org>; Mon, 02 Mar 2015 13:05:07 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2070.6\))
Subject: Re: [PATCH] NFS: Ensure that buffered writes wait for O_DIRECT writes to complete
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <1425096977-9293-1-git-send-email-trond.myklebust@primarydata.com>
Date: Mon, 2 Mar 2015 16:05:05 -0500
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <72BBB619-7847-49C5-A9D7-5E943ED87EBC@primarydata.com>
References: <1425096977-9293-1-git-send-email-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good to me.

-dros



> On Feb 27, 2015, at 11:16 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> The O_DIRECT code will grab the inode->i_mutex and flush out buffered
> writes, before scheduling a read or a write. However there is no
> equivalent in the buffered write code to wait for O_DIRECT to complete.
> 
> Fixes a reported issue in xfstests generic/133, when first performing an
> O_DIRECT write followed by a buffered write.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
> fs/nfs/file.c | 4 ++++
> 1 file changed, 4 insertions(+)
> 
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index 94712fc781fa..c045c7169fa0 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -372,6 +372,10 @@ start:
> 				 nfs_wait_bit_killable, TASK_KILLABLE);
> 	if (ret)
> 		return ret;
> +	/*
> +	 * Wait for O_DIRECT to complete
> +	 */
> +	nfs_inode_dio_wait(mapping->host);
> 
> 	page = grab_cache_page_write_begin(mapping, index, flags);
> 	if (!page)
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

