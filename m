Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:39129 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874Ab1FGSlZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 14:41:25 -0400
Received: by gwaa18 with SMTP id a18so1905540gwa.19
        for <linux-nfs@vger.kernel.org>; Tue, 07 Jun 2011 11:41:24 -0700 (PDT)
In-Reply-To: <1307462188-13122-1-git-send-email-steved@redhat.com>
References: <1307462188-13122-1-git-send-email-steved@redhat.com>
Date: Tue, 7 Jun 2011 22:41:23 +0400
Message-ID: <BANLkTikuUNx+opL+8TnS=cM9ASnrJYLuLA@mail.gmail.com>
Subject: Re: [PATCH] mountd: group length not being set correctly in auth_unix_gid
From: Pavel Shilovsky <piastryyy@gmail.com>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

2011/6/7 Steve Dickson <steved@redhat.com>:
> From: Rinat Bikov <becase@altlinux.org>
>
> Commit 9274e94d introduce dynamic buffering for gids lists.
> In that patch there was a bug that only used the dynamic
> length on the first call, resulting in the dynamic length
> not being dynamic at all.
>
> Reported-by: Rinat Bikov <becase@altlinux.org>
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/mountd/cache.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
>
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index 0c4a03d..6084893 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -147,8 +147,9 @@ static void auth_unix_gid(FILE *f)
>                if (!groups)
>                        return;
>
> -               groups_len = ngroups = INITIAL_MANAGED_GROUPS;
> +               groups_len = INITIAL_MANAGED_GROUPS;
>        }
> +       ngroups = groups_len;
>
>        if (readline(fileno(f), &lbuf, &lbuflen) != 1)
>                return;
> --
> 1.7.5.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

Looks good. It's almost the same, as I sent before "mountd: Fix
missing varialble assignment in auth_unix_gid"
(https://patchwork.kernel.org/patch/841452/) but it haven't got any
comments yet.

-- 
Best regards,
Pavel Shilovsky.
