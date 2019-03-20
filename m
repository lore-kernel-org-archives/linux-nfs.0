Return-Path: <SRS0=avcE=RX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05EFEC43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Mar 2019 03:03:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C478020857
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Mar 2019 03:03:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CYJRlUTW"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726896AbfCTDDG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Mar 2019 23:03:06 -0400
Received: from mail-ua1-f45.google.com ([209.85.222.45]:44885 "EHLO
        mail-ua1-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726823AbfCTDDF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Mar 2019 23:03:05 -0400
Received: by mail-ua1-f45.google.com with SMTP id r21so301735uan.11
        for <linux-nfs@vger.kernel.org>; Tue, 19 Mar 2019 20:03:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=IqWYpiIzNRv/8P0ZCxfKW+kReV4FKV5o+ul3AqlT4lc=;
        b=CYJRlUTWWs0P2nvQix097X5DRKZwhIDEQ64OpxdlhvKrZBhTsYW6ppFHfEGHQmzjb6
         VfNMM6sPn6feUIRRAlPiTR128i3HkBmlfesSw/r15K7hKAZH6W5JvAenCjTHw55IxONv
         qYIojp90aSgv9mMnEAWGLE07+CnZwbzC2BMVmfHhUhtyjc6eN2UqWFzjriIgmg75bm6O
         MzOd9RV61519kA9ElPmAQr4YaS+tkdwq365QNTAZZ8TIquGoI4cWO/17CBTfxX9JUSW2
         url4CBIWCol/1as+tpAEMFFj2fn+06+wyXp2hKMegJcV77rtxMs6Ulgrol8kn2+mlsiA
         JOPQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
        bh=IqWYpiIzNRv/8P0ZCxfKW+kReV4FKV5o+ul3AqlT4lc=;
        b=OlsC587l2c/+YxXqMtobw2Nw5ru4NJAZzmJepl/LkNnLBMl4JXP8KtQCsfkp/ht22v
         u1aHw+p1/Yk6XYnq53B2wOlxas1vQAAEl34mx+Sqk1wKtqVAVpoKNRQ75YNehQNswAeo
         m+3xjIqXMt1/7WR0CV0dUGxbji5ihWypKFHDnSys8MsrIU+gAhOGuz/tqNkFlYUdT6E6
         MlGa3DVfXx3uPGTEhl8b0cxe5Rc5zD165AeS8uypiNoNlyeo03WaGg+DnKGhwo7HpK50
         ngXVb107bXYHVGDGslEupWpqcxzTgQdb+sqWa/TltIKRirMNdNTXNBGBsd+MYmU7ijAr
         Gt9w==
X-Gm-Message-State: APjAAAVKKVGCM3c/7EQuteEA9XYj+l1U40x1s+OPrBZ0AgVntLXfuPyi
        XDRmASM3v9AlR22crfMKwlsNfhaeoT/nT+4JmPfJvgqN
X-Google-Smtp-Source: APXvYqznlJ6kVMQ4EX1mmM7Ys7zn3rRsKKfn3deq/P+wuo5fwhWE6vi20XFMw/gBjBp7s08yXwE2OcOc/Soi7UMYhcM=
X-Received: by 2002:ab0:6144:: with SMTP id w4mr3111022uan.135.1553050984757;
 Tue, 19 Mar 2019 20:03:04 -0700 (PDT)
MIME-Version: 1.0
From:   Marvin Zhang <fanzier@gmail.com>
Date:   Wed, 20 Mar 2019 11:02:49 +0800
Message-ID: <CA+5eE-TWSOGs+7wJnykbwD84iTuXStgmsprxbXdf27ciHMg2Ng@mail.gmail.com>
Subject: Some questions about Trunking
To:     linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Experts,
Here are some questions about trunking:
1.  For session trunking. During first mount(or first connection),
client create a session. During the second mount(or second
connection), client will reuse the session which the first connection
created. Does the second mount create a new super block or reuse the
previous? If there is a READ request on this session, how to judge to
use which connection?
2. For client id truking. As protocol said, client can create multipl
session at the same time. I can't understand in which scenario client
can create multiple session

Thanks,
Marvin
