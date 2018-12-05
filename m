Return-Path: <SRS0=3CSe=OO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D913DC04EB9
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 13:12:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A9C792084C
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 13:12:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9C792084C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mba.ocn.ne.jp
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727398AbeLENL4 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 5 Dec 2018 08:11:56 -0500
Received: from mfdf018.ocn.ad.jp ([153.128.50.74]:56318 "EHLO
        mfdf018.ocn.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726918AbeLENL4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Dec 2018 08:11:56 -0500
Received: from mogw1832.ocn.ad.jp (mogw1832.ocn.ad.jp [153.138.214.98])
        by mfdf018.ocn.ad.jp (Postfix) with ESMTP id C83A7B94A48;
        Wed,  5 Dec 2018 22:11:53 +0900 (JST)
Received: from mf-smf-unw005c2 (mf-smf-unw005c2.ocn.ad.jp [153.138.219.79])
        by mogw1832.ocn.ad.jp (Postfix) with ESMTP id ECA234A043F;
        Wed,  5 Dec 2018 22:11:50 +0900 (JST)
Received: from ocn-vc-mts-201c1.ocn.ad.jp ([153.138.219.212])
        by mf-smf-unw005c2 with ESMTP
        id UWvBgKrs3017KUWxygZjK0; Wed, 05 Dec 2018 22:11:50 +0900
Received: from smtp.ocn.ne.jp ([153.149.227.167])
        by ocn-vc-mts-201c1.ocn.ad.jp with ESMTP
        id UWxygUhJ963EtUWxygCBiS; Wed, 05 Dec 2018 22:11:50 +0900
Received: from localhost (p935071-ipngn2102funabasi.chiba.ocn.ne.jp [180.56.175.71])
        by smtp.ocn.ne.jp (Postfix) with ESMTPA;
        Wed,  5 Dec 2018 22:11:50 +0900 (JST)
Date:   Wed, 05 Dec 2018 22:11:46 +0900 (JST)
Message-Id: <20181205.221146.969453990167463340.anemo@mba.ocn.ne.jp>
To:     geert@linux-m68k.org
Cc:     trond.myklebust@hammerspace.com, linux-nfs@vger.kernel.org,
        linux-mips@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: NFS/TCP crashes on MIPS/RBTX4927 in v4.20-rcX (bisected)
From:   Atsushi Nemoto <anemo@mba.ocn.ne.jp>
In-Reply-To: <CAMuHMdVJr0PwvJg3FeTCy7vxuyY1=S1tPLHO7hPsoZX4wZ+-cQ@mail.gmail.com>
References: <CAMuHMdVJr0PwvJg3FeTCy7vxuyY1=S1tPLHO7hPsoZX4wZ+-cQ@mail.gmail.com>
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

Hi Geert,

On Tue, 4 Dec 2018 14:53:07 +0100, Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> I found similar crashes in a report from 2006, but of course the code
> has changed too much to apply the solution proposed there
> (https://www.linux-mips.org/archives/linux-mips/2006-09/msg00169.html).
> 
> Userland is Debian 8 (the last release supporting "old" MIPS).
> My kernel is based on v4.20.0-rc5, but the issue happens with v4.20-rc1,
> too.
> 
> However, I noticed it works in v4.19! Hence I've bisected this, to commit
> 277e4ab7d530bf28 ("SUNRPC: Simplify TCP receive code by switching to using
> iterators").
> 
> Dropping the ",tcp" part from the nfsroot parameter also fixes the issue.
> 
> Given RBTX4926 is little endian, just like my arm/arm64 boards, it's probably
> not an endianness issue.  Sparse didn't show anything suspicious before/after
> the guilty commit.
> 
> Do you have a clue?

If it was a cache issue, disabling i-cache or d-cache completely might
help understanding the problem.  I added TXx9 specific "icdisable" and
"dcdisable" kernel options for debugging long ago.

I hope these options still works correctly with recent kernel but not
sure.

Also, disabling i-cache makes your board VERY slow, of course.

---
Atsushi Nemoto
