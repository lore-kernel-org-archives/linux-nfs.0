Return-Path: <SRS0=0ybF=OQ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 746ECC64EB1
	for <linux-nfs@archiver.kernel.org>; Fri,  7 Dec 2018 14:51:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4539A20989
	for <linux-nfs@archiver.kernel.org>; Fri,  7 Dec 2018 14:51:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4539A20989
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mba.ocn.ne.jp
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726129AbeLGOvw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 7 Dec 2018 09:51:52 -0500
Received: from mfdf022.ocn.ad.jp ([153.128.50.80]:53104 "EHLO
        mfdf022.ocn.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725998AbeLGOvv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Dec 2018 09:51:51 -0500
Received: from mogw0939.ocn.ad.jp (mogw0939.ocn.ad.jp [153.149.227.45])
        by mfdf022.ocn.ad.jp (Postfix) with ESMTP id 19CD522353E;
        Fri,  7 Dec 2018 23:51:50 +0900 (JST)
Received: from mf-smf-unw009c1 (mf-smf-unw009c1.ocn.ad.jp [153.138.219.105])
        by mogw0939.ocn.ad.jp (Postfix) with ESMTP id 3794AD00506;
        Fri,  7 Dec 2018 23:51:48 +0900 (JST)
Received: from ocn-vc-mts-201c1.ocn.ad.jp ([153.138.219.212])
        by mf-smf-unw009c1 with ESMTP
        id VHRhgngCrHkOOVHTogbxLT; Fri, 07 Dec 2018 23:51:48 +0900
Received: from smtp.ocn.ne.jp ([153.149.227.165])
        by ocn-vc-mts-201c1.ocn.ad.jp with ESMTP
        id VHTngelAL63EtVHTngM9yz; Fri, 07 Dec 2018 23:51:48 +0900
Received: from localhost (p935071-ipngn2102funabasi.chiba.ocn.ne.jp [180.56.175.71])
        by smtp.ocn.ne.jp (Postfix) with ESMTPA;
        Fri,  7 Dec 2018 23:51:47 +0900 (JST)
Date:   Fri, 07 Dec 2018 23:51:41 +0900 (JST)
Message-Id: <20181207.235141.2138062629640003368.anemo@mba.ocn.ne.jp>
To:     geert@linux-m68k.org
Cc:     trond.myklebust@hammerspace.com, linux-nfs@vger.kernel.org,
        linux-mips@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: NFS/TCP crashes on MIPS/RBTX4927 in v4.20-rcX (bisected)
From:   Atsushi Nemoto <anemo@mba.ocn.ne.jp>
In-Reply-To: <CAMuHMdU9zXXSaPHKvfG3A73h3CTsb9H2RT_gWt-Ne=qQ+HKShQ@mail.gmail.com>
References: <CAMuHMdVJr0PwvJg3FeTCy7vxuyY1=S1tPLHO7hPsoZX4wZ+-cQ@mail.gmail.com>
        <20181205.221146.969453990167463340.anemo@mba.ocn.ne.jp>
        <CAMuHMdU9zXXSaPHKvfG3A73h3CTsb9H2RT_gWt-Ne=qQ+HKShQ@mail.gmail.com>
X-Fingerprint: 6ACA 1623 39BD 9A94 9B1A  B746 CA77 FE94 2874 D52F
X-Pgp-Public-Key: http://wwwkeys.pgp.net:11371/pks/lookup?op=get&search=0x2874D52F
X-Mailer: Mew version 6.7 on Emacs 24.5 / Mule 6.0 (HANACHIRUSATO)
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, 5 Dec 2018 14:41:30 +0100, Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> When using these options, I do see a slowdown in early boot, but the issue
> is still there.

Hmm, the NIC of the board is NE2000 variants, so DMA coherency will
not be an issue anyway.  So strange ...

The board has a PCI slot.  If you had an legacy PCI NIC card, trying
with it might help finding the bug.

> My next guess is an unaligned access not using {get,put}_unaligned(), which
> doesn't seem to work on tx4927, but doesn't cause an exception neither.

IIRC, TX49 can raise an exception on unaligned access.

---
Atsushi Nemoto
