Return-Path: <SRS0=saDi=QU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95A31C282C2
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Feb 2019 06:10:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 59934222BE
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Feb 2019 06:10:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="MJdK1aId"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731744AbfBMGKk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 13 Feb 2019 01:10:40 -0500
Received: from mail-qk1-f196.google.com ([209.85.222.196]:36104 "EHLO
        mail-qk1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730865AbfBMGKk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Feb 2019 01:10:40 -0500
Received: by mail-qk1-f196.google.com with SMTP id o125so711987qkf.3
        for <linux-nfs@vger.kernel.org>; Tue, 12 Feb 2019 22:10:39 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=QFVcv2o1pYPqf6P2wQxw0Spij/6T3IEiLH5GiYn8k10=;
        b=MJdK1aIdz1ydAcPn5IhB/SsAf0Yafr6uo6FPVMLWoMY/+1xVWAlXmaB2HLhCEgjr/Y
         YReBRCwH51Gj7w7Rgnru0ZS4WxoYOkAhUZX4fS/BidHau1TJs0T99r7xnus8Nso4Kjc3
         7oxZaapdLeBaiTwBrW/c4nOzKa485cR9KHvBCFZxeDrTSzfaZ2Llx3u9xLDfc+T7yl4r
         +cO+2FofADSP4CQ3s6wzQRnCazyWc2seccohR63APkKLvjSal+VQChnPdkrUZ3B5KLtr
         hW3JdPAW5sl+E+pC/3fjF3dszDvPZT/+6AoJdwn4U+/nts4o4EQMnNUgO2Jm4NdIHHd+
         BpMQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=QFVcv2o1pYPqf6P2wQxw0Spij/6T3IEiLH5GiYn8k10=;
        b=e3tMjQrE5xkZUvPz3mOq9M73LcV9jVdgrUZlzE5TmRpOtT/Ho5R/sDHNDjmsarWPRv
         3jXfO2oWTiiiSXE0P1mJNRJyp/Wlzb1Qxs2Mvmjgwcwl8ffA3dzybOPqZmxazq1wT52t
         cYyFLxV4Y9qSUQF3IuBdzM3cO6vW8ImT9i/7kIkwmag90lbGzd4vbsIdKl2ohvIIC1DL
         oeccYJ74GrlSrQUkJJvdWCVKlQFaaUwmIcEBjPYTg+lZ4Tm/kMsR+a6po0B7jjPcS0mP
         xjCZ9jdyK7Hrs9MxgbKZXmw48jN4O9NKm6MtJBT3BfZeWC4iVOsmRcl2QeHLwgMK+kM9
         MZUg==
X-Gm-Message-State: AHQUAuYQCTosSxXufY93vwyetZ+Yn4E0N2yzCoLBaVlxnEWufheXMg2q
        PmsGMrUasnr+AC0+fMWQ2gdEPAVepFpFmak/bO4455h4
X-Google-Smtp-Source: AHgI3IbNeT8TgGIyh6+Kmu6bJdqr8ce+X+2DebmwiIM/FSPjVHXUP0BFWJEkgwXeBJ27RefhmzJSlie4liqO2daC9zI=
X-Received: by 2002:a37:52d6:: with SMTP id g205mr5389717qkb.335.1550038239450;
 Tue, 12 Feb 2019 22:10:39 -0800 (PST)
MIME-Version: 1.0
References: <20190212162157.GA27459@sh-el5.eng.rdu2.redhat.com> <20190212194413.GC3471@kroah.com>
In-Reply-To: <20190212194413.GC3471@kroah.com>
From:   Murphy Zhou <jencce.kernel@gmail.com>
Date:   Wed, 13 Feb 2019 14:10:27 +0800
Message-ID: <CADJHv_uoAt70K1_za_y5-Vd17MidLfUKj-qH8OmenEMTzZVnsQ@mail.gmail.com>
Subject: Re: [v5.0-rc3 regression] Oops when starting nfs service
To:     Greg KH <gregkh@linuxfoundation.org>
Cc:     linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Greg,You patch fixed my issue. Thanks!
On Wed, Feb 13, 2019 at 3:44 AM Greg KH <gregkh@linuxfoundation.org> wrote:
>
> On Tue, Feb 12, 2019 at 11:21:57AM -0500, Murphy Zhou wrote:
> > Hi,
> >
> > Starting nfs-server service can crash the kernel since
> > commit ff9fb72bc07705c00795ca48631f7fffe24d2c6b
> > Author: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > Date:   Wed Jan 23 11:28:14 2019 +0100
> >
> >     debugfs: return error values, not NULL
> >
> > # git describe ff9fb72bc07705c00795ca48631f7fffe24d2c6b
> > v5.0-rc2-3-gff9fb72bc077
> >
>
> Be careful with 'git describe', you showed what I applied that patch
> against, not what release it showed up in.
>
> This really showed up in 5.0-rc6:
>
> $ git describe --contains ff9fb72bc07705c00795ca48631f7fffe24d2c6b
> v5.0-rc6~21^2~3

Ya! Thanks very much for the tip! I forgot about this, so it should be a
rc6 regression. :)

-Murphy

>
> thanks,
>
> greg k-h
