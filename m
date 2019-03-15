Return-Path: <SRS0=RY80=RS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F256BC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 23:54:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AFBE62085A
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 23:54:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=netronome-com.20150623.gappssmtp.com header.i=@netronome-com.20150623.gappssmtp.com header.b="nCqkPlzE"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726638AbfCOXyq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Mar 2019 19:54:46 -0400
Received: from mail-qt1-f195.google.com ([209.85.160.195]:39543 "EHLO
        mail-qt1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726649AbfCOXyq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Mar 2019 19:54:46 -0400
Received: by mail-qt1-f195.google.com with SMTP id t28so12085242qte.6
        for <linux-nfs@vger.kernel.org>; Fri, 15 Mar 2019 16:54:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=netronome-com.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:in-reply-to:references
         :organization:mime-version:content-transfer-encoding;
        bh=E2oPwu0uChxLcTW+K0yevO2Uaes7IFkIteTpMVOUInA=;
        b=nCqkPlzEhyio7Evi1Eo2TlK/YHOClDlwXv+6932UMa8SBD1IjVIUi9kEbSqULicdgO
         m17GUXsogojNViBHEh3SYFToMfAnGNcl/VAsHWHY3KCPJKtF0VmkNnNYb1wYnZkIg9qq
         //lUH4HKEB5HYC3xS14nip/0LgIfiFkfr8t6fkMiX9QU7uxYBk8miTAxgZsY02SuOruc
         9lxqM0tstai5l7xfeL4ClCckzS5iaQayEgMuoB7RRxG3x5GJ1Vg0dwrDLOwyPA7oILfM
         TheRxPnankP298Nef5J0qXlpaOAyIsijmUKsVorK9ZPZTdYC3sJlHHJrr98qgYUnbz56
         0iSA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:in-reply-to
         :references:organization:mime-version:content-transfer-encoding;
        bh=E2oPwu0uChxLcTW+K0yevO2Uaes7IFkIteTpMVOUInA=;
        b=aPT81V/Vt9acs3jADbfeJwkHWk8w9LE2vXC7ZI09hdHDLmYRUTCQKGaHrSk6LmaOdg
         7HQmbQwj/X9iXue7YgnLUIgqVlFA30sqZWZZ4LjOqsBFslUY9ZNE+lMDeQLwu8/oJw1N
         MN9dYX6tgdU1NV5ZrU3id52SJ4eaCgADtHE+FdjKyiKt30QXRrTY3eWvy3tg4wvLXdwP
         AnflMy7DvKBfJCoRuWVo15DRUTrlspeHunEMgMaXecFsFVbGRjtgLNYWIDP1JAWVGi1R
         v1cy7/rtPLMDdxKguN6oQEea1QTErnmG0kV7CPQjvxULjoRY6+gCMCxtCplUc2Wvold9
         7yVg==
X-Gm-Message-State: APjAAAWLwEMFxl3B0oM65vIoZZltbf5Olx4GTEAUr+81Dodea7st2GB1
        Sba5JITLEWI8r7wWHPzuN50ULw==
X-Google-Smtp-Source: APXvYqz87+VhWYVNC9ZQH6C2Pts7V2MbITG+uftilsZefs5+DDZt1s3Sut7bINnzoL9degHnSJwRiA==
X-Received: by 2002:ac8:33dd:: with SMTP id d29mr5220866qtb.320.1552694085478;
        Fri, 15 Mar 2019 16:54:45 -0700 (PDT)
Received: from cakuba.netronome.com ([66.60.152.14])
        by smtp.gmail.com with ESMTPSA id e85sm2028805qkj.58.2019.03.15.16.54.44
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Mar 2019 16:54:45 -0700 (PDT)
Date:   Fri, 15 Mar 2019 16:54:40 -0700
From:   Jakub Kicinski <jakub.kicinski@netronome.com>
To:     Trond Myklebust <trond.myklebust@hammerspace.com>
Cc:     linux-nfs@vger.kernel.org,
        Anna Schumaker <anna.schumaker@netapp.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Kees Cook <keescook@chromium.org>
Subject: Re: mount.nfs: Protocol error after upgrade to linux/master
Message-ID: <20190315165440.53b9db3c@cakuba.netronome.com>
In-Reply-To: <20190315120105.5541ad46@cakuba.netronome.com>
References: <20190315110555.0807d015@cakuba.netronome.com>
        <20190315120105.5541ad46@cakuba.netronome.com>
Organization: Netronome Systems, Ltd.
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 15 Mar 2019 12:01:05 -0700, Jakub Kicinski wrote:
> On Fri, 15 Mar 2019 11:05:55 -0700, Jakub Kicinski wrote:
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
> > No errors in dmesg, please let me know if it's a known problem or what
> > other info could be of use.  
> 
> Hm.. I tried to bisect but reverting to that commit doesn't help.  
> 
> Looks like the server responds with:
> 
>   ICMP parameter problem - octet 22, length 80
> 
> pointing at some IP options (type 134)...

Okay, figured it out, it's the commit 13e735c0e953 ("LSM: Introduce
CONFIG_LSM") and all the related changes in security/

I did olddefconfig and it changed my security module from apparmor to
smack silently.  smack must be slapping those IP options on by default.

Pretty awful user experience, and a non-zero chance that users who
upgrade their kernels will miss this and end up with the wrong security
module...
