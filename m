Return-Path: <SRS0=W4f8=7K=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7FAF5C433DF
	for <linux-nfs@archiver.kernel.org>; Thu, 28 May 2020 20:43:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 5FF29208A7
	for <linux-nfs@archiver.kernel.org>; Thu, 28 May 2020 20:43:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="pQjZXc1+"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2407238AbgE1Um6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 28 May 2020 16:42:58 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:43992 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2407321AbgE1Um4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 May 2020 16:42:56 -0400
Received: from mail-ej1-x635.google.com (mail-ej1-x635.google.com [IPv6:2a00:1450:4864:20::635])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 8A469C08C5C6
        for <linux-nfs@vger.kernel.org>; Thu, 28 May 2020 13:42:56 -0700 (PDT)
Received: by mail-ej1-x635.google.com with SMTP id a2so1375533ejb.10
        for <linux-nfs@vger.kernel.org>; Thu, 28 May 2020 13:42:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:from:date:message-id:subject:to;
        bh=qjhbjX6cWObDwZo7rT4OHwMsXKizS2RujfmOEdv1Jag=;
        b=pQjZXc1+1NvpngzhuSY9mxDudVDUapOS5zw/X2Rg94KNzrqhdyEJ9LOW13mkm5pmys
         Hf4ltnkyMguR9IUpZ8jbi3JvMyrx9/HFdCg0feBhiRHsPcXrxCzYfrjzWTebN0kRxNk8
         vfcZtmLCF2yWx/pp72/Q3J8EjjB5elx/BWmUKS940WU267SmhxRR/HtpT27OLkpGq7k7
         P9B1HZjR/jPhECb1TG7vigaRvPbvQZDpdfn6TAYwuukc95CQakIdDUQ+ykwxpG7cJvsy
         OX/gTF+MMpJVoIiX9rWjC3SPYmYsrc6JlAUuH5y6jw3GyEmmy/P8VTPRF8Jfp6C8wQdo
         32tw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
        bh=qjhbjX6cWObDwZo7rT4OHwMsXKizS2RujfmOEdv1Jag=;
        b=tQ9PAf8WxlaERA6w2ZsgVrAX4Zooxi7yCo2EtOooGWE4yO1G1ox4LKreG5YsbqOcdg
         QjhAcj5TzpgKHcUN4mgga+j6IIp/Gk5xHMsinC1AKHu83iphrCCqItd648aCFqfqCgb9
         Y6YQhbopvhhyP9eZ5QrMHgL+jMRVw4chJlJpvAmycvJDE9fjUh6dLREjRQPpmSabRPa2
         9dyDVZbg/zG3U9gBMrjSbVG2QhyI+h8LNfSq+6BhzPcliBs5STK3Ukd4l4NF2MHy5imu
         +TncMnbGxIl5xoQ3bmhwwFQEfNDwwBA/CT7miTt+fVxAX9+nKH1SiHT2kR6krZTkp4Wo
         wH0g==
X-Gm-Message-State: AOAM531g5Rs2BsFoR9o7uZFPTUsQCgcAoHglMKJEqZngUwPrMY/N8rRj
        8/taUUJuRGGbwGaroTRDXsOAbxds8It/mjnJf7B/4g==
X-Google-Smtp-Source: ABdhPJzOFehQAYrrzwYiLyQB/rGJiYf0NYCsngSDqV3ELvflOcPu07ckP20XrnsBXO/cTziKSeSIj8lqyuxn9wKWPak=
X-Received: by 2002:a17:906:3454:: with SMTP id d20mr4559450ejb.451.1590698573845;
 Thu, 28 May 2020 13:42:53 -0700 (PDT)
MIME-Version: 1.0
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Thu, 28 May 2020 16:42:42 -0400
Message-ID: <CAN-5tyE-hr2Fd1dKt=DUrVh-FJXzgGx5zhWr17SSbM1LOZ-pGQ@mail.gmail.com>
Subject: How to handle revocation of locking state
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi folks,

Looking for recommendation on what the client is suppose to be doing
in the following situation. Client opens a file and has a byte-range
lock which returned a locking state. Client is acquiring another byte
range lock. It uses the returned locking stated for the 2nd lock.
Server returns ADMIN_REVOKED.

Currently the client goes into an infinite loop of just resending the
same LOCK operation with
the same locking stateid.

Is this a recoverable situation? The fact that the lock state was
revoked, should it be an automatic EIO since previous lock is lost (so
why bother going forward)? Or should the client retry the lock but
send it with the open stateid?

Thank you.
