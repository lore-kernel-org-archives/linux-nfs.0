Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:39989 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754138Ab1IJH3g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 10 Sep 2011 03:29:36 -0400
Received: by qyk7 with SMTP id 7so606684qyk.19
        for <linux-nfs@vger.kernel.org>; Sat, 10 Sep 2011 00:29:35 -0700 (PDT)
Message-ID: <4E6B11DD.1010905@tonian.com>
Date: Sat, 10 Sep 2011 00:29:33 -0700
From: Benny Halevy <bhalevy@tonian.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH] pnfsblock: fix size of upcall message
References: <1315599074-21412-1-git-send-email-rees@umich.edu>
In-Reply-To: <1315599074-21412-1-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-09-09 13:11, Jim Rees wrote:
> Make the status field explicitly 32 bits.  "...it's unlikely that the kernel
> and userspace would differ on the size of an int here, but it might be a
> good idea to go ahead and make that explicitly 32 bits in case we end up
> dealing with more exotic arches at some point in the future."
> 
> Suggested-by: Jeff Layton <jlayton@redhat.com>
> Signed-off-by: Jim Rees <rees@umich.edu>

merged. thanks!

Benny

> ---
>  fs/nfs/blocklayout/blocklayout.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
> index 8900396..42acf7e 100644
> --- a/fs/nfs/blocklayout/blocklayout.h
> +++ b/fs/nfs/blocklayout/blocklayout.h
> @@ -150,7 +150,7 @@ BLK_LSEG2EXT(struct pnfs_layout_segment *lseg)
>  }
>  
>  struct bl_dev_msg {
> -	int status;
> +	int32_t status;
>  	uint32_t major, minor;
>  };
>  
