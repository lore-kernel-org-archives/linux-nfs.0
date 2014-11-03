Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f177.google.com ([209.85.213.177]:38373 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752458AbaKCUVP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Nov 2014 15:21:15 -0500
Received: by mail-ig0-f177.google.com with SMTP id hl2so5318417igb.16
        for <linux-nfs@vger.kernel.org>; Mon, 03 Nov 2014 12:21:15 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.0 \(1990.1\))
Subject: Re: [PATCH] nfs: remove spurious WARN_ON_ONCE in write path
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <1415045985-60963-1-git-send-email-dros@primarydata.com>
Date: Mon, 3 Nov 2014 15:21:12 -0500
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <D64AFA82-9440-4F93-A541-3B8F19A0664B@primarydata.com>
References: <1415045985-60963-1-git-send-email-dros@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I’m not sure it we want to CC stable on this one - the single warning can simply be ignored.

-dros

> On Nov 3, 2014, at 3:19 PM, Weston Andros Adamson <dros@primarydata.com> wrote:
> 
> This WARN_ON_ONCE was supposed to catch reference counting bugs, but can
> trigger in inappropriate situations.
> 
> This was reproducible using NFSv2 on an architecture with 64K pages -- we
> verified that it was not a reference counting bug and the warning was
> safe to ignore.
> 
> Reported-by: Will Deacon <will.deacon@arm.com>
> Tested-by: Will Deacon <will.deacon@arm.com>
> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
> ---
> fs/nfs/write.c | 2 --
> 1 file changed, 2 deletions(-)
> 
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 12493846a2d3..f83b02dc9166 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -715,8 +715,6 @@ static void nfs_inode_remove_request(struct nfs_page *req)
> 
> 	if (test_and_clear_bit(PG_INODE_REF, &req->wb_flags))
> 		nfs_release_request(req);
> -	else
> -		WARN_ON_ONCE(1);
> }
> 
> static void
> -- 
> 1.9.3 (Apple Git-50)
> 

