Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f182.google.com ([209.85.212.182]:51949 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755522Ab3CYJeV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Mar 2013 05:34:21 -0400
Received: by mail-wi0-f182.google.com with SMTP id hi18so6357838wib.9
        for <linux-nfs@vger.kernel.org>; Mon, 25 Mar 2013 02:34:20 -0700 (PDT)
Message-ID: <51501A18.7050504@tonian.com>
Date: Mon, 25 Mar 2013 11:34:16 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: fanchaoting <fanchaoting@cn.fujitsu.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] ctl: should return NULL when dmsetup fail in find_dm_name
References: <513DC8BF.5060503@cn.fujitsu.com>
In-Reply-To: <513DC8BF.5060503@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-03-11 14:06, fanchaoting wrote:
> when dmsetup fail in find_dm_name, it should return NULL,if don't
> do it. it will cause core dump in get_dm when do free(name).

Thanks, but what version are you using?
This was already fixed here:
http://git.linux-nfs.org/?p=bhalevy/pnfsd-block-ctl.git;a=commitdiff;h=9082efe1dc12248e530d4200d7150a286abea922

Please update to the latest version
git://linux-nfs.org/~bhalevy/pnfsd-block-ctl.git

Benny

> 
> Signed-off-by: fanchaoting<fanchaoting@cn.fujitsu.com>
> 
> ---
>  ctl.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/ctl.c b/ctl.c
> index 2071b0e..0ac1c44 100644
> --- a/ctl.c
> +++ b/ctl.c
> @@ -489,7 +489,7 @@ find_dm_name(int major, int minor)
>         if (((fd = get_output("/sbin/dmsetup", argv)) == -1) ||
>             ((fp = fdopen(fd, "r")) == NULL)) {
>                 printf("%s: get_output/fdopen failed\n", __func__);
> -               return;
> +               return NULL;
>         }
>         while (fgets(buf, sizeof (buf), fp) != NULL) {
>                 t = __token_init(buf, '\t');
> --
> 1.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
