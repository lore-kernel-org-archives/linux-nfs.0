Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E503C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 21:46:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3D0E22080D
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 21:46:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gBIKvJXU"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728528AbeLSVqV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 16:46:21 -0500
Received: from mail-oi1-f173.google.com ([209.85.167.173]:40715 "EHLO
        mail-oi1-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727079AbeLSVqV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2018 16:46:21 -0500
Received: by mail-oi1-f173.google.com with SMTP id t204so2870206oie.7
        for <linux-nfs@vger.kernel.org>; Wed, 19 Dec 2018 13:46:20 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=MOfkjIDaoyHn4ma5t9/fkGCm3Dyh4teYMaOAWPoKDo8=;
        b=gBIKvJXUfTTd6Jgy3Cb79gn6Kt/A+DN6R9aIHCfZcRuCO4qov9kelyAsf0qLDVEtKZ
         woTGXxaYkcKI52BE326BRya8swTvyg9GlLYh+DiS5Kaa7yJBX+Cnb9zN6G+1dLzyVQ+C
         YAVmFA+I9+ET6MJt9Hq0ifEFxhzVow9C2fdbQpL8CFJIFYI1Cmfeu7s+Xi4+fzs7uuzo
         JglSA6OZvwh+O+P/tF039MF+rxF6jfGFGNI4pUpzHMDm8BvwQxtKYAnLzz6XVtN7X8In
         pLNxBjTm8Y2J4ZEz1yIOtt0llLlvjr+Y6YFNAVPs0zgC6I8k1hmZBIzz1ZQ3iS7LMDLx
         8Hbg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
        bh=MOfkjIDaoyHn4ma5t9/fkGCm3Dyh4teYMaOAWPoKDo8=;
        b=eeUhbtL5URfeLE99d47pccXuzVglI9I/SU/TX9+gbg77JNywjIyrn0N0RdyS5d+qIx
         +GKM5czhNQGgRKwruKyrJTFL5IVzEbNQkAf7R6t8ddULdJAW5YUjFp3du/QpMo8xv5+H
         l9Bt0408YW52TD5i6JlZWf+0vnSWxTvdhKqFH4rSalfj4L5kZRTibpM+jiKvYUOAlWIG
         If8THBVqXXFUdjPgleot/bsLgJP0Ecl68c8xqCIlf15QgeE1w7HIFNjferblHS+rw5zJ
         ZRaXptKidkOOTqprZp1KIU8us6aFQon+nJT8LWeEmq+hOwtz6fHQigPf+v7MT3Udy9RA
         OURQ==
X-Gm-Message-State: AA+aEWYNSmuZZ4oNlZAkRQyEYDiso+6XfqSU8KKJnCku6XLJ+KmlxOSh
        XVxHruk/JTl/ZMf5BWo7K5KhGUubLUnrCqVNvoZ1Nw==
X-Google-Smtp-Source: AFSGD/VwMNgq2RQmq21t2URgRRx58Ibg8RU4jABARjBZ5XupHowXTcHaj0rS8RTT/YpusfJTTaG/EMc0Nv3hP6jUMg4=
X-Received: by 2002:aca:e183:: with SMTP id y125mr384246oig.184.1545255980304;
 Wed, 19 Dec 2018 13:46:20 -0800 (PST)
MIME-Version: 1.0
From:   james harvey <jamespharvey20@gmail.com>
Date:   Wed, 19 Dec 2018 16:46:09 -0500
Message-ID: <CA+X5Wn50FLeaAko-Qt6JJXwqhtgp5WfM+COtX=gMgSrPMXFuyw@mail.gmail.com>
Subject: Keep file data off network when moving between filesystems on the
 same server
To:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Using NFS v4.2 on Arch, nfs-utils 2.3.3, linux 4.18.16.

If a server has multiple nfs exports on different filesystems, and a
client moves a file from one of these exports to another, the file
contents transmit across the network.

If the file contents were kept on the server, there would be a great
speed boost.  (Assuming the network speed is less than the server disk
I/O speed.)

Apologies if this is one of those things that sounds easy and has been
asked a lot but rejected.
