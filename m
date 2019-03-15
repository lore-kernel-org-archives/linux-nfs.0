Return-Path: <SRS0=RY80=RS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 724AAC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 19:08:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 344C92064A
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 19:08:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=netronome-com.20150623.gappssmtp.com header.i=@netronome-com.20150623.gappssmtp.com header.b="sOETxq3M"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726316AbfCOTIU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Mar 2019 15:08:20 -0400
Received: from mail-qt1-f196.google.com ([209.85.160.196]:38572 "EHLO
        mail-qt1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726264AbfCOTIU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Mar 2019 15:08:20 -0400
Received: by mail-qt1-f196.google.com with SMTP id s1so11331219qte.5
        for <linux-nfs@vger.kernel.org>; Fri, 15 Mar 2019 12:08:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=netronome-com.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:in-reply-to:references
         :organization:mime-version:content-transfer-encoding;
        bh=+KH52aqOlUV7ydonSPUf5d+nbWRVOsOarhzPp36leGg=;
        b=sOETxq3M20zXvkUjyd3nj1hfWxxiTKmNSNxyMYI1RIuY3SISvuO5fR4aIa6lIlpd0i
         Qp9U2hByxrFQSCDXfD19fZQfglatYGiYpqrBwbP/NCsmixT4u3pZeVC3o4THzWdN8eZ0
         u1zy1k6/JCxt5T/ADtrNQWkgXDaOr1Wlf9JO1gg0M92+jdFkVOJl4p8zi5TZg8m4nxk2
         ObH8BICmumFnstkIoXpRfy4j1x4lTwppImW7WfXnzFgKh16lMjjR8Mf99MQr7corR/Ds
         sKNtT8g+A8Vi5cSAvd7Qbg2ccFqWq70GgzlrQ0YzalH4pL2b7qxwx26D5gdEOIE/lN7G
         w3Iw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:in-reply-to
         :references:organization:mime-version:content-transfer-encoding;
        bh=+KH52aqOlUV7ydonSPUf5d+nbWRVOsOarhzPp36leGg=;
        b=lOvHfRF9N3J1H5pO4fSAyVY74hdwraYpEJbO42EdePKEiPYQwMSIeU9il+peBnMLWE
         uTIiAMH+vqikhrd9ApTUt/TL5kgOcMlfDlD+0txxyiQvnXnaIpvVfXm4fm2fLAeO2R3N
         Ws/epY04jxLuUAKXrzalwRuGJ+zL4udXqAMiety/Vb2V1Gb7di7riodEgir0hVB1qo7J
         0xJ8CZH0zvtt0T7Crd0hV0/ESmIBR/V8m74MGRUWhKWTqEyoK0GzGcaCycwQ8R0qKnuX
         is4rtDyFGAQQxZgbP328luj4Y6PefP7QzaLqRrOI1SIeviMbR32DRlGrhDPyZgEWwU33
         lbjQ==
X-Gm-Message-State: APjAAAW/kXR95tsK0s4RAPyAvN7m27LbKo75wrGndkMAhBHEKAoRty+/
        EWLGSQFIEEpzLrANOAa36VQngA==
X-Google-Smtp-Source: APXvYqyOEXfEgShBDRZ6vCfunmQBUPzwtZfL85pcpBVlqsuMeCdPMozDXXbII/yhxBLJjX+7W1Q3nA==
X-Received: by 2002:ac8:764a:: with SMTP id i10mr4117016qtr.142.1552676899594;
        Fri, 15 Mar 2019 12:08:19 -0700 (PDT)
Received: from cakuba.netronome.com ([66.60.152.14])
        by smtp.gmail.com with ESMTPSA id r58sm2030285qtr.24.2019.03.15.12.08.18
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Mar 2019 12:08:19 -0700 (PDT)
Date:   Fri, 15 Mar 2019 12:08:15 -0700
From:   Jakub Kicinski <jakub.kicinski@netronome.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: mount.nfs: Protocol error after upgrade to linux/master
Message-ID: <20190315120815.543f4cd0@cakuba.netronome.com>
In-Reply-To: <f74ac3d790748542914ca545a88d34e7cb644f33.camel@hammerspace.com>
References: <20190315110555.0807d015@cakuba.netronome.com>
        <f74ac3d790748542914ca545a88d34e7cb644f33.camel@hammerspace.com>
Organization: Netronome Systems, Ltd.
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 15 Mar 2019 18:41:20 +0000, Trond Myklebust wrote:
> On Fri, 2019-03-15 at 11:05 -0700, Jakub Kicinski wrote:
> > Hi,
> > 
> > I just upgraded from:
> > 
> > commit a3b1933d34d5bb26d7503752e3528315a9e28339 (net)
> > Merge: c6873d18cb4a 24319258660a
> > Author: David S. Miller <davem@davemloft.net>
> > Date:   Mon Mar 11 16:22:49 2019 -0700
> > 
> > to
> > 
> > commit 3b319ee220a8795406852a897299dbdfc1b09911
> > Merge: 9352ca585b2a b6e88119f1ed
> > Author: Linus Torvalds <torvalds@linux-foundation.org>
> > Date:   Thu Mar 14 10:48:14 2019 -0700
> > 
> > and I'm seeing:
> > 
> > # mount /home/
> > mount.nfs: Protocol error
> > 
> > No errors in dmesg, please let me know if it's a known problem or
> > what
> > other info could be of use.  
> 
> It sounds like the exact same problem that Marc Dionne reported seeing.
> Can you also try the patch at 
> http://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=patch;h=513149607d19bc3821386fb5ac75f8b99fd4b115
> ?

Sorry, I didn't see your reply, trying now..
