Return-Path: <SRS0=qWmq=XI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	PDS_TONAME_EQ_TOLOCAL_SHORT,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6F3FC49ED7
	for <linux-nfs@archiver.kernel.org>; Fri, 13 Sep 2019 15:14:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6E87520640
	for <linux-nfs@archiver.kernel.org>; Fri, 13 Sep 2019 15:14:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="PQ7TJqWe"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2403865AbfIMPOn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 13 Sep 2019 11:14:43 -0400
Received: from mail-vs1-f45.google.com ([209.85.217.45]:37329 "EHLO
        mail-vs1-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2403864AbfIMPOm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Sep 2019 11:14:42 -0400
Received: by mail-vs1-f45.google.com with SMTP id p13so3637927vsr.4
        for <linux-nfs@vger.kernel.org>; Fri, 13 Sep 2019 08:14:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:from:date:message-id:subject:to;
        bh=caVgHwPz6zu5lUgJ3keIDX993JwbWdRWxshINVBJmwM=;
        b=PQ7TJqWe7HsF7/Us0f8XEF0wJA6NFv4UEc/y+jtntl15EMvRtb/Ym+o/QWsTPMo/H1
         pmrAsGxWZARbjkg7c/9yf7k/Kt/exu+GTPnHxLd/mCXI2Q6+sxDS86fLeoTzn6FEEM+P
         cGm0mqQ3DEhiN8VAr0LySk9NLu0DhWKy2Cl1rix4X7eoEwqW0igxosGJVrhqe3TCtNqh
         hxzg306hXhWX64EeJTXsPre6fyxJHzv/gQy7GlfdV3BxVGqb06J//yKA4uUB7lQWtSi/
         pFzLk/kvwNZi9/djs1CSqI4kBhBqUm1bfXmYQ9Ag3sF/6vU2qdvNbq8q1yslPg8ibtcz
         iEfw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
        bh=caVgHwPz6zu5lUgJ3keIDX993JwbWdRWxshINVBJmwM=;
        b=NZwxFf43djhaTKPEZYQRbfgEg20Kuc8pYRIFuIwUIp4BFTmoWHOYwLsf0yJ3AEI0m/
         vnjD0I9EKtMXy9VFuwb11DOzwMKHHFH6PyAsJ8+4FZ11MmfJ8sTpezAyI4xzaiwFPyQe
         o0aCPlIOt5iUIysIb6Un2HcIeNHwZRNkt3lv4boFxWtf8xwpDIOlzkjUbN/vKeXVD9jL
         MO9Ac00UvQpLvRpeGY9lp2kpM/sHJyTbJPlmeO6bwocCncb5Ym3ojVddUm9Gb21OHo0I
         UKLIAYJYHOPIfkHQZYFoVoIw+xXbafDLqh+jvCrVeT2fRBfw2ltkez6VhKe7fb1E7Jxg
         FpwQ==
X-Gm-Message-State: APjAAAUUvnBCd7mcrUvCr67RHS+Wqww9qkKESZs3/uXRK/8eLbNAWdk7
        lpXoyu5B8mKomho+WCQKcy4CPTpriNx5uCu7+qUxuw==
X-Google-Smtp-Source: APXvYqz+PtwIqYXwY899aaEPt392Je0T2UD9k86ampouhigKN1RmVOinxYo3VhHk9lW+I2ecYX9ct3lGFgJT2Ghm0sw=
X-Received: by 2002:a67:c991:: with SMTP id y17mr11222377vsk.85.1568387681801;
 Fri, 13 Sep 2019 08:14:41 -0700 (PDT)
MIME-Version: 1.0
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Fri, 13 Sep 2019 11:14:31 -0400
Message-ID: <CAN-5tyG97C6GTXOz5G6z8SL+jNKYa0siWnSfjijRNVucFs3KwA@mail.gmail.com>
Subject: support for UDP
To:     linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi folks,

I'd like to gauge what people think. Do you think we'd ever do a bold
thing like drop the UDP support in the upstream kernel (obviously with
a plan to fade it out with a config option that we did with the des
support)...
