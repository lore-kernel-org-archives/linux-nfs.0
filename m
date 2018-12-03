Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4163FC04EB9
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 12:47:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E7F4820850
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 12:47:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="b3MvyAiw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7F4820850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726365AbeLCMsr (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 07:48:47 -0500
Received: from mail-yb1-f196.google.com ([209.85.219.196]:38152 "EHLO
        mail-yb1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726334AbeLCMsr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2018 07:48:47 -0500
Received: by mail-yb1-f196.google.com with SMTP id u103-v6so5204375ybi.5;
        Mon, 03 Dec 2018 04:47:52 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=nIZAWcwFCnwj+r0ouCxLn/SBQVk7wI5JjOGsotALsbI=;
        b=b3MvyAiwzy5GAYKIAz1GW0Wu6USDGY6j7OEceKRv/Wt+IeiuZBkhginiX0B6ovNrip
         Z17uma/icOEfIyDudbZBzn9lK6Gq4u3dyTLz9xEhcmu72chHBGZ2BSyESfGl9Eq+zDiu
         Cw7+LpIygjo+GtGQKqn736rPnO3MIRrPHPxAzYoX4xtEE/ORAuKP3rflTgT6pgI7BaJY
         lHG6tBth9xDmZUwwrpXNstL3Z7+MmF0LidB8YTGsXejASi4PsYu1/JEq7EOICDcLi7EE
         1UNEgMsjYjzV2KoSWaVZGeLq2B3Vx88/Wa9LF1oDj2Md9DNenMObyB1UqcLQ83auhuQp
         DhEA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=nIZAWcwFCnwj+r0ouCxLn/SBQVk7wI5JjOGsotALsbI=;
        b=eCC7GMSsAskw0bgq9S8ZHU4YZLmcuBoeyAQE5e3489n1+mwuvPtKmj+FWtSl5ROjxP
         HubXIPEsNg4j0/xDrQCrXqPHSh1pICtowos1hqmO3ito9szIAGVMLUp8SVHCH3Vg5NWu
         UYISzB6NP/M+mBO1x+XxqrWKRmUse94FxJE3LQ1Y8O+pPOcLINRlGS3swPsZ42H7icGC
         oiXRKJCmewpkXCDMjOcMWHzZ4XjxQ4uySqbq5tJ5Iha8SLSC1/gBEvvBMgyMyaHey13g
         PiOTXiYw1sWDLCd5o5NEBd9dRa5dqyn3x5knbvhCp/bjQD2axTxhBKoD5nr26bWBB9yA
         ZeIQ==
X-Gm-Message-State: AA+aEWYV3J3+JRk0uROO0TSbuTPmsDzVGps9sRjdpRg21nKaBi8310pR
        UAPj+ajWupSQcv4FoS6rCdrFn8LxDwiTBLPQ10Y=
X-Google-Smtp-Source: AFSGD/WcOwrJdyaKzGYGnP+Uy+ohHjhCKq2cJRD1FxjANP3XQLw5xVpVvrCyBcz8SNNdkWiyKFKIIsW2FOrCtKy4bb4=
X-Received: by 2002:a25:ff01:: with SMTP id c1-v6mr15393815ybe.325.1543841271958;
 Mon, 03 Dec 2018 04:47:51 -0800 (PST)
MIME-Version: 1.0
References: <20181203083416.28978-1-david@fromorbit.com> <20181203083416.28978-6-david@fromorbit.com>
In-Reply-To: <20181203083416.28978-6-david@fromorbit.com>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Mon, 3 Dec 2018 14:47:40 +0200
Message-ID: <CAOQ4uxgbFA_T_U53kM-HJH0mYMw3mF205TMgnKWDX-xZ5LrABg@mail.gmail.com>
Subject: Re: [PATCH 05/11] vfs: use inode_permission in copy_file_range()
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
> Similar to FI_DEDUPERANGE, make copy_file_range() check that we have
> write permissions to the destination inode.
>
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---

Looks good.

Reviewed-by: Amir Goldstein <amir73il@gmail.com>

Thanks,
Amir.
