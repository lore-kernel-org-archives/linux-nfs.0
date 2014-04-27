Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f54.google.com ([209.85.216.54]:63085 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752604AbaD0AKm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Apr 2014 20:10:42 -0400
Received: by mail-qa0-f54.google.com with SMTP id w8so5042505qac.13
        for <linux-nfs@vger.kernel.org>; Sat, 26 Apr 2014 17:10:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1398542157-20159-1-git-send-email-toralf.foerster@gmx.de>
References: <1398542157-20159-1-git-send-email-toralf.foerster@gmx.de>
Date: Sat, 26 Apr 2014 20:10:41 -0400
Message-ID: <CAABAsM5nm9eRJXF809TPLu5qNeVU0XLPPjtfnji37REQmYHqsQ@mail.gmail.com>
Subject: Re: [PATCH] fs/nfs/idmap.c: fix a Memory leak for variable desc
From: Trond Myklebust <trondmy@gmail.com>
To: =?UTF-8?Q?Toralf_F=C3=B6rster?= <toralf.foerster@gmx.de>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Apr 26, 2014 at 3:55 PM, Toralf Förster <toralf.foerster@gmx.de> wrote:
> Signed-off-by: Toralf Förster <toralf.foerster@gmx.de>
> ---
>  fs/nfs/idmap.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
> index 567983d..8eb4954 100644
> --- a/fs/nfs/idmap.c
> +++ b/fs/nfs/idmap.c
> @@ -272,8 +272,10 @@ static struct key *nfs_idmap_request_key(const char *name, size_t namelen,
>         ssize_t ret;
>
>         ret = nfs_idmap_get_desc(name, namelen, type, strlen(type), &desc);
> -       if (ret <= 0)
> +       if (ret <= 0) {
> +               kfree(desc);
>                 return ERR_PTR(ret);
> +       }
>
>         rkey = request_key(&key_type_id_resolver, desc, "");
>         if (IS_ERR(rkey)) {

Hi Toralf,

As far as I can tell, the only error that nfs_idmap_get_desc() can
return is ret==-ENOMEM, in which case desc==NULL.
It cannot ever return ret==0, either, since the return value,
'desclen', has a lower bound of '2'. What am I missing?

Cheers
  Trond
