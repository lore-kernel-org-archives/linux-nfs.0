Return-Path: <SRS0=o69+=33=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C66EC2BA83
	for <linux-nfs@archiver.kernel.org>; Fri,  7 Feb 2020 17:25:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C50462082E
	for <linux-nfs@archiver.kernel.org>; Fri,  7 Feb 2020 17:25:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="GWoMycD6"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726988AbgBGRZg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 7 Feb 2020 12:25:36 -0500
Received: from mail-wr1-f68.google.com ([209.85.221.68]:34264 "EHLO
        mail-wr1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726874AbgBGRZg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Feb 2020 12:25:36 -0500
Received: by mail-wr1-f68.google.com with SMTP id t2so3631468wrr.1
        for <linux-nfs@vger.kernel.org>; Fri, 07 Feb 2020 09:25:34 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=QEYwY92w3eojCZcKMTYkTT+Vdn96E6l3fxaUSRKkhPM=;
        b=GWoMycD61Lp5CvK7vjWxvqBsxj2cBAJTqtBnIZDrm17jGwvhAiomw6U7UOzAYiY936
         yowpXxQ6oVN9nr/3LQyoCxK+No/RL/WAzAnc7zoNq3UGRmj1x+0H9n3dPv841FgNKCt4
         9W/W/wNRX3Ix+s4gCGCHTKKgo2bLkqgrHOz4l2qkcv7IMpils6TYTG5le3IUIVojJgpZ
         VsnXq682Kgm8txaz12JOWbmHrf0nvywmFcSj+ITHGrTUlEuAyIQ4fI2VknFbdiyDuLWP
         yyfId609Uk6d/XIdrQOCrl5ocLljL0NMBlUHRnksNKei/41A7YZ2iykiBtGbYQLAJLmM
         0a4Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=QEYwY92w3eojCZcKMTYkTT+Vdn96E6l3fxaUSRKkhPM=;
        b=kLSDWwlcav4OoShhJc3x3SsA7D6+4VnK/TN1VYb7bmMnEzJpx9i0t/KFE65e+Mxa0K
         yBkQlyqy/BCCj5Vdl7dCa+3KYQLXfpcG0LsKQGeW4xfbRW+wa/eTgFN0Xrmzp4715LLF
         dFyQC8VrlJHUyJdK1uM3ppsMbVqXDTjMRkvhGjYVjuIpvep6JrnCBqvCPu/g0ZmjLx2R
         WlXCFQcJPl4hHNM4TzIql9k8TUxWMgvfNxE1wHPyy9jHv2J4xUkjBhLgLCdVzU8LaYMf
         sWcp22tsLN6IzYWRbEEcAx0QTQ+5MFxAxvMul6xTyPypdhS0yJTAr9tpByCb2hy/EtGy
         PY6g==
X-Gm-Message-State: APjAAAWVp+FCg8TnggQyrfggrFPZqNH9vZisOHXBeVV65AVIjIuFp6GU
        bGptuchiP2BBNr5t/dwqs199zJp76GCPOfWTiREe/A==
X-Google-Smtp-Source: APXvYqya7CxZ/zRp8WWXGhZ35bslzQ5sXQWN3E7anDEw8AP9K5nMDNIcbYvy+fcGp7cCRD8olB/DXYHJ4jLkV7x0/7I=
X-Received: by 2002:adf:806c:: with SMTP id 99mr68254wrk.328.1581096334286;
 Fri, 07 Feb 2020 09:25:34 -0800 (PST)
MIME-Version: 1.0
References: <20200207152109.20855-1-steved@redhat.com>
In-Reply-To: <20200207152109.20855-1-steved@redhat.com>
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Fri, 7 Feb 2020 12:25:23 -0500
Message-ID: <CAN-5tyHatMk_xsBW5MHpv7-HyiCMPS9qrz3_O6-XN5KpH_RWtA@mail.gmail.com>
Subject: Re: [PATCH] query_krb5_ccache: Removed dead code that was flagged by
 a covscan
To:     Steve Dickson <steved@redhat.com>
Cc:     Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Feb 7, 2020 at 10:22 AM Steve Dickson <steved@redhat.com> wrote:
>
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  utils/gssd/krb5_util.c | 2 --
>  1 file changed, 2 deletions(-)
>
> diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> index bff759f..a1c43d2 100644
> --- a/utils/gssd/krb5_util.c
> +++ b/utils/gssd/krb5_util.c
> @@ -1066,8 +1066,6 @@ query_krb5_ccache(const char* cred_cache, char **ret_princname,
>                             *ret_realm = strdup(str+1);
>                     }
>                     k5_free_unparsed_name(context, princstring);
> -               } else {
> -                       found = 0;
>                 }

Uhm, sorry wasn't fast enough for you commit decision but I don't see
that this a dead code? krb5_unparse_string() could return an error so
"else" is a valid condition. I mean it's probably unlikely that
check_for_tgt() returns found and they you can't parse the principal
name out of it. But things like memory errors could still be valid
error conditions?


>         }
>         krb5_free_principal(context, principal);
> --
> 2.24.1
>
