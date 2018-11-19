Return-Path: <SRS0=xyvj=N6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 249B4C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 18:08:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D960C20671
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 18:08:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="Xcuwa5DY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D960C20671
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=umich.edu
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729984AbeKTEdR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 19 Nov 2018 23:33:17 -0500
Received: from mail-vs1-f66.google.com ([209.85.217.66]:38387 "EHLO
        mail-vs1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729974AbeKTEdQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Nov 2018 23:33:16 -0500
Received: by mail-vs1-f66.google.com with SMTP id x64so18322011vsa.5;
        Mon, 19 Nov 2018 10:08:40 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=GZMmMKEjwY5jeFneFMwjgKXMewDwl8eNhTmQn30VA3g=;
        b=Xcuwa5DYA7zHAGzPwFFrU/u6kBu7b/p9eWsVLhY3k2mlbsmaPbNdUfJOQDszbZxduP
         pAM5N7qKc+SNNCVZyEnyaIH3Zr/Q+xWKy8Wh1T/vfzBcYskGYYltCLupVCM1O6C14Zk2
         yhdznRui4h+YsuiJjlYrRb8xTshSeHdYDQX8ZLLNqykyaO73MrmOqgVF88+OMBsth4ne
         Igdnrb9wpEh1yzzexUS2H7ViNFasbYDeQ+0xONt7FrkqZcC9oB5dMyZThYq7IBhxLfNp
         wpl0FHukLx01uYMEz76OGeu0aVnMvP6jj1z8hTdXD4QJk5Ya0YFB8FKP+tQjPj8qBDrl
         125g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=GZMmMKEjwY5jeFneFMwjgKXMewDwl8eNhTmQn30VA3g=;
        b=tSa5TAzP6OygQrxOyCg3MA5MLsRXgW/MTcG7hXL5ZF3EoUQUqZ+KZ1cPfNzWw2cdmX
         uy/RjhSfRhkwvMxK9DZrm2yJJ5+qiHgZ1CKHPeZ4cZF0brjuAR1OgiLWlMNpbypARtuI
         xfdHSCCVuz68Q56rSKJnHROfshaBQZmVv/xeiDbRJRP+xEbs8Il/9gEeulogY38diXuT
         XNQ9AkELPuVcCCmTLTxmjFtcPmzLCULH7dTbdk35+fcZiyfC1Thx8tGOEJlois1vcAke
         9w7qTelLmFvL00v72PYeYJNOuJ7YheQ7cUQ7w1jb0+eISZ0Vivi8ga5fJ/M+FTaXAp9N
         r+uw==
X-Gm-Message-State: AGRZ1gIAP6NmlU4NYNF85kuUreQNzEBkrRYejnqW4xhSTtjkEEqTCYb9
        81kAaBNjOi02EZtakOpq8w1guEi601VF3E8JPaQ=
X-Google-Smtp-Source: AJdET5cxIiMFtCtHjuD0B4Dnsu6YMXHq4M9/sN2aj7R82IFe9FN81uxN7qfpRMHS6XmbWPbWk3rMnJMvrZjYYAcmToc=
X-Received: by 2002:a67:f453:: with SMTP id r19mr9810660vsn.164.1542650919476;
 Mon, 19 Nov 2018 10:08:39 -0800 (PST)
MIME-Version: 1.0
References: <20181119153707.10832.42881.stgit@manet.1015granger.net>
 <20181119154607.10832.92558.stgit@manet.1015granger.net> <CAN-5tyG26W+TjTsjpTVvF3RJOGCnD8L79dCbRqKTm5F1V3fuxw@mail.gmail.com>
 <6592845E-0136-4D42-8426-3E2A0BB5FFE7@oracle.com>
In-Reply-To: <6592845E-0136-4D42-8426-3E2A0BB5FFE7@oracle.com>
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Mon, 19 Nov 2018 13:08:27 -0500
Message-ID: <CAN-5tyEw5iRaA6mCp5DeNv1DMkFGAqtvq1PcRSiFZ6PQyJpDUA@mail.gmail.com>
Subject: Re: [PATCH v1 4/4] xprtrdma: Plant XID in on-the-wire RDMA offset (FRWR)
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-rdma <linux-rdma@vger.kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Nov 19, 2018 at 12:59 PM Chuck Lever <chuck.lever@oracle.com> wrote:
>
>
>
> > On Nov 19, 2018, at 12:47 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> >
> > On Mon, Nov 19, 2018 at 10:46 AM Chuck Lever <chuck.lever@oracle.com> wrote:
> >>
> >> Place the associated RPC transaction's XID in the upper 32 bits of
> >> each RDMA segment's rdma_offset field. These bits are currently
> >> always zero.
> >>
> >> There are two reasons to do this:
> >>
> >> - The R_key only has 8 bits that are different from registration to
> >>  registration. The XID adds more uniqueness to each RDMA segment to
> >>  reduce the likelihood of a software bug on the server reading from
> >>  or writing into memory it's not supposed to.
> >>
> >> - On-the-wire RDMA Read and Write operations do not otherwise carry
> >>  any identifier that matches them up to an RPC. The XID in the
> >>  upper 32 bits will act as an eye-catcher in network captures.
> >
> > Is this just an "eye-catcher" or do you have plans to use it in
> > wireshark? If the latter, then can we really do that? while a linux
> > implementation may do that, other (or even possibly future linux)
> > implementation might not do this. Can we justify changing the
> > wireshark logic for it?
>
> No plans to change the wireshark RPC-over-RDMA dissector.
> That would only be a valid thing to do if adding the XID
> were made part of the RPC-over-RDMA protocol via an RFC.

Agreed. Can you also help me understand the proposal (as I'm still
trying to figure why it is useful).

You are proposing to modify the RDMA segments's RDMA offset field (I
see top 6bits are indeed always 0). I don't see how adding that helps
an RDMA read/write message which does not have an "offset" field in it
be matched to a particular RPC. I don't believe we have (had) any
issues matching the initial RC Send only that contains the RDMA_MSG to
the RPC.

>
>
> --
> Chuck Lever
>
>
>
