Return-Path: <SRS0=RY80=RS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 656ECC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 18:06:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2B6D62186A
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 18:06:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=netronome-com.20150623.gappssmtp.com header.i=@netronome-com.20150623.gappssmtp.com header.b="VLEpDKAa"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726688AbfCOSGB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Mar 2019 14:06:01 -0400
Received: from mail-qt1-f178.google.com ([209.85.160.178]:32820 "EHLO
        mail-qt1-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725956AbfCOSGB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Mar 2019 14:06:01 -0400
Received: by mail-qt1-f178.google.com with SMTP id k14so5390054qtb.0
        for <linux-nfs@vger.kernel.org>; Fri, 15 Mar 2019 11:06:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=netronome-com.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:organization:mime-version
         :content-transfer-encoding;
        bh=2TWg5XYfz4YyiVeJ4VvuMzLYCUb7lUrpDnqi8rS7Z1E=;
        b=VLEpDKAakFQYv8uyLJTX+Cj1QY5cdCjDNojzziOPZ/JkSeC9SltqriFtwl85AIytBk
         K1YVM9umsQtsLFG9DlAkkz3FZd9Y5QKo/1wKNOslxOJB28OYSjHUp+U22Lqh9aEW2Qau
         xUGZvSaIYnuoMbJuqIzwzDvt/WOcVkEl4xiiQLkRkW6T6o0gEWeA5tEB0f8YrB+yv5pf
         Kf9WRtgxm90TsWrKKhmzSqwsLfjZgBNrRAf/08e/oRLnGdIzYEq5GNQLBYjbT/mZs/Bb
         CSnoivzcV2BrerUfDL+i8KeolmrCWOQl4+RMN3nvAwjeXOoDhh91QvFyJSKPz57tGAxo
         aDLA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:organization
         :mime-version:content-transfer-encoding;
        bh=2TWg5XYfz4YyiVeJ4VvuMzLYCUb7lUrpDnqi8rS7Z1E=;
        b=uM9dFA/r5qHaxBPim5L/8tR1Z69HJdmP9cKqvwVyyH7MrB0DjddhDyyekJEAu4Hfzc
         L2MotkEdKgI9qfiLRLMncJj/gZB4Yn0mOeTGZZi1Oe0EeUYsTHW8hipP20YaylZhNAxC
         W4ZBB22WsxJIuEdwPgB8/jPa2e4o4NCThCyCjzgHE88b7wNAtux+5OZ9vpiY5UxpOcNV
         BJWZtDIsVIRK3eh6N5erd4TRUwO1SrEsBEm6lek052UPw+anHSCsVYvIJVbTx+sxj3HS
         7QlEv/zqMF7gl7IowjA4bU5qHjNnzKC9hqDm0aDVafaYpkmgGdyItiazLNX2G0wVB/yY
         EJbg==
X-Gm-Message-State: APjAAAXnWJrXpwp/keBQYkOa2DquIFIYUqAUAtWSPkxXJegiQg3pT8hK
        DOXFtdC30gwgWYUXA5oL416XJQ==
X-Google-Smtp-Source: APXvYqy7wMiSdfw3vVYA1lzscCa03gnTmFXQLDcvubDlyq2zFlOvnRuqNzFIg18WsOmlYp8PU8kngw==
X-Received: by 2002:ac8:d49:: with SMTP id r9mr1012116qti.192.1552673160204;
        Fri, 15 Mar 2019 11:06:00 -0700 (PDT)
Received: from cakuba.netronome.com ([66.60.152.14])
        by smtp.gmail.com with ESMTPSA id e4sm2051907qta.84.2019.03.15.11.05.59
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Mar 2019 11:05:59 -0700 (PDT)
Date:   Fri, 15 Mar 2019 11:05:55 -0700
From:   Jakub Kicinski <jakub.kicinski@netronome.com>
To:     Trond Myklebust <trond.myklebust@hammerspace.com>
Cc:     linux-nfs@vger.kernel.org,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: mount.nfs: Protocol error after upgrade to linux/master
Message-ID: <20190315110555.0807d015@cakuba.netronome.com>
Organization: Netronome Systems, Ltd.
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi,

I just upgraded from:

commit a3b1933d34d5bb26d7503752e3528315a9e28339 (net)
Merge: c6873d18cb4a 24319258660a
Author: David S. Miller <davem@davemloft.net>
Date:   Mon Mar 11 16:22:49 2019 -0700

to

commit 3b319ee220a8795406852a897299dbdfc1b09911
Merge: 9352ca585b2a b6e88119f1ed
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Thu Mar 14 10:48:14 2019 -0700

and I'm seeing:

# mount /home/
mount.nfs: Protocol error

No errors in dmesg, please let me know if it's a known problem or what
other info could be of use.
