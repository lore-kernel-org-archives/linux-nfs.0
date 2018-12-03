Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F0D2C04EB9
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 12:52:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C4F212087F
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 12:52:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hP9PjQgs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4F212087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726445AbeLCMxA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 07:53:00 -0500
Received: from mail-yb1-f195.google.com ([209.85.219.195]:36516 "EHLO
        mail-yb1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726386AbeLCMw7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2018 07:52:59 -0500
Received: by mail-yb1-f195.google.com with SMTP id w203so1373575ybg.3;
        Mon, 03 Dec 2018 04:52:04 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=PU46l61mD8zyI7RWSeFrATcFxEhqMK/3VmF5vTzjP1Q=;
        b=hP9PjQgsNHICe9lYC62iTeGNT3VJpYgv+gcoyxAeYbbYhph4INuPfC5vl9S/h5MwMq
         eNetmOi7Pub5nQBLWvmJsxyAs9liLsbRpWr5WPRRbzN6rVD8T1kpsdacSavJrcgV92U2
         ngy46x6dY5ZSBFgFJZfWPaU4Sg5qsE/2CjaXjhLa8c6twZGqaa9AzSLXRr4lLJR+d225
         l7xBjwn7x5xRUng9eGTXyeR8gfzAd1qToO6MLJ45QtiadzjM7x4c2aqsk/rN2JwS5lYZ
         Cs+kwo0XoraHl4psMsgc7f9JAvQXkQPXlSQmBtw1J8zX0SxbdgtO52J/l784wSRpv8XV
         9/BA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=PU46l61mD8zyI7RWSeFrATcFxEhqMK/3VmF5vTzjP1Q=;
        b=lz4fOWE22b7KQrIlLTQXJwkZCDLzb9KQClX1sASghCKRnh0SVPi2WoqC21Fe9u64eD
         OImg1Kpy069MCPMxehcfa2Ep1LzJt6ClaBjwEWurE8KDUW0cmRAnsKsAXs/QFOCeSKVw
         2woq4JIopU2h7kGsNucIa589cSyxbk3gRVVZuTp7aqZ4mrNPGcNaAzpmbkPCD2YcmI2Y
         zXBqx2tNzP06qMlG30KmpSnyn/uPXYkPjcXfZtA7lcMpuvAIBExUbWsvE+3AobNfJWzw
         nej+LpVW0BVWUc9uIeD2PU+jGXYo/t4u0KK6Z80RsyuhhlH/1/A4TBwDrwMRQHk4GteG
         3Sow==
X-Gm-Message-State: AA+aEWZcwRv78uuRoIqjTC6db/UWHZaHyu/jm4OV1chkysJR4E09Gkx5
        lfiOuhcshrf3MQ2DWoy5uqhHsTnyso4pHqTR2RM=
X-Google-Smtp-Source: AFSGD/WsKx1mbc6dVksKdSj3PX4+gW6G1mNbcffSVYSyKQoQyLqJ5AJyG+gitKNAqKVvY3SjIkmUB+JawX4LB7lu9MM=
X-Received: by 2002:a25:ff01:: with SMTP id c1-v6mr15406508ybe.325.1543841523787;
 Mon, 03 Dec 2018 04:52:03 -0800 (PST)
MIME-Version: 1.0
References: <20181203083416.28978-1-david@fromorbit.com> <20181203083416.28978-7-david@fromorbit.com>
In-Reply-To: <20181203083416.28978-7-david@fromorbit.com>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Mon, 3 Dec 2018 14:51:52 +0200
Message-ID: <CAOQ4uxibdJaN-tQBnUeLejyReaVbi1HOnvqW=SUP7ph1+VhDuw@mail.gmail.com>
Subject: Re: [PATCH 06/11] vfs: copy_file_range needs to strip setuid bits
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
> The file we are copying data into needs to have its setuid bit
> stripped before we start the data copy so that unprivileged users
> can't copy data into executables that are run with root privs.
>
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---

Looks good.
Reviewed-by: Amir Goldstein <amir73il@gmail.com>

Thanks,
Amir.
