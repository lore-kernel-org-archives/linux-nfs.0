Return-Path: <SRS0=nj1J=RK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92295C43381
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Mar 2019 15:02:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5B77920449
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Mar 2019 15:02:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GSXON3hk"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726161AbfCGPCY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 7 Mar 2019 10:02:24 -0500
Received: from mail-lf1-f41.google.com ([209.85.167.41]:39121 "EHLO
        mail-lf1-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726127AbfCGPCY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Mar 2019 10:02:24 -0500
Received: by mail-lf1-f41.google.com with SMTP id r123so11911217lff.6
        for <linux-nfs@vger.kernel.org>; Thu, 07 Mar 2019 07:02:23 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :content-transfer-encoding;
        bh=EjCuhpqoP7zw90m43pLWnFZBq+baED7i4bsS6AnZQZA=;
        b=GSXON3hkq/oQcBK8OFU98+ALb+2fxbu5Pez6CUdW5RN/y/h+YbNELc1tanh3UL5w/q
         7crVrSiMMGV32aiacwxNLn7PcGyeVWdFoX6fBHFTPSjuU791ja7NihfwPB0LSO8ycqvz
         pdcIhkOwhSluAkqK29MCtuuVEupxOj6t1cAZTqZQW0iilV9XlpZOQNgXzMZmZB4WUGJ7
         PCYaUW+INMsQEsNRIifUEdE1ixDIK7SQCthBNanEWNZuQ68FqYvKGt3YpNbPbfaD1T6o
         uo91SlEGqtAIIAqF29hWPvd7olBtuDItvyUgIp7bPlF3sjmyWJyCNIQCXjJW9Arc61Sb
         VlEQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:content-transfer-encoding;
        bh=EjCuhpqoP7zw90m43pLWnFZBq+baED7i4bsS6AnZQZA=;
        b=mkO/I3/kFhIE6snnFUmbqCXgJRGx+cjcxIj/UfhowCHnDQ/W0O65PfXnxMjK3ysvuC
         fXiiBRbgAy15ZrgIkpzxBYKAynMbw5exbhhcopbLO8Szk3+wFFaRo7GgQK+nICYp7NHm
         pFT2K/UJTBTFY3Mme9EWGjF0ldboNzjZOXbfodo3VZobQMEjwuKrElVzVHimGeoYUEqa
         RHlWJgxeeHAQPkTrIQS/pZYbl4g1Tm8/ViycKj5k4kEyb7lUBbkNhNVgtwVlnyTVEwo/
         6dCeDJvHjO//nuUv9gH2UmnVXCRrh+kj/PuPmUF6BJ8/p2Q5A5G/0mtPAJYRV4Jcssal
         tvrA==
X-Gm-Message-State: APjAAAWpVX9Nkl6J3i635JarU+2XtXQKWqnJ1F8fZz2DYwfoIa78AdfL
        39CWAAQbrcXrcx90pJGZdloTs5nk7eV9ISbXSgfNTjMm
X-Google-Smtp-Source: APXvYqyI04AN8g9goeQx41K9Z9CqxQKDNtoijla2B4yj8vDWwk/xhPZ1MWCfWpCKDEVVszAhyNNCUaG1ULNtDUY6/Cs=
X-Received: by 2002:a19:8c56:: with SMTP id i22mr7272050lfj.79.1551970942385;
 Thu, 07 Mar 2019 07:02:22 -0800 (PST)
MIME-Version: 1.0
References: <CACyXjPx84Y9jwrAQzvhjDz2jH8aZnx8MsvJjQvW9FzDfZy0HCQ@mail.gmail.com>
In-Reply-To: <CACyXjPx84Y9jwrAQzvhjDz2jH8aZnx8MsvJjQvW9FzDfZy0HCQ@mail.gmail.com>
From:   Richard Sharpe <realrichardsharpe@gmail.com>
Date:   Thu, 7 Mar 2019 07:01:54 -0800
Message-ID: <CACyXjPx0oxRhKiSm1AJU9pQ27FEMHYuAnhfLO_NSV20fQVgmyA@mail.gmail.com>
Subject: Re: Check that an RPC compiler has been installed
To:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Mar 6, 2019 at 5:17 PM Richard Sharpe
<realrichardsharpe@gmail.com> wrote:
>
> When I installed Fedora-29 to check out building on Fedora I didn't
> have rpcgen installed.
>
> autogen worked and configure worked but make failed in spectacular ways.
>
> The attached patch warns the user during configure but is perhaps not
> the correct test, because of rpcgen is on your path but not where the
> earlier tests expect it, things will still likely fail.

Here is a better version. Since we already know we didn't find rpcgen,
just let the user know.

Tested by uninstalling rpcgen.

From 6caea95ccebb5d3635b3d1c91e8683954fe61645 Mon Sep 17 00:00:00 2001
From: root <realrichardsharpe@gmail.com>
Date: Wed, 6 Mar 2019 19:51:12 -0500
Subject: [PATCH] If we don't find rpcgen let the user know about it rather
 than getting an error later during make.

---
 configure.ac | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/configure.ac b/configure.ac
index cb9d921..b23bb6a 100644
--- a/configure.ac
+++ b/configure.ac
@@ -154,6 +154,9 @@ AC_ARG_WITH(rpcgen,
        if test "$rpcgen_path" =3D "yes"; then
            for p in /usr/local/bin/rpcgen /usr/bin/rpcgen /bin/rpcgen
            do if test -f $p ; then RPCGEN_PATH=3D$p ; break; fi ; done
+           if test -z "$RPCGEN_PATH"; then
+                AC_MSG_ERROR([Please install rpcgen or use --with-rpcgen])
+           fi
        elif test "$rpcgen_path" !=3D "internal"; then
            RPCGEN_PATH=3D$rpcgen_path
        else
--
2.19.1



--=20
Regards,
Richard Sharpe
(=E4=BD=95=E4=BB=A5=E8=A7=A3=E6=86=82=EF=BC=9F=E5=94=AF=E6=9C=89=E6=9D=9C=
=E5=BA=B7=E3=80=82--=E6=9B=B9=E6=93=8D)(=E4=BC=A0=E8=AF=B4=E6=9D=9C=E5=BA=
=B7=E6=98=AF=E9=85=92=E7=9A=84=E5=8F=91=E6=98=8E=E8=80=85)
