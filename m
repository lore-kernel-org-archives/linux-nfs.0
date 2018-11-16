Return-Path: <SRS0=G+EE=N3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F5BCC43441
	for <linux-nfs@archiver.kernel.org>; Fri, 16 Nov 2018 19:49:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2E8EC20685
	for <linux-nfs@archiver.kernel.org>; Fri, 16 Nov 2018 19:49:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="imM6k8TH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E8EC20685
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=umich.edu
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725763AbeKQGC5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 17 Nov 2018 01:02:57 -0500
Received: from mail-ua1-f54.google.com ([209.85.222.54]:41190 "EHLO
        mail-ua1-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725753AbeKQGC5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Nov 2018 01:02:57 -0500
Received: by mail-ua1-f54.google.com with SMTP id z24so8682404ual.8
        for <linux-nfs@vger.kernel.org>; Fri, 16 Nov 2018 11:49:12 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=A3KutqkIdwPqq8110EmcbOKbkdr2nTuRnWNGPDCPYl0=;
        b=imM6k8THmBvsmz3//sL0CD+2OZBB118ix8qcyj2TPqJUZXkCyxLhkVh/z740nxm94m
         nooP7P58lfyHXvFLjw94JlHS0/8zgmA9SfcuickrbKdshWB1zDxzAm14sJ1nVEOmNPjN
         hnFTw8diDnG55PI2NtMgrS+H22EGbEZd/cSpHkIodnNjUYpwKld9v3hZIs+eiF5wnn28
         UZK/Jned9r2g8PVFAnN4ycZtVrsSqfIEKGTVJ4dvL2SDBM4DUEVyz71/Mv8J4RVSrDYq
         sdiiRs5bQnKbobLfzvpLa7Kmc26u+pz0fS2rVBPF/kJNEeVe0aMjHh5/U33bK5TEfYm0
         nB/w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=A3KutqkIdwPqq8110EmcbOKbkdr2nTuRnWNGPDCPYl0=;
        b=GospcXGbhSJf1TfM2sYFwzfEh5+EBaudPDaGtIoFSNU68ZblhDxXJ0A5eZm2m5H4DP
         QHEgrnJC1WXK6guS5vUJ98Wy5Kz19ktLKMdxFre3MDPY6eEWl4nN+gKH+p/GQecSk2nS
         tGM7MXLYBWJmVT698Iyjl0RtAU5l3KWtVOHjJTeVpFzhcTIv4D9Igl0jShKSq2F3PSnn
         6nfCL89/xxl58IRAz1iw2byhLBFR+D9m05EOIyEdrj8QMFOgtxzln2oNjPS36qfjbI0f
         tBWrkDJDAdaT3WB1GHuSq6+fjNi6izeYG1K6M1VDiNQkfp3zeB/deFBZZ4VZra3CgR0L
         Rf/A==
X-Gm-Message-State: AGRZ1gJ6zKrRJicJhM22NDthNRljMzBR/t/K0cJY+gS8UhQGupP9BIgI
        LTjp8AcU8VL47J4+XZ8a/S8ki+VU9/ItBPfdYWI=
X-Google-Smtp-Source: AJdET5fX6d9jf+Kwg6YhfMDMR03sMIXY3Z25ygaNaXE+iZ8lBk6CvLz5JZTmHuTcLfWOlhROamwSZTDQBbKmCVeJ8aE=
X-Received: by 2002:ab0:918:: with SMTP id w24mr5631630uag.51.1542397751544;
 Fri, 16 Nov 2018 11:49:11 -0800 (PST)
MIME-Version: 1.0
References: <20181116142627.GA19946@fieldses.org> <CAN-5tyGsDAd2hkaw5nONdS2TzRy1qK7xyFDpNeT7Jsd9ZrH7+g@mail.gmail.com>
 <20181116175645.GA21852@fieldses.org> <20181116180118.GB21852@fieldses.org>
 <CAN-5tyGRy5vi4P-jMTmV7cto8b_6s5Cuop7dTN0Y7witpzr2pQ@mail.gmail.com>
 <CAN-5tyHX3h6TXJhFeZPGZvAWXXxwaxpAkZtRNV9+L8m5xJ3fVw@mail.gmail.com> <20181116193016.GA22304@fieldses.org>
In-Reply-To: <20181116193016.GA22304@fieldses.org>
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Fri, 16 Nov 2018 14:49:00 -0500
Message-ID: <CAN-5tyFDGnCAdQcYJRC15nsqLOmOt2c4+bZN7pEFSL-1PAx2XQ@mail.gmail.com>
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

On Fri, Nov 16, 2018 at 2:30 PM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Fri, Nov 16, 2018 at 01:52:29PM -0500, Olga Kornievskaia wrote:
> > On Fri, Nov 16, 2018 at 1:30 PM Olga Kornievskaia <aglo@umich.edu> wrote:
> > > Then how does the copy knows not to go wait for the callback? Copy
> > > checks the pending_callback list to see if received a callback. If
> > > not, it puts itself on the copy list and goes to sleep. The callback,
> > > checks the copy list and if it finds a copy signals it, if not it puts
> > > itself on the pending_callback list. a lock is held over checking one
> > > list and putting yourself on the other.
>
> OK, apologies, I don't really understand those data structures yet, but
> something seems wrong to me.
>
> Under what circumstances could we recieve a CB_OFFLOAD without having
> started the corresponding copy already?

It can receive a CB_OFFLOAD before it receives a reply to the COPY.
It's possible and I can trigger it during testing when doing a really
short copy. The copy is done and callback thread sends a reply.
CB_OFFLOAD call and COPY reply can be switched on the server or on the
processing on the client.

>
> And shouldn't CB_OFFLOAD be returning bad_stateid in the case it doesn't
> recognize the given stateid?

It could but what should the server do in this case. I would imagine
it wouldn't do anything. There is nothing it can do. So now we have a
copy that send the call and is going to wait on the reply which will
never come as the 1st one came and we rejected it and now copy will
wait forever.

Please describe what "is wrong" with the current implementation.  I
believe it provide a reasonable solution to the race condition.

> It looks like the allocation failure is
> the *only* way we'll return an error on CB_OFFLOAD, and that seems
> wrong.

Yes it is the only error we currently return. Do you see any other
useful errors that a client should return (and would be useful to
handle on the server). I don't see any need for any more
complications.

> > > > I also wonder if SERVERFAULT is really the best error for a memory
> > > > allocation failure there.
> > >
> > > I guess EIO or ENOMEM might be better. But I don't think this error
> > > gets returned anywhere to the main process.
> > >
> >
> > Wait. It is returning SERVERFAULT because it's the callback server replying
> > back to the server's CB_RECALL call and I believe SERVERFAULT is the
> > appropriate error here. NFS doesn't have ENOMEM error.
>
> We could return DELAY if we think it might be worth the server trying
> the CB_RECALL again.  (That's what nfsd usually returns on allocation
> failures.  I don't know if that's really ideal.)

If the client had any smarts to say correct this error that would be
useful to return but this is not the case. I don't believe there is a
