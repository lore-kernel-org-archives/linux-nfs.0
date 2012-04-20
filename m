Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:56337 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758Ab2DTU0Z convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Apr 2012 16:26:25 -0400
Received: by vcqp1 with SMTP id p1so6683783vcq.19
        for <linux-nfs@vger.kernel.org>; Fri, 20 Apr 2012 13:26:24 -0700 (PDT)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
In-Reply-To: <1334949705-33393-1-git-send-email-dros@netapp.com>
References: <1334949705-33393-1-git-send-email-dros@netapp.com>
Date: Fri, 20 Apr 2012 22:26:24 +0200
Message-ID: <CAGue13oJHJnLL2KwJWtCgECX5KrdoQYVdMJwzm54=7M+DHV7pQ@mail.gmail.com>
Subject: Re: [PATCH] NFS4: fix referrals with IPv6 mounts
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: Weston Andros Adamson <dros@netapp.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 20, 2012 at 9:21 PM, Weston Andros Adamson <dros@netapp.com> wrote:
> nfs4_path() was parsing the path component by splitting on the first colon.
> This is wrong when an IPv6 address is used to mount a server.
>
> For example, having mounted 'fc00::10:/export', nfs4_path() returned
> ':10:/export'.  This causes referrals (using IPv4 or IPv6 addresses) to fail
> in nfs4_validate_fspath().
>
> Parsing the path component by using the *last* colon works with
> IPv6 as well as IPv4 addrs.
>

what about
http://www.ietf.org/rfc/rfc2732.txt

Tigran.

> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> ---
>  fs/nfs/nfs4namespace.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
> index 9c8eca3..dd3dd30 100644
> --- a/fs/nfs/nfs4namespace.c
> +++ b/fs/nfs/nfs4namespace.c
> @@ -59,7 +59,7 @@ static char *nfs4_path(struct dentry *dentry, char *buffer, ssize_t buflen)
>        char *limit;
>        char *path = nfs_path(&limit, dentry, buffer, buflen);
>        if (!IS_ERR(path)) {
> -               char *colon = strchr(path, ':');
> +               char *colon = strrchr(path, ':');
>                if (colon && colon < limit)
>                        path = colon + 1;
>        }
> --
> 1.7.4.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
