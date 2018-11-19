Return-Path: <SRS0=xyvj=N6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC34CC43441
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 18:47:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 791D22075B
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 18:47:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="nheya8dz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 791D22075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=umich.edu
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727565AbeKTFMW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 20 Nov 2018 00:12:22 -0500
Received: from mail-vs1-f68.google.com ([209.85.217.68]:45046 "EHLO
        mail-vs1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726522AbeKTFMW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Nov 2018 00:12:22 -0500
Received: by mail-vs1-f68.google.com with SMTP id g68so18378628vsd.11;
        Mon, 19 Nov 2018 10:47:32 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=DxImvv91kritHvdFXlkoI/Uu5q1ateaM5IfjMrU1HRs=;
        b=nheya8dz+DuvQG57V74se5CwRll8mw8AxbateZB5P3Rvq6MSSO+IRSrvTdemtS0O7Z
         vUWeixW1FrrS/si5cZ0dfO8LzC4fxui/AsuKbGsOLWHQDEigElJOlby0KfcqEITEOKQ8
         PC8Yp5+ycfZoYLyC7JRwhUSCSFj3Odri9tglQrD9F3OyYqQHoe/XBKkZCgmrXlPYSF4u
         nzp7Fy8QbWtvltvx7E9PLr4vCA3f9g+closPOtS+xnaDYggI6lf0h5r/k9qfwLFJpGoe
         BlBo7GpAj6H8Q43uZaTInhpg7IbetWdnkkp3KPAG+o+1/JgOaCuikB4tNTWy4IWjzqGS
         zNfQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=DxImvv91kritHvdFXlkoI/Uu5q1ateaM5IfjMrU1HRs=;
        b=Td7G8y6uF2EG08CZlFstEnjLQ700WZvZzo7z79Yme1IqHm9N685Zk0iELsGwzcrnOG
         ILpkMfIQMuG5Ww/GIPybDAfj+xv0aze3MBC7ThoAV44vzQtYtEaRnQVVcRSyIGIREARe
         vLJEu6rpFz6Ys94XbQ23FNN1pO/z9S3K/U4op1VNucRqC9TdPfzVlpdsT4h6o9srdZzO
         tcmX1MLlxwIRwW6quu6QT/NaSDkPdVDJwrfd3swkJl23HDNvfenS95FBMT5kNUWn60kx
         K8uyP5gIZwilfczoLWdKLhigU9B7BJTpV+bh9YtCgVq64VpZBH95/9m0d/Yk9DXD5BDE
         HWrg==
X-Gm-Message-State: AGRZ1gKZqitn/24XQEHbLKd+oRpfG5GydkkbvSW2m5YSfhJnmILSif4T
        NWNJw+P5WzZqn+0dMK+C/zQcsFzZHvbY0bO4PLU=
X-Google-Smtp-Source: AJdET5dWDg/H0ulxByOehBK5fxAKjh9Tt6i0NYb2gO1AuhDjxJCA/jXLvYqriLD5nSp+zati6B25RPsqP+N/JmZBCAQ=
X-Received: by 2002:a67:4285:: with SMTP id p127mr9651176vsa.134.1542653251540;
 Mon, 19 Nov 2018 10:47:31 -0800 (PST)
MIME-Version: 1.0
References: <20181119153707.10832.42881.stgit@manet.1015granger.net>
 <20181119154607.10832.92558.stgit@manet.1015granger.net> <CAN-5tyG26W+TjTsjpTVvF3RJOGCnD8L79dCbRqKTm5F1V3fuxw@mail.gmail.com>
 <6592845E-0136-4D42-8426-3E2A0BB5FFE7@oracle.com> <CAN-5tyEw5iRaA6mCp5DeNv1DMkFGAqtvq1PcRSiFZ6PQyJpDUA@mail.gmail.com>
 <4A94F1A9-96A4-4A2F-8617-AF0E2380D0C1@oracle.com>
In-Reply-To: <4A94F1A9-96A4-4A2F-8617-AF0E2380D0C1@oracle.com>
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Mon, 19 Nov 2018 13:47:19 -0500
Message-ID: <CAN-5tyGU85PJe4Uoocw5NkT8YiYSF8wTWTgg4HycAgKpyHSfiw@mail.gmail.com>
Subject: Re: [PATCH v1 4/4] xprtrdma: Plant XID in on-the-wire RDMA offset (FRWR)
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-rdma <linux-rdma@vger.kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Nov 19, 2018 at 1:19 PM Chuck Lever <chuck.lever@oracle.com> wrote:
>
>
>
> > On Nov 19, 2018, at 1:08 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> >
> > On Mon, Nov 19, 2018 at 12:59 PM Chuck Lever <chuck.lever@oracle.com> wrote:
> >>
> >>
> >>
> >>> On Nov 19, 2018, at 12:47 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> >>>
> >>> On Mon, Nov 19, 2018 at 10:46 AM Chuck Lever <chuck.lever@oracle.com> wrote:
> >>>>
> >>>> Place the associated RPC transaction's XID in the upper 32 bits of
> >>>> each RDMA segment's rdma_offset field. These bits are currently
> >>>> always zero.
> >>>>
> >>>> There are two reasons to do this:
> >>>>
> >>>> - The R_key only has 8 bits that are different from registration to
> >>>> registration. The XID adds more uniqueness to each RDMA segment to
> >>>> reduce the likelihood of a software bug on the server reading from
> >>>> or writing into memory it's not supposed to.
> >>>>
> >>>> - On-the-wire RDMA Read and Write operations do not otherwise carry
> >>>> any identifier that matches them up to an RPC. The XID in the
> >>>> upper 32 bits will act as an eye-catcher in network captures.
> >>>
> >>> Is this just an "eye-catcher" or do you have plans to use it in
> >>> wireshark? If the latter, then can we really do that? while a linux
> >>> implementation may do that, other (or even possibly future linux)
> >>> implementation might not do this. Can we justify changing the
> >>> wireshark logic for it?
> >>
> >> No plans to change the wireshark RPC-over-RDMA dissector.
> >> That would only be a valid thing to do if adding the XID
> >> were made part of the RPC-over-RDMA protocol via an RFC.
> >
> > Agreed. Can you also help me understand the proposal (as I'm still
> > trying to figure why it is useful).
> >
> > You are proposing to modify the RDMA segments's RDMA offset field (I
> > see top 6bits are indeed always 0). I don't see how adding that helps
> > an RDMA read/write message which does not have an "offset" field in it
> > be matched to a particular RPC. I don't believe we have (had) any
> > issues matching the initial RC Send only that contains the RDMA_MSG to
> > the RPC.
>
> The ULP has access to only the low order 8 bits of the R_key. The
> upper 24 bits are fixed for each MR. So for any given MR, there are
> only 256 unique R_key values. That means the same R_key will appear
> again quickly on the wire.
>
> The 64-bit offset field is set by the ULP, and can be essentially
> any arbitrary value. Most kernel ULPs use the iova of the registered
> memory. We only need the lower 32 bits for that.
>
> The purpose of adding junk to the offset is to make the offset
> unique to that RPC transaction, just like the R_key is. This helps
> make the RDMA segment co-ordinates (handle, length, offset) more
> unique and thus harder to spoof.

Thank you for the explanation that makes sense.

> We could use random numbers in that upper 32 bits, but we have
> something more handy: the RPC's XID.
>
> Now when you look at an RDMA Read or Write, the top 32 bits in each
> RDMA segment's offset match the XID of the RPC transaction that the
> RDMA operations go with. This is really a secondary benefit to the
> uniquifying effect above.

I find the wording "no the wire RDMA read or write" misleading. Did
you really mean it as "RDMA read or write" or do you mean "RDMA_MSG"
or do you mean "NFS RDMA read or write"? Because RDMA offset is not a
part of the RDMA read/write (first/middle/last) packet. That's what
I'm hanged up on.


>
>
> --
> Chuck Lever
>
>
>
