Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f178.google.com ([209.85.220.178]:33318 "EHLO
	mail-vc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753209AbaFWX2R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2014 19:28:17 -0400
Received: by mail-vc0-f178.google.com with SMTP id ij19so6972740vcb.9
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jun 2014 16:28:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140623221016.GA9429@pad.redhat.com>
References: <1403559272-11019-1-git-send-email-bfields@redhat.com>
	<CAHQdGtQXjvyaXx9PkYW=96F+wvPEj8-=eGFV2NDpfFZEB77E5w@mail.gmail.com>
	<20140623221016.GA9429@pad.redhat.com>
Date: Mon, 23 Jun 2014 19:28:16 -0400
Message-ID: <CAHQdGtR54dy4DJLbx9jBEFbOM7dxihkZBqFgLpafSXdYuqei9A@mail.gmail.com>
Subject: Re: [PATCH 1/3] nfsd: fix rare symlink decoding bug
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 23, 2014 at 6:10 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 2d305a1..56bdf4a 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -600,7 +600,18 @@ nfsd4_decode_create(struct nfsd4_compoundargs *argp, struct nfsd4_create *create
>                 READ_BUF(4);
>                 create->cr_linklen = be32_to_cpup(p++);
>                 READ_BUF(create->cr_linklen);
> -               SAVEMEM(create->cr_linkname, create->cr_linklen);
> +               /*
> +                * The VFS will want a null-terminated string, and
> +                * null-terminating in place isn't safe since this might
> +                * end on a page boundary:
> +                */
> +               create->cr_linkname =
> +                               kmalloc(create->cr_linklen + 1, GFP_KERNEL);
> +               if (!create->cr_linkname)
> +                       return nfserr_jukebox;
> +               memcpy(create->cr_linkname, p, create->cr_linklen);
> +               create->cr_linkname[create->cr_linklen] = '\0';
> +               defer_free(argp, kfree, create->cr_linkname);
>                 break;
>         case NF4BLK:
>         case NF4CHR:

Note that "defer_free()" does yet another allocation here in order to
make space for a small 'struct tmpbuf' structure. Unlike the first
allocation, there is no check for whether or not that second
allocation is successful above, so you can easily end up with a silent
memory leakage (ditto for a number of other callers of defer_free()).

Looking around at all the other users, wouldn't it perhaps make sense
to replace defer_free() with a helper that does just a single
allocation for both the memory buffer and the struct tmpbuf?

Cheers
  Trond
-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
