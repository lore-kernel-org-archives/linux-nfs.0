Return-Path: <SRS0=umLH=R7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77734C43381
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 13:32:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 422382075E
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 13:32:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KmdKtXce"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725939AbfC1NcI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 28 Mar 2019 09:32:08 -0400
Received: from mail-io1-f67.google.com ([209.85.166.67]:40366 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725948AbfC1NcI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Mar 2019 09:32:08 -0400
Received: by mail-io1-f67.google.com with SMTP id d201so17212170iof.7
        for <linux-nfs@vger.kernel.org>; Thu, 28 Mar 2019 06:32:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=8httFPoOHR0qsPFm/C2XpR7+EmZiy9pM8FBDRARYiTg=;
        b=KmdKtXceM6ViEgxLz9c+cXkixjgLkJ2VBo6/5nJrZpzkk/yE7fqHU/BfAGJcY1S5Gk
         7ALsKeu+f4wJSdIPtpSx6cx0ozrqWpvxnDNDyZ5I0XHwe9IINg7b/pf8OsX96H87CPF/
         DTt67tta5B6yqSLUOTpPfUrQngr/WZ1eNL8qRH0Z2uSvFs73vcDYM/Im0X8uOtOYLGIp
         erM5eAG+9PcNRqtxktaOKXQ+FhL/h/AW5shjnJM1sD2VRLjPdR/BlhJurG0nMBali6VR
         xyVZdJLAkQDhWtec0cHOgM3O4+WXIyXvRLe2f70hgHXndPg7ZKGcuZlEvxzAcS0zqovQ
         zcrA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=8httFPoOHR0qsPFm/C2XpR7+EmZiy9pM8FBDRARYiTg=;
        b=AyjgwXHtUKCzDhAM/ujSAGL21wTudGhKsfo+8vQetio9LxgRUzh91s9TKylmB5GD7p
         CUiyHnIeaRS8V5WYLOAAAjcCRNrfwsPsJ3UVcvnnlJYwMIyrLgBO4xhHC2HVlzzPS/nS
         IzUpmGJgI+YFTBVuzXIM+J8PPtHc6ob6oBr0wu5eyBQxatmE6Y9hBb0kdmZmju1Nlfs5
         e+mgomTwjZCt1fJ3HE4esewzxvTK59FAx7ppT3IaIe2RzBEqsk9oqMJrfd+j8fWSLGZ1
         MU2MNuffKkIW/oGMVGarKbyvifRYqmNlIZZpiA4FOzwUoMX5IRkJ3RwCJ9DhpM4ohqCF
         j1iQ==
X-Gm-Message-State: APjAAAUA+Ngz7bPZlIaMv9uDEttfN7aDBKyz6GpBj5H5GbgKt1XsgOsB
        TjXniEXrfHYOKqA/qCH7MHIJVybmGSpy4eSRCA==
X-Google-Smtp-Source: APXvYqzhXhh3HzssN/qtBU77CHoWHpxOfDpDDNWkIyGq8Yb6UT+qLp+7glv2p1qcdJdfKVukuw2rhPPmbrXUDedMOms=
X-Received: by 2002:a6b:ed0c:: with SMTP id n12mr15303494iog.259.1553779927205;
 Thu, 28 Mar 2019 06:32:07 -0700 (PDT)
MIME-Version: 1.0
References: <23B588B3-C119-4036-B60B-7872A52129F4@zentai.name> <YT1PR01MB35469D45DD321F14EFAD0536DD580@YT1PR01MB3546.CANPRD01.PROD.OUTLOOK.COM>
In-Reply-To: <YT1PR01MB35469D45DD321F14EFAD0536DD580@YT1PR01MB3546.CANPRD01.PROD.OUTLOOK.COM>
From:   Trond Myklebust <trondmy@gmail.com>
Date:   Thu, 28 Mar 2019 09:31:56 -0400
Message-ID: <CAABAsM6vfAdQij121_QiNN5trsDipnEK5SJTsGPVvaaOq_v98w@mail.gmail.com>
Subject: Re: [PATCH] Add EMFILE to nfsd errors
To:     Rick Macklem <rmacklem@uoguelph.ca>
Cc:     Armin Zentai <armin@zentai.name>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, 27 Mar 2019 at 17:25, Rick Macklem <rmacklem@uoguelph.ca> wrote:
>
> I don't believe that EMFILE is specified as an NFS error in the RFCs?
>

Agreed. Applying this patch would lead to a NFS protocol violation
that most clients would be unprepared for. For instance, I believe the
Linux client would end up mapping it to EIO as an unrecognised status
code. Other clients may map it to something different, or may even end
up falling over.

Cheers,
  Trond

> rick
>
> ________________________________________
> From: linux-nfs-owner@vger.kernel.org <linux-nfs-owner@vger.kernel.org> on behalf of Armin Zentai <armin@zentai.name>
> Sent: Wednesday, March 27, 2019 3:03:43 PM
> To: linux-nfs@vger.kernel.org; J. Bruce Fields; Jeff Layton
> Subject: [PATCH] Add EMFILE to nfsd errors
>
> This patch adds the EMFILE to nfsd errors for better error output.
>
> I've encountered a hard-to-debug situation, when I used a fuse under an NFS export, because of a 'too many open files' error.
>
> Before the patch nfsd warns with this message:
> 'nfsd4_process_open2 failed to open newly-created file! status=5'  (5: EIO)
>
> After the patch:
> 'nfsd4_process_open2 failed to open newly-created file! status=24' (24: EMFILE)
>
> Also the client returns with EREMOTEIO instead of EIO, which indicates a server error from the NFS client side.
>
> Signed-off-by: Armin ZENTAI <armin@zentai.name>
> ---
>  fs/nfsd/nfsd.h           | 1 +
>  fs/nfsd/nfsproc.c        | 1 +
>  include/uapi/linux/nfs.h | 1 +
>  3 files changed, 3 insertions(+)
>
> diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
> index 066899929863..19a269d75fb5 100644
> --- a/fs/nfsd/nfsd.h
> +++ b/fs/nfsd/nfsd.h
> @@ -217,6 +217,7 @@ void                nfsd_lockd_shutdown(void);
>  #define        nfserr_cb_path_down     cpu_to_be32(NFSERR_CB_PATH_DOWN)
>  #define        nfserr_locked           cpu_to_be32(NFSERR_LOCKED)
>  #define        nfserr_wrongsec         cpu_to_be32(NFSERR_WRONGSEC)
> +#define nfserr_emfile                  cpu_to_be32(NFSERR_EMFILE)
>  #define nfserr_badiomode               cpu_to_be32(NFS4ERR_BADIOMODE)
>  #define nfserr_badlayout               cpu_to_be32(NFS4ERR_BADLAYOUT)
>  #define nfserr_bad_session_digest      cpu_to_be32(NFS4ERR_BAD_SESSION_DIGEST)
> diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
> index 0d20fd161225..ff9e883c7829 100644
> --- a/fs/nfsd/nfsproc.c
> +++ b/fs/nfsd/nfsproc.c
> @@ -810,6 +810,7 @@ nfserrno (int errno)
>                 { nfserr_serverfault, -ENFILE },
>                 { nfserr_io, -EUCLEAN },
>                 { nfserr_perm, -ENOKEY },
> +               { nfserr_emfile, -EMFILE },
>         };
>         int     i;
>
> diff --git a/include/uapi/linux/nfs.h b/include/uapi/linux/nfs.h
> index 946cb62d64b0..dcb0ea33f2db 100644
> --- a/include/uapi/linux/nfs.h
> +++ b/include/uapi/linux/nfs.h
> @@ -57,6 +57,7 @@
>         NFSERR_NOTDIR = 20,             /* v2 v3 v4 */
>         NFSERR_ISDIR = 21,              /* v2 v3 v4 */
>         NFSERR_INVAL = 22,              /* v2 v3 v4 */
> +       NFSERR_EMFILE = 24,             /* v2 v3 v4 */
>         NFSERR_FBIG = 27,               /* v2 v3 v4 */
>         NFSERR_NOSPC = 28,              /* v2 v3 v4 */
>         NFSERR_ROFS = 30,               /* v2 v3 v4 */
> --
> 2.11.0
>
