Return-Path: <SRS0=saDi=QU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E6E4C282CA
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Feb 2019 11:50:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 095BF222B2
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Feb 2019 11:50:21 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1733182AbfBMLuT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 13 Feb 2019 06:50:19 -0500
Received: from mail-qt1-f174.google.com ([209.85.160.174]:42647 "EHLO
        mail-qt1-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726411AbfBMLuT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Feb 2019 06:50:19 -0500
Received: by mail-qt1-f174.google.com with SMTP id b8so2132269qtr.9
        for <linux-nfs@vger.kernel.org>; Wed, 13 Feb 2019 03:50:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:date:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=FEilIrlN50uu7jpGZXpNgSrBCeNanC8f9UwfcvMMJag=;
        b=c3xlixaJTsqAsvsqSFvkjSne7+ygC0T9X8xPjYcWo5Bs8aXfvoRnfKvXSCNV2on0lf
         9kWxb2WgDP5oKU2dsoOoxK1cLGfGlmMO1QJ2ECw/o8wqKziV6r1Jvn1S234Z0xpML7A7
         nrGAVyrpnm2bL9DOjS9vjbG8xMyu2SKIulivW0DfmUJm8h6E6R0xR9wf94zuvvfM2lFn
         80toWlfbRORrjFx3BuO1nqhIcv+bHEIcacunAIia4ZHTVQWAz2soJvTOziNWkEm4zoAp
         DddQq5JsBxETf7NYPgsRavp91inXshxa2pDRSu3OH2tmMhhGoc1LdBBxRY8CwiUg3Js8
         HMSw==
X-Gm-Message-State: AHQUAuanHgAZdvHU6j8yQuotLRbj/lUN8AVgaDKlraCKFoulBuUkAyXj
        dE/MZNJ9PATuJgdJNnMAUNB0yeytsdE=
X-Google-Smtp-Source: AHgI3IY6PtWijilkPFB9CT0+70QWvnL6iSv4fZN/4jT+c5Uk5WAerX4uk4Z7Zsk4mCYcTNTUklmTeg==
X-Received: by 2002:ac8:601:: with SMTP id d1mr53078qth.155.1550058618081;
        Wed, 13 Feb 2019 03:50:18 -0800 (PST)
Received: from tleilax.poochiereds.net (cpe-2606-A000-1100-DB-0-0-0-C3D.dyn6.twc.com. [2606:a000:1100:db::c3d])
        by smtp.gmail.com with ESMTPSA id t38sm36271477qtc.12.2019.02.13.03.50.17
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Feb 2019 03:50:17 -0800 (PST)
Message-ID: <0bd905c30a652d19404eef82b40f6b92987ca814.camel@redhat.com>
Subject: Re: Why doesn't NFSv3 implement LOOKUPP?
From:   Jeff Layton <jlayton@redhat.com>
To:     Yihao Wu <wuyihao@linux.alibaba.com>, linux-nfs@vger.kernel.org
Date:   Wed, 13 Feb 2019 06:50:16 -0500
In-Reply-To: <3dc67361-9c2f-d183-09e5-0a4d5c48d0f7@linux.alibaba.com>
References: <3dc67361-9c2f-d183-09e5-0a4d5c48d0f7@linux.alibaba.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, 2019-02-13 at 16:41 +0800, Yihao Wu wrote:
> Hi all,
> 
> When looking into "Failures: generic/467" given by xfstests, I found that NFSv3
> didn't implement LOOKUPP. I know that this might be by design. But LOOKUPP was
> meant to replace ".." in NFSv3, right?
> 
> xfstests's generic/467 test case performs the following sequence of operations.
> 
> name_to_handle -> drop_caches -> open_by_handle
> 
> Dentry becomes disconnected due to drop_caches. NFSv3 doesn't support LOOKUPP.
> So when it performs open_by_handle to an directory, this test case fails.
> 
> I did some small experiment by implementing LOOKUPP for NFSv3. The way I tried
> is to merely pass ".." to nfs3_proc_lookup. And it seems to work. At least it's
> a workaround for xfstests.
> 
> I'm curious whether this sort of simulation of LOOKUPP will work or make sense.
> 
> Thanks,
> Yihao Wu

v3 was mostly designed with unix-like clients in mind. For v4, the spec
writers cast a wider net and decided not to put special meaning on
lookups of "." and "..", but they still needed a way to do a lookup of
"..".

The question is why you want to implement LOOKUPP in v3. Mostly we added
it to the client to support reexporting NFSv4 filesystems via NFSv3. Are
you looking to reexport v3 filesystems for some reason?
-- 
Jeff Layton <jlayton@redhat.com>

