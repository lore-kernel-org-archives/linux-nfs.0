Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:26262 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757126Ab1JRJuq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Oct 2011 05:50:46 -0400
Message-ID: <4E9D4BF1.9070401@parallels.com>
Date: Tue, 18 Oct 2011 13:50:41 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Jim Rees <rees@umich.edu>
CC: Benny Halevy <bhalevy@tonian.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Silence compiler warning
References: <1318810012-15140-1-git-send-email-rees@umich.edu>
In-Reply-To: <1318810012-15140-1-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have this warning also:
fs/nfs/callback_proc.c:116: warning: ‘ino’ may be used uninitialized in this 
function

17.10.2011 04:06, Jim Rees пишет:
> fs/nfs/callback_proc.c: In function ‘do_callback_layoutrecall’:
> fs/nfs/callback_proc.c:115:26: warning: ‘lo’ may be used uninitialized in this function
>
> No functional change. If no layout is found, we'll return before  using
> "lo".
>
> Signed-off-by: Jim Rees<rees@umich.edu>
> ---
>   fs/nfs/callback_proc.c |    2 +-
>   1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index 43926ad..93633f1 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -112,7 +112,7 @@ static u32 initiate_file_draining(struct nfs_client *clp,
>   				  struct cb_layoutrecallargs *args)
>   {
>   	struct nfs_server *server;
> -	struct pnfs_layout_hdr *lo;
> +	struct pnfs_layout_hdr *lo = NULL;
>   	struct inode *ino;
>   	bool found = false;
>   	u32 rv = NFS4ERR_NOMATCHING_LAYOUT;


-- 
Best regards,
Stanislav Kinsbursky
