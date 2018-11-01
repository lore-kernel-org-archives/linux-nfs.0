Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0352C6786F
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 20:30:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A7EA0205F4
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 20:30:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rdg2BwNA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A7EA0205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727806AbeKBFfN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 2 Nov 2018 01:35:13 -0400
Received: from mail-vs1-f66.google.com ([209.85.217.66]:35485 "EHLO
        mail-vs1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727429AbeKBFfN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Nov 2018 01:35:13 -0400
Received: by mail-vs1-f66.google.com with SMTP id d62so11227739vsd.2
        for <linux-nfs@vger.kernel.org>; Thu, 01 Nov 2018 13:30:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=z5iFG/MU3Re+L4/A0ujLGeH5RuLgMBC16ZXJkYXiP94=;
        b=rdg2BwNAODWOW47tLDhLNDomgl8KRPf1qnc7TWJ6rvm0GVNzc08E3L1TgSi7Biv5Qj
         LT5OnvchTrALI7IG1v1bIqTP4r6eKJcI7uHQEwPNZFkm2Vn5kNiyIiGgMYknfN1ltbN8
         cNSj0xoCBannOyHFA1EaRRgM8gZQB9DVanchklU5HXKLJeBt/e2J/ShbTpku7LIrqfkW
         PV0vrMWLmivZAZ4Gvh6hOphVliJK+vz9VX09uRfM4bBFpshKNUL/vOCLAYHfr1M4eDIl
         0eOrLW5cFzx9LOA6T2CdYVo/BLndyJ6VCEc+soCclWCQtnOUCBWqh/9UsNpSh9/4j2ZS
         /+3g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=z5iFG/MU3Re+L4/A0ujLGeH5RuLgMBC16ZXJkYXiP94=;
        b=b9g6zKINvmNJSyde3l4r05JzPeQRZn4WK0Tbrlg1Rpp+2DSIE5sPlOHS0jakj3SXvK
         UtklhzkkD0r9sjfH1/I4dTtDTQ/B8JgmfevORVvbgpGDlx67u/azHaWMQJeq+Wu24BWC
         bSXAMTzBbtS/5CT2S7MITmAZB6RookJOuTVRdYxLoZrPOeqoxlVybl7Br1N+TZpovnTz
         QIaCZAKYVNzEURck5fRMxDng7jkKq5bEiQUpiBm1Q4/70WA0SXSqYyhnjEXkpO1/+SFl
         qC2/zyHMtzjOuVdawwIwzgvR3Aynf1y0CiNKgmaqED5Xz+wjuwWnksguyDAByywy81QN
         ZPRA==
X-Gm-Message-State: AGRZ1gK3pcvFJ4L2rop5f6C4lAgjyExMKqcmG1FUrXvbU7fWgO4devYZ
        b6WSydyJI0pJWwStADEEURC1xFfC1id6onq2pAO1WQ==
X-Google-Smtp-Source: AJdET5fZbPcwTFeIyIC9sKkGCw9OA2leGZIjSlSeLOusKIotMuZoDHvVM/T169rokBFWAw6PGTNpfjxepJ0RKm4vvnI=
X-Received: by 2002:a67:a858:: with SMTP id r85mr3809008vse.215.1541104241301;
 Thu, 01 Nov 2018 13:30:41 -0700 (PDT)
MIME-Version: 1.0
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181019152905.32418-5-olga.kornievskaia@gmail.com> <20181031184042.GD3377@fieldses.org>
 <CAN-5tyGuVF30ynxYj_EaWDjJJyJTXLXWb=O516XJsThk9AsUvQ@mail.gmail.com> <20181101201257.GA12930@fieldses.org>
In-Reply-To: <20181101201257.GA12930@fieldses.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Thu, 1 Nov 2018 16:30:29 -0400
Message-ID: <CAN-5tyHOL37cmTbFU-eGH6WoaF+1d5M9hWSzpGJp64X9dRAbDQ@mail.gmail.com>
Subject: Re: [PATCH v1 04/13] NFS inter ssc open
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Nov 1, 2018 at 4:13 PM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Wed, Oct 31, 2018 at 02:54:51PM -0400, Olga Kornievskaia wrote:
> > On Wed, Oct 31, 2018 at 2:40 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> > >
> > > Just to pick one thing that I don't understand yet:
> > >
> > > On Fri, Oct 19, 2018 at 11:28:56AM -0400, Olga Kornievskaia wrote:
> > > > +EXPORT_SYMBOL_GPL(nfs42_ssc_open);
> > > > +void nfs42_ssc_close(struct file *filep)
> > > > +{
> > > > +     struct nfs_open_context *ctx = nfs_file_open_context(filep);
> > > > +
> > > > +     ctx->state->flags = 0;
> > >
> > > Why is this needed?
> >
> > This is needed so that CLOSE isn't going on the wire but closed internally.
> >
> > > Also, given the name and the pairing with nfs42_ssc_open(), would it be
> > > more logical for it to do the fput() as well?
> >
> > I'd like to keep that fput() in the nfsd to make it consistent with
> > the "intra". There are fput()s for intra but intra doesn't call into
> > nfs42_ssc_close().
>
> OK, I think.
>
> I'll need an ACK from Trond and/or Anna on this one in any case.

I included the client-side patches only so that you can compile and
run (or at least I tried as later I think I realized that you needed
one more patch. Thus I have asked if you are planning to run just
include all the client-side series). But I have submitted all of them
to be reviewed as client-side patches. Thus they have been reviewed by
Anna (don't know if Trond is looking of not) and some by others
(Jeff).
