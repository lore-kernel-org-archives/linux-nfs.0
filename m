Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52708 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751012Ab1CKRaX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Mar 2011 12:30:23 -0500
In-Reply-To: <1299107978-3248-1-git-send-email-bookjovi@gmail.com>
References: <1299107978-3248-1-git-send-email-bookjovi@gmail.com>
Date: Fri, 11 Mar 2011 18:22:38 +0100
Message-ID: <AANLkTinXc7uwCdZAFGqg=9ZsWGzos14F8d9YxhCA0q43@mail.gmail.com>
Subject: Re: [PATCH] nfs: fix compilation warning
From: Geert Uytterhoeven <geert@linux-m68k.org>
To: bookjovi@gmail.com
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>,
        Greg Kroah-Hartman <gregkh@suse.de>, stable <stable@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Mar 3, 2011 at 00:19,  <bookjovi@gmail.com> wrote:
> From: Jovi Zhang <bookjovi@gmail.com>
>
> this commit fix compilation warning as following:
> linux-2.6/fs/nfs/nfs4proc.c:3265: warning: comparison of distinct pointer types lacks a cast

And as the offender is on track for 2.6.37.4-stable, it needs to be
applied there, too.

> Signed-off-by: Jovi Zhang <bookjovi@gmail.com>
> ---
>  fs/nfs/nfs4proc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 1ff76ac..c7eb4ee 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3262,7 +3262,7 @@ static int buf_to_pages_noslab(const void *buf, size_t buflen,
>        spages = pages;
>
>        do {
> -               len = min(PAGE_CACHE_SIZE, buflen);
> +               len = min((size_t)PAGE_CACHE_SIZE, buflen);

Alternatively, we could use

len = min_t(size_t, PAGE_CACHE_SIZE, buflen);

which may be somewhat cleaner, as it doesn't add an explicit cast.

>                newpage = alloc_page(GFP_KERNEL);
>
>                if (newpage == NULL)

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
