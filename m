Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81D37C04EBF
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 12:42:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 44F5920850
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 12:42:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cUHDVe9h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44F5920850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726456AbeLCMnk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 07:43:40 -0500
Received: from mail-yb1-f195.google.com ([209.85.219.195]:42540 "EHLO
        mail-yb1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725975AbeLCMnk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2018 07:43:40 -0500
Received: by mail-yb1-f195.google.com with SMTP id s8so3035763ybe.9;
        Mon, 03 Dec 2018 04:42:45 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=FYiaBSD2sLw/PxoWJhLD9O7NQvctubSu9R2bLaiCak8=;
        b=cUHDVe9hejJ1YnX/Hv6d/PUQELahHf486WM/SZNPCnxM0aSFw3/Ct3Qjj2b2kR+nrc
         HD0XnekMX9iNvH13rjGTfMGLA+M97NBXBTA8NnO9k1ZX+0UlOQHxTWLbanxjiSueRVd7
         XVUvprvQrHH8ixsxkayrACwkXaaRZv3t+0Fi6S1Eh2Z47M1gJYRHjVqck8WWf3Gg8U52
         3Ih/8TukuwoQnIv2aLQdIidOI2trEMPcusAP2ZKW32CDqryfRS7WR42nh6dSElhoGfzM
         IHfMMYCPEJzhxmDXbFeUV+3OtKlBo8HVJ4SupFhGcDl4jJ+o8JOia5hVToZ3SDgRTe9s
         iTJw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=FYiaBSD2sLw/PxoWJhLD9O7NQvctubSu9R2bLaiCak8=;
        b=NhUwGT+b2IqbE/mA0RZeao3/mOSd3VOySsQEK/NDA3U8xoG7sf5DPgtjP6GJxzj33e
         oPbZeKIcARMUa+Vh83H4IJzxL8xrN41jn98HQ81SUQO/WT3GvtZ6p+PJnw5pWFUMzhtq
         9iCwBLMhRjI53Sc8/JOUPatq4L055OiuNmcZCEES8bVkdXkYnXMyIzyOl6u7sTXfn/i+
         UOOt+98eANxBrou+ewE2LkmLDujFNvyUIRA/cdMsbs2nYi2+vbYEXga//7Rz+/V+GksZ
         BgVd419sNniBtYgTg1jQBDJuRetoheGX2fCt0+VyBwIHaTIHFz3Jd1UTXUPJR7HIN+WP
         PAyA==
X-Gm-Message-State: AA+aEWY7erY5xcVawqsQHWQ5CaRrafw/cE/1WJEArvux/dDpIvDG0oOF
        TS1n75q5UhREE9YjaXBKEHiM7M2/ppVuqLAU4Ng=
X-Google-Smtp-Source: AFSGD/XPfzW3k/9U8HC7avnw2GPPkQDlHxYGqT4bGzwk/FmkrYD1BOA1XWg8RetxjwPydQ7jFf133XVcAzeHkTk0R2I=
X-Received: by 2002:a25:ff01:: with SMTP id c1-v6mr15377425ybe.325.1543840964988;
 Mon, 03 Dec 2018 04:42:44 -0800 (PST)
MIME-Version: 1.0
References: <20181203083416.28978-1-david@fromorbit.com> <20181203083416.28978-5-david@fromorbit.com>
In-Reply-To: <20181203083416.28978-5-david@fromorbit.com>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Mon, 3 Dec 2018 14:42:33 +0200
Message-ID: <CAOQ4uxgOUJ+VQmiXKXStBJiBASXXpoe6GUEVDaFFmfWEgiMVzw@mail.gmail.com>
Subject: Re: [PATCH 04/11] vfs: add missing checks to copy_file_range
To:     Dave Chinner <david@fromorbit.com>
Cc:     linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-xfs <linux-xfs@vger.kernel.org>,
        Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        overlayfs <linux-unionfs@vger.kernel.org>,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Dec 3, 2018 at 10:34 AM Dave Chinner <david@fromorbit.com> wrote:
>
> From: Dave Chinner <dchinner@redhat.com>
>
> Like the clone and dedupe interfaces we've recently fixed, the
> copy_file_range() implementation is missing basic sanity, limits and
> boundary condition tests on the parameters that are passed to it
> from userspace. Create a new "generic_copy_file_checks()" function
> modelled on the generic_remap_checks() function to provide this
> missing functionality.
>
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---

Looks good.

Reviewed-by: Amir Goldstein <amir73il@gmail.com>
