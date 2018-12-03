Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 986ECC04EB9
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 12:55:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4FD1720834
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 12:55:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mROoPdiy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4FD1720834
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726401AbeLCM4y (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 07:56:54 -0500
Received: from mail-yb1-f194.google.com ([209.85.219.194]:42386 "EHLO
        mail-yb1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726238AbeLCM4y (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2018 07:56:54 -0500
Received: by mail-yb1-f194.google.com with SMTP id s8so3050537ybe.9;
        Mon, 03 Dec 2018 04:55:58 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=1BipUQLZB0m15SpHImtVi99FCmLtYXhLuvN0lEQ6Pyw=;
        b=mROoPdiydXcH3lcEOZc4JsYyT7ewYs2/mSJ2LbQ1ITARaXZCztEbaPcdq9tr7LkMI0
         Eu+PwSfvQsYyVJh8H1XCWpittJbLyMVbfMh+I7y7EJ+oOcM1B2PF+9ofZEBkCLrIZGOn
         pmH2Lmy65FEhpCtq/huAYgirI53ru0Pqz/+8dF2P/AduG/6CxHMkxPuAmQRWv2ornPf4
         sWurNRf3lQADiXRCqTfn8mADP8uyTnVJF6999pXwx/9hOJJifhjpjagmcUv8jRJaI/Zp
         9nMR9DcjNVn+taDIIi8d18YI4j2bjmZbTwEVHEsk9GB5utmPiLOlub/f7bIDbajMWhwz
         7Kww==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=1BipUQLZB0m15SpHImtVi99FCmLtYXhLuvN0lEQ6Pyw=;
        b=E+n0lsF0XSZIGf+GLloPptNttpNWN5F0Sy9kkiif1OFLlJZnnFidz8X31wnKRnp4Mb
         iQGFve7cliWDHuo/WMVVj65PBu1gLVdM1UfXES2xFMIyKohAPkG4oAxizUxMr01nqsy5
         Kvbyjxat+VWgfFRHFkDtu2h3A7sajLX41DeUPj2radQTF333d2H0+XczSaZ3IDM/QUyX
         hxq3Y87sYrCpgBblUaj0IunVINZQENaD8Wwsi/YiJIXluQVIIJok4FQSS9rjyHxt7n5A
         iB0/ieTaCLeW5i6XzMpTS5W6GengciAuTgxRulj2NWYYbok5ad6SCIeWocv9l0deJVOk
         3jpg==
X-Gm-Message-State: AA+aEWYqCwyLxgD94HXu5eIpuwSjeKJ70W5YJTib9oyJNZTPlrGgNuWP
        5PqZ6HMulIc1qwTZ65n7mg8X0BtBFo+JFjcB++U=
X-Google-Smtp-Source: AFSGD/VigUOkLkYffe048boYgVDbfjC1Jp1uZCtqcQS/WnOiylHF5KKnYmLxefhH/YbyedZndep/bQwVfKCHuR5zxvA=
X-Received: by 2002:a5b:310:: with SMTP id j16-v6mr15215305ybp.320.1543841757542;
 Mon, 03 Dec 2018 04:55:57 -0800 (PST)
MIME-Version: 1.0
References: <20181203083416.28978-1-david@fromorbit.com> <20181203083416.28978-12-david@fromorbit.com>
In-Reply-To: <20181203083416.28978-12-david@fromorbit.com>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Mon, 3 Dec 2018 14:55:46 +0200
Message-ID: <CAOQ4uxj9k6rHAXFrNPUDVD7Mw32JeK7T0HUaytxjvmguyjDjGw@mail.gmail.com>
Subject: Re: [PATCH 11/11] ovl: allow cross-device copy_file_range calls
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
> Restrictions on cross-device copy_file_range() only affect the
> vfs_copy_file_range() call to the lower filesystems. They will
> handle the copy appropriately, so OVL will never see a EXDEV error
> from them. Hence we can remove the EXDEV checks and error handling
> from the ovl_copy_file_range() implementation.
>
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---

Looks good.

Reviewed-by: Amir Goldstein <amir73il@gmail.com>

Thanks,
Amir.
