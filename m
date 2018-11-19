Return-Path: <SRS0=xyvj=N6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08E3AC43441
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 21:22:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A13902080C
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 21:22:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="U6OXrgLL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A13902080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=umich.edu
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730510AbeKTHsQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 20 Nov 2018 02:48:16 -0500
Received: from mail-vs1-f65.google.com ([209.85.217.65]:44484 "EHLO
        mail-vs1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730203AbeKTHsP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Nov 2018 02:48:15 -0500
Received: by mail-vs1-f65.google.com with SMTP id g68so18650933vsd.11;
        Mon, 19 Nov 2018 13:22:43 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=flCTWYcSvRG5gZgeA40/4vAiF4xG9DMN2lyzzh17CKc=;
        b=U6OXrgLLpbJ9JO4A12RvuDBY4dZs1LhteHTD+f8d+jJoIfU1m2lj+4Lr5i4YeTRiLf
         m79RqR+5hoQWHx06lfYLgMxY8YPYNmnxEKpxJ0RWwOy8h2MWJ1KP3Kad3ZLGF7tRNMcN
         f+IDHgYCSGiybRqSiB0XW+G31FG2A7+XhicdIltjeIKjWlxxzrDsspvTOv+qtQLX9zY7
         xQAIH0Wdq1IvbiBMnl7b9SdPBXd9XRx1XTDtKlHO31cJyT4iCmDyAPuoBm4PMZ8hz3xh
         RiK3Wxb0Ion8nZN3N0JXkQP9onUBaDyUxvGTF97bkbZs0HWxnyH+x/7qvuQ0Mf2r4u1P
         T3Cw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=flCTWYcSvRG5gZgeA40/4vAiF4xG9DMN2lyzzh17CKc=;
        b=YGiWYLuocnFGRP1LLLvD854U1ZfhWaVqdd6xUSPaC1qj+zCLL9F4uUyOWetT8arffQ
         A04OL5XZ8I3U9Dqyy/deHWVa5/QluiAdckkCExxbxX2ZXWQ9F6C/obdeyMva8+DYEtKh
         5iAVabJwvVlCusotEfCbqyGKAHL8tH6pKgLLSA0gxHmBRU93+WnqEPSoKM1244hkktz+
         jsA+mYL7beHZjX4+ak5LvC5oF8+I2r4xscfLNb62ke4FE8uLS1y6R/qjrB6AMStZ6Pcj
         sEQLoo2DoJquXg3XEhzmyZ3E5kCVsSj5iWaYbW7cuH/F0Ag0HhcEUTDx7Sl4TTbilx4I
         54qg==
X-Gm-Message-State: AGRZ1gL8zU8cH/OrEbtPJp3FlR+jbjmUuHIKMNUuL6rL1f9noslulmfU
        fRc5n3TAk+/mCdIcQjO7LuqgFQioxpRN9Nza700=
X-Google-Smtp-Source: AJdET5fuZ41WLe81kIYhAyqWhbXXUMDEvvN8HjJM52acwnsJsXK+cygWXuhvbHtwABV0LTyBv8FHmGhT6tFKceGacTw=
X-Received: by 2002:a67:a858:: with SMTP id r85mr9747787vse.215.1542662563036;
 Mon, 19 Nov 2018 13:22:43 -0800 (PST)
MIME-Version: 1.0
References: <20181119153707.10832.42881.stgit@manet.1015granger.net>
 <20181119154607.10832.92558.stgit@manet.1015granger.net> <CAN-5tyG26W+TjTsjpTVvF3RJOGCnD8L79dCbRqKTm5F1V3fuxw@mail.gmail.com>
 <6592845E-0136-4D42-8426-3E2A0BB5FFE7@oracle.com> <CAN-5tyEw5iRaA6mCp5DeNv1DMkFGAqtvq1PcRSiFZ6PQyJpDUA@mail.gmail.com>
 <4A94F1A9-96A4-4A2F-8617-AF0E2380D0C1@oracle.com> <CAN-5tyGU85PJe4Uoocw5NkT8YiYSF8wTWTgg4HycAgKpyHSfiw@mail.gmail.com>
 <9BD3F7C9-96BF-4555-A901-5E82E2CF9E28@oracle.com>
In-Reply-To: <9BD3F7C9-96BF-4555-A901-5E82E2CF9E28@oracle.com>
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Mon, 19 Nov 2018 16:22:31 -0500
Message-ID: <CAN-5tyELSi-Vtf1W3CSFzynbgVW7rcyJnfHmcb6Ehs0NEUiy4A@mail.gmail.com>
Subject: Re: [PATCH v1 4/4] xprtrdma: Plant XID in on-the-wire RDMA offset (FRWR)
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-rdma <linux-rdma@vger.kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Nov 19, 2018 at 1:59 PM Chuck Lever <chuck.lever@oracle.com> wrote:
>
>
>
> > On Nov 19, 2018, at 1:47 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> >
> > On Mon, Nov 19, 2018 at 1:19 PM Chuck Lever <chuck.lever@oracle.com> wrote:
> >>
> >>
> >>
> >>> On Nov 19, 2018, at 1:08 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> >>>
> >>> On Mon, Nov 19, 2018 at 12:59 PM Chuck Lever <chuck.lever@oracle.com> wrote:
> >>>>
> >>>>
> >>>>
> >>>>> On Nov 19, 2018, at 12:47 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> >>>>>
> >>>>> On Mon, Nov 19, 2018 at 10:46 AM Chuck Lever <chuck.lever@oracle.com> wrote:
> >>>>>>
> >>>>>> Place the associated RPC transaction's XID in the upper 32 bits of
> >>>>>> each RDMA segment's rdma_offset field. These bits are currently
> >>>>>> always zero.
> >>>>>>
> >>>>>> There are two reasons to do this:
> >>>>>>
> >>>>>> - The R_key only has 8 bits that are different from registration to
> >>>>>> registration. The XID adds more uniqueness to each RDMA segment to
> >>>>>> reduce the likelihood of a software bug on the server reading from
> >>>>>> or writing into memory it's not supposed to.
> >>>>>>
> >>>>>> - On-the-wire RDMA Read and Write operations do not otherwise carry
> >>>>>> any identifier that matches them up to an RPC. The XID in the
> >>>>>> upper 32 bits will act as an eye-catcher in network captures.
> >>>>>
> >>>>> Is this just an "eye-catcher" or do you have plans to use it in
> >>>>> wireshark? If the latter, then can we really do that? while a linux
> >>>>> implementation may do that, other (or even possibly future linux)
> >>>>> implementation might not do this. Can we justify changing the
> >>>>> wireshark logic for it?
> >>>>
> >>>> No plans to change the wireshark RPC-over-RDMA dissector.
> >>>> That would only be a valid thing to do if adding the XID
> >>>> were made part of the RPC-over-RDMA protocol via an RFC.
> >>>
> >>> Agreed. Can you also help me understand the proposal (as I'm still
> >>> trying to figure why it is useful).
> >>>
> >>> You are proposing to modify the RDMA segments's RDMA offset field (I
> >>> see top 6bits are indeed always 0). I don't see how adding that helps
> >>> an RDMA read/write message which does not have an "offset" field in it
> >>> be matched to a particular RPC. I don't believe we have (had) any
> >>> issues matching the initial RC Send only that contains the RDMA_MSG to
> >>> the RPC.
> >>
> >> The ULP has access to only the low order 8 bits of the R_key. The
> >> upper 24 bits are fixed for each MR. So for any given MR, there are
> >> only 256 unique R_key values. That means the same R_key will appear
> >> again quickly on the wire.
> >>
> >> The 64-bit offset field is set by the ULP, and can be essentially
> >> any arbitrary value. Most kernel ULPs use the iova of the registered
> >> memory. We only need the lower 32 bits for that.
> >>
> >> The purpose of adding junk to the offset is to make the offset
> >> unique to that RPC transaction, just like the R_key is. This helps
> >> make the RDMA segment co-ordinates (handle, length, offset) more
> >> unique and thus harder to spoof.
> >
> > Thank you for the explanation that makes sense.
> >
> >> We could use random numbers in that upper 32 bits, but we have
> >> something more handy: the RPC's XID.
> >>
> >> Now when you look at an RDMA Read or Write, the top 32 bits in each
> >> RDMA segment's offset match the XID of the RPC transaction that the
> >> RDMA operations go with. This is really a secondary benefit to the
> >> uniquifying effect above.
> >
> > I find the wording "no the wire RDMA read or write" misleading. Did
> > you really mean it as "RDMA read or write" or do you mean "RDMA_MSG"
> > or do you mean "NFS RDMA read or write"? Because RDMA offset is not a
> > part of the RDMA read/write (first/middle/last) packet. That's what
> > I'm hanged up on.
>
> Here's an RDMA Read request in a network capture I had at hand:
>
> No.     Time               Source                Destination           Protocol Length Info
>     228 22:31:06.203637    LID: 5                LID: 11               InfiniBand 42     RC RDMA Read Request QP=0x000240
>
> Frame 228: 42 bytes on wire (336 bits), 42 bytes captured (336 bits) on interface 1
> Extensible Record Format
> InfiniBand
>     Local Route Header
>     Base Transport Header
>     RETH - RDMA Extended Transport Header
>         Virtual Address: 11104011393315758080   <<<<<<
>         Remote Key: 1879114618
>         DMA Length: 4015
>     Invariant CRC: 0xd492a3e1
>     Variant CRC: 0x8736
>
> The value of the Virtual Address field is what the RPC-over-RDMA
> protocol calls the Offset. The Read responses are matched to this
> request by their message sequence numbers, and this Read request is
> matched to the RPC Call by the XID in the top 32 bits of the
> Virtual Address.
>
> Likewise for an RDMA Write Only request:
>
>     188 22:31:06.201350    LID: 5                LID: 11               InfiniBand 162    RC RDMA Write Only QP=0x000240
>
> Frame 188: 162 bytes on wire (1296 bits), 162 bytes captured (1296 bits) on interface 1
> Extensible Record Format
> InfiniBand
>     Local Route Header
>     Base Transport Header
>     RETH - RDMA Extended Transport Header
>         Virtual Address: 10455493047213809920   <<<<<<
>         Remote Key: 1879115386
>         DMA Length: 120
>     Invariant CRC: 0xe2e1b2cd
>     Variant CRC: 0x676f
> Data (120 bytes)
>
> 0000  91 19 5f 87 00 00 00 01 00 00 00 00 00 00 00 00   .._.............
> 0010  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01   ................
> 0020  00 00 00 02 00 00 01 ed 00 00 00 02 00 00 04 16   ................
> 0030  00 00 00 64 00 00 00 00 00 00 00 28 00 00 00 00   ...d.......(....
> 0040  00 00 00 00 00 00 00 00 00 00 00 00 54 9e e5 9d   ............T...
> 0050  c6 d3 1a d2 00 00 00 00 00 00 63 1f 5b f2 2e 7a   ..........c.[..z
> 0060  0b ae f9 ec 5b f2 2e 7a 0b 53 6c ef 5b f2 2e 7a   ....[..z.Sl.[..z
> 0070  0b 53 6c ef 00 00 00 0c                           .Sl.....
>
>
> I believe RDMA Write First also has an RETH. The sender does not
> interleave RDMA Writes, so subsequent Middle and Last packets go
> with this RDMA Write First.

Ok I see now where I was confused, in RDMA_MSG in the wireshark it's
labeled "RDMA offset" and the in the RDMA write first message it's
labeled "Virtual address". Thank you for explanation.

Here's the next question (coming from Jorge)? Is it reasonable to
assume that top 32bits are always zero? I have an network trace (from
4.18-rc2 kernel) where they are not.

RPC over RDMA
    XID: 0xa347cfa2
    Version: 1
    Flow Control: 128
    Message Type: RDMA_MSG (0)
    Read list (count: 0)
    Write list (count: 1)
        Write chunk (1 segment)
            Write chunk segment count: 1
            RDMA segment 0
                RDMA handle: 0x4000076f
                RDMA length: 65676
                RDMA offset: 0x0000001049973000

I don't believe 0xa347cfa2 can fit?
>
>
> --
> Chuck Lever
>
>
>
