Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4EDE4C54EE9
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Sep 2022 12:29:34 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231806AbiIHM3c (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 8 Sep 2022 08:29:32 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:59272 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231837AbiIHM14 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Sep 2022 08:27:56 -0400
Received: from mail-vs1-xe32.google.com (mail-vs1-xe32.google.com [IPv6:2607:f8b0:4864:20::e32])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 5DE81ED38A
        for <linux-nfs@vger.kernel.org>; Thu,  8 Sep 2022 05:27:53 -0700 (PDT)
Received: by mail-vs1-xe32.google.com with SMTP id o123so18136020vsc.3
        for <linux-nfs@vger.kernel.org>; Thu, 08 Sep 2022 05:27:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
         :date;
        bh=i1yUeKSl7+V1QiCXx8cINoGbuohQMkhiH7Z99zqwsr0=;
        b=QBy5dSW9XpRq3E/7MyVHNIEAj3ccR6SXTOtspl0NSeZNQr++0ngaNdTnlS9l7OtbFW
         J2ZXVDPeqGdx5zG4ZLGg9VPa9K1dFjVYS6lh7f9XKfMC6aoZcggTTPwwLxUB4S2sCRao
         TFal3VACZ44orqbHisSr2aAxP/zxFlE91dSD5qwIzuv9bR+YE3ERhk4CEqN8S/8Gu2Oz
         9HKktVaFCI3sgRBA7imYdhARcRg03qDsUT9cEGDR9Yzd8CwHwKpIGdHPXrS7o3xDiAUL
         0sdACnHud0qBk8cEQNVmFF0Q1SfREmR1l3q1LU6z38v46BaXJe9Zq6AQE/dio+QF6zd/
         V/ZA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=to:subject:message-id:date:from:mime-version:x-gm-message-state
         :from:to:cc:subject:date;
        bh=i1yUeKSl7+V1QiCXx8cINoGbuohQMkhiH7Z99zqwsr0=;
        b=pr2ch7u1X9Bl7iJShryzTfmAjJxlfGprPTDLMJwYeoFHtVugMbtJN/Nb2JHTRz+ekX
         CwKpzfgpkuG7M05ywI7oDZ1iEpRvKKcLDLWhQKD3i37BRnplBjghh2C2/ID+9BuC9nea
         cDck44BKDjOCbhOYQGgUVOggbh+6GKWUSyy4O39bQnuChKKzaE3nfLhDENbW4SMg9mab
         ZjI62XZf0HIu8OIvmvkvqKtYVwPpifNkIn9aTagzErXgKSLmqzgM7XEhz+BaRNMuQ+hV
         YtOTwsAM4+eOskJlCcLxGq4ahOVAATY4vrpJz20Doi8QWj1POrfY4eXalpMGdT2imPgn
         wvvA==
X-Gm-Message-State: ACgBeo0ygWhRuoiAdgI89xR4/aYHNw4XN1GHQJ/jCuEkRgaZ9/YAEyeu
        soB9uiey/5ZLQn/YDll7KirHxoW6saeBadvKYBN6V0Sg7EKX5g==
X-Google-Smtp-Source: AA6agR5XBt6lICKafBAm6VyjH7SbLe5noBPvK4xWkLSVBFoaS2nVwC65/PWbDOO1TkXzokSBmbjbkzipXlBrbSf/DQM=
X-Received: by 2002:a67:ac0b:0:b0:388:6b47:2b1d with SMTP id
 v11-20020a67ac0b000000b003886b472b1dmr2878087vse.37.1662640072084; Thu, 08
 Sep 2022 05:27:52 -0700 (PDT)
MIME-Version: 1.0
From:   battery dude <jyf007@gmail.com>
Date:   Thu, 8 Sep 2022 07:27:05 -0500
Message-ID: <CAMBbDaF2Ni0gMRKNeFTQwgAOPPYy7RLXYwDJyZ1edq=tfATFzw@mail.gmail.com>
Subject: Does NFS support Linux Capabilities
To:     linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

According to https://access.redhat.com/solutions/2117321 this article,
I want to ask, how to make NFS support the penetration of Linux
Capabilities
