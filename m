Return-Path: <SRS0=G+EE=N3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62EF0C43441
	for <linux-nfs@archiver.kernel.org>; Fri, 16 Nov 2018 20:12:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2A3532086B
	for <linux-nfs@archiver.kernel.org>; Fri, 16 Nov 2018 20:12:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="d69E9ZCx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A3532086B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=umich.edu
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725956AbeKQG0A (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 17 Nov 2018 01:26:00 -0500
Received: from mail-vs1-f48.google.com ([209.85.217.48]:38858 "EHLO
        mail-vs1-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725819AbeKQG0A (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Nov 2018 01:26:00 -0500
Received: by mail-vs1-f48.google.com with SMTP id x64so14452245vsa.5
        for <linux-nfs@vger.kernel.org>; Fri, 16 Nov 2018 12:12:10 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=EiWwkkbsRNJc31f90OmUEaoxzTvVsRW/n1UJch+jRkI=;
        b=d69E9ZCxgSAqiV18kJ9VmsF1gPQwAeaocZsxPOxcIyMMfxbVJLmrtrVSzXY2fxrGZy
         B7u7VctlyfbS2Bbqsg0AWdyZkj6pO3c9t4JHWxvtytrKsy2dU72hz65kChIZI4W0Wqqe
         oAo16ISQBg+fqNBMRcmaFvkMl+SQiuk2y2elfju003L3eQynd0LVZ0zNREch5Uz/AZKd
         XmxXvsSXPtYhjFJoWFUjCU5jGfu1ppSjJRGnGgmoXkUgp5L8IYFEEbiIMtoQFhDgnGwa
         xEUr0/kspJjaeM7ffeGJSV+/JQm65Qh/OVcpn2xJGs7sVlwdO9z2YjXcrCdSajf8sYoG
         YmYw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=EiWwkkbsRNJc31f90OmUEaoxzTvVsRW/n1UJch+jRkI=;
        b=ROcuvu8FUcLNPhgaD6foZDxQvVBpIfi1qwlk78be/PuuOa0plvpMYMP6IdBNlTLcMN
         tjE1CheFtklWLhfyJ1o6l4BQUHLLM9LbBmEQjOtLN7LlUaGDKUBaTOyh/4+3rL6oHy1E
         K9HWnBqr0ixvt4GAZDivRJpLq9z6Ai0XRHjbMqT0Ca+FgYFAZT+CaHOw6naTo3Ewtojj
         95mIw7o9rI1FaNNuvmrqWKw48geHwickpdK4eXK0LYPH+qzhPnc0vueykH+UnOoKOC0P
         q2YY960W0npxrVDfufLmZ+KDxiPz3qzOKLt5EemVwa/JdXTrcPeG5upYqan1hmD2cA10
         fCOQ==
X-Gm-Message-State: AGRZ1gKJFKOIDPDuCm/btdUTavP6Xi7kkNcALE1hJetuInStuWV4ploi
        Toy1nVpHa9b/sZsXq0Yk0YJzoZPnxqfAAHTSQmQ=
X-Google-Smtp-Source: AJdET5egn1Pa6aZoe/D5sFhZh+eevhTX0LHRWxOqR6+a9nB8o0xOEltyAosiDwJyntkzXPxVWXlp31VPNLreb83TydU=
X-Received: by 2002:a67:60c7:: with SMTP id u190mr5097902vsb.85.1542399129551;
 Fri, 16 Nov 2018 12:12:09 -0800 (PST)
MIME-Version: 1.0
References: <20181116142627.GA19946@fieldses.org> <CAN-5tyGsDAd2hkaw5nONdS2TzRy1qK7xyFDpNeT7Jsd9ZrH7+g@mail.gmail.com>
 <20181116175645.GA21852@fieldses.org> <20181116180118.GB21852@fieldses.org>
 <CAN-5tyGRy5vi4P-jMTmV7cto8b_6s5Cuop7dTN0Y7witpzr2pQ@mail.gmail.com>
 <CAN-5tyHX3h6TXJhFeZPGZvAWXXxwaxpAkZtRNV9+L8m5xJ3fVw@mail.gmail.com>
 <20181116193016.GA22304@fieldses.org> <CAN-5tyFDGnCAdQcYJRC15nsqLOmOt2c4+bZN7pEFSL-1PAx2XQ@mail.gmail.com>
 <20181116195844.GB22304@fieldses.org>
In-Reply-To: <20181116195844.GB22304@fieldses.org>
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Fri, 16 Nov 2018 15:11:58 -0500
Message-ID: <CAN-5tyGhkNkhU0ow8DbEm1RAjC2xiAZXwnCm5i13j-2zXHRv3A@mail.gmail.com>
Subject: Re: handle_async_copy calling kzalloc under spinlock
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Nov 16, 2018 at 2:58 PM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Fri, Nov 16, 2018 at 02:49:00PM -0500, Olga Kornievskaia wrote:
> > On Fri, Nov 16, 2018 at 2:30 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> > >
> > > On Fri, Nov 16, 2018 at 01:52:29PM -0500, Olga Kornievskaia wrote:
> > > > On Fri, Nov 16, 2018 at 1:30 PM Olga Kornievskaia <aglo@umich.edu> wrote:
> > > > > Then how does the copy knows not to go wait for the callback? Copy
> > > > > checks the pending_callback list to see if received a callback. If
> > > > > not, it puts itself on the copy list and goes to sleep. The callback,
> > > > > checks the copy list and if it finds a copy signals it, if not it puts
> > > > > itself on the pending_callback list. a lock is held over checking one
> > > > > list and putting yourself on the other.
> > >
> > > OK, apologies, I don't really understand those data structures yet, but
> > > something seems wrong to me.
> > >
> > > Under what circumstances could we recieve a CB_OFFLOAD without having
> > > started the corresponding copy already?
> >
> > It can receive a CB_OFFLOAD before it receives a reply to the COPY.
> > It's possible and I can trigger it during testing when doing a really
> > short copy. The copy is done and callback thread sends a reply.
> > CB_OFFLOAD call and COPY reply can be switched on the server or on the
> > processing on the client.
>
> That race is discussed in
> https://tools.ietf.org/html/rfc5661#section-2.10.6.3 and is supposed to
> be dealt with by using referring triples and/or returning DELAY.

I believe those are suggestions and not mandates? A client can't rely
that the server will implement referring sequence information. Sending
"delay" to the server might be an option but it's an option that most
like will interfere with performance as well?

> > > And shouldn't CB_OFFLOAD be returning bad_stateid in the case it doesn't
> > > recognize the given stateid?
> >
> > It could but what should the server do in this case. I would imagine
> > it wouldn't do anything. There is nothing it can do. So now we have a
> > copy that send the call and is going to wait on the reply which will
> > never come as the 1st one came and we rejected it and now copy will
> > wait forever.
> >
> > Please describe what "is wrong" with the current implementation.  I
> > believe it provide a reasonable solution to the race condition.
>
> Looks like a server that sends bad stateids in callbacks could cause you
> to allocate something that will never get freed.

I thought the philosophy was that client shouldn't be coded to a
broken server. If needed, we can later on add a cleanup thread that
goes thru the list and removes really old entries.

>
> --b.
>
> > > It looks like the allocation failure is
> > > the *only* way we'll return an error on CB_OFFLOAD, and that seems
> > > wrong.
> >
> > Yes it is the only error we currently return. Do you see any other
> > useful errors that a client should return (and would be useful to
> > handle on the server). I don't see any need for any more
> > complications.
> >
> > > > > > I also wonder if SERVERFAULT is really the best error for a memory
> > > > > > allocation failure there.
> > > > >
> > > > > I guess EIO or ENOMEM might be better. But I don't think this error
> > > > > gets returned anywhere to the main process.
> > > > >
> > > >
> > > > Wait. It is returning SERVERFAULT because it's the callback server replying
> > > > back to the server's CB_RECALL call and I believe SERVERFAULT is the
> > > > appropriate error here. NFS doesn't have ENOMEM error.
> > >
> > > We could return DELAY if we think it might be worth the server trying
> > > the CB_RECALL again.  (That's what nfsd usually returns on allocation
> > > failures.  I don't know if that's really ideal.)
> >
> > If the client had any smarts to say correct this error that would be
> > useful to return but this is not the case. I don't believe there is a
