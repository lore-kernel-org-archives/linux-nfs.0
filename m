Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8485EC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 15:11:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5534720657
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 15:11:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="C2DByZwa"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726380AbfBVPLR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 10:11:17 -0500
Received: from mail-ua1-f68.google.com ([209.85.222.68]:37888 "EHLO
        mail-ua1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726325AbfBVPLR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Feb 2019 10:11:17 -0500
Received: by mail-ua1-f68.google.com with SMTP id p9so2237550uaa.5
        for <linux-nfs@vger.kernel.org>; Fri, 22 Feb 2019 07:11:16 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=M3Ro7AG/5w3ilJ8C2EhLesq53D/y9X5HjCZjTquiytQ=;
        b=C2DByZwaXDLglmC+AL36i3WGjxjPXFKzYk1rdpnJrsS1Ylg/w+RO+48rO90xisx8jx
         Z2naKztF0hYizjs2EYUQquN/jD6OX/ynzh2sGh9b8WC0xIBOVWh1jhbGc+i/lEjpB2v5
         hVtt/FrqJth8esFB8k9dR+GneO1jUc85WOtbiQlPgVYLLPMqYnxQcb1xotua3ChWRqlp
         xbZ0x5bCHdvprXWffXmCa6GV4HRFcZ4w4Gbs8HnIYJduY+HozpUH2lw04QeYt48k7LyW
         OAN2Jvl8Aez0sEyLuS2LB2V+wVqXSwGPWyegI0+4xyTZ4G45TTWWhsiTVEaESsgI8IM7
         FaAg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=M3Ro7AG/5w3ilJ8C2EhLesq53D/y9X5HjCZjTquiytQ=;
        b=aAKJywyg8cia+AE/TgaAxGqDI7SIHLdqDsQTlUvPsPlQwyuSSBfRLB0aKkr2U+niZi
         bQQUimncuNXwD32aSTcOFW/jLh7lB2nAACdSgVQJSEFVJbyr2DNZwXJeomWN8ieebXBw
         XJRTlK+rhmJcSZjOO/uw5ZYVJBxrGQSFJ870qv7QZMoUJUtm5i5L8AUBgvuFWU1DsUR3
         umi4VqQN6UFWR0rXY3NuNFW6IjdFPaBzEcwg+4vJ2Mo6Svc93X7v/Mmpm4l7AL8zBFxh
         +x8OtbFzWWEApd1RCwjgVIlUtdzF60pjTseEL8VPqD5zMfBvXBr1MlDE3MLShUvP89g4
         ZJUw==
X-Gm-Message-State: AHQUAuYYfG+kXetDn7aNk/Ce5vBY1qbX9HiK7ZTyZYx+QRs5q3c2rfS0
        XK6XzYgai9MQcRJKyChFn78N7YmiG+AbIc/cZpo=
X-Google-Smtp-Source: AHgI3IZv3fdlMHWyVmrTOk2gP6wLxdeHVjtXOQMdq1BN+967PrVmSFOdd3kQhmkvhU64e7gr9JUg/OiPt5rsYwoRiEI=
X-Received: by 2002:a05:6102:18f:: with SMTP id r15mr2364415vsq.215.1550848275898;
 Fri, 22 Feb 2019 07:11:15 -0800 (PST)
MIME-Version: 1.0
References: <20190220145650.21566-1-olga.kornievskaia@gmail.com>
 <1550837576.6456.3.camel@redhat.com> <a124c78ca5a5eefce34e8a84e92d87516345ee0c.camel@hammerspace.com>
 <CAN-5tyE5dm07V_8Qqse5qrLQVzrYXELM1EY2ySpCedBUBKYsLQ@mail.gmail.com> <05e439b3c419f3ac173feb770d3d2ae1d7500a2d.camel@hammerspace.com>
In-Reply-To: <05e439b3c419f3ac173feb770d3d2ae1d7500a2d.camel@hammerspace.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Fri, 22 Feb 2019 10:11:04 -0500
Message-ID: <CAN-5tyFu4g40XJ7JzTSbidaEA30NeLQXFWD4t9pkRufesV-vJw@mail.gmail.com>
Subject: Re: [PATCH 1/1] SUNRPC: fix handling of half-closed connection
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "dwysocha@redhat.com" <dwysocha@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Feb 22, 2019 at 10:06 AM Trond Myklebust
<trondmy@hammerspace.com> wrote:
>
> On Fri, 2019-02-22 at 09:46 -0500, Olga Kornievskaia wrote:
> > On Fri, Feb 22, 2019 at 8:45 AM Trond Myklebust <
> > trondmy@hammerspace.com> wrote:
> > > On Fri, 2019-02-22 at 07:12 -0500, Dave Wysochanski wrote:
> > > > Hi Olga,
> > > >
> > > > Do you have a reproducer for this?  A number of months ago I did
> > > > a
> > > > significant amount of testing with half-closed connections, after
> > > > we
> > > > had reports of connections stuck in FIN_WAIT2 in some older
> > > > kernels.
> > > > What I found was with kernels that had the tcp keepalives (commit
> > > > 7f260e8575bf53b93b77978c1e39f8e67612759c), I could only reproduce
> > > > a
> > > > hang of a few minutes, after which time the tcp keepalive code
> > > > would
> > > > reset the connection.
> > > >
> > > > That said it was a while ago and something subtle may have
> > > > changed.
> > > > Also I'm not not sure if your header implies an indefinite hang
> > > > or
> > > > just
> > > > a few minutes.
> > > >
> > > > Thanks.
> > > >
> > > >
> > > > On Wed, 2019-02-20 at 09:56 -0500, Olga Kornievskaia wrote:
> > > > > From: Olga Kornievskaia <kolga@netapp.com>
> > > > >
> > > > > When server replies with an ACK to client's FIN/ACK, client
> > > > > ends
> > > > > up stuck in a TCP_FIN_WAIT2 state and client's mount hangs.
> > > > > Instead, make sure to close and reset client's socket and
> > > > > transport
> > > > > when transitioned into that state.
> >
> > Hi Trond,
> >
> > > So, please do note that we do not want to ignore the FIN_WAIT2
> > > state
> >
> > But we do ignore the FIN_WAIT2 state.
>
> We do not. We wait for the server to send a FIN, which is precisely the
> reason for which FIN_WAIT2 exists.
>
> >
> > > because it implies that the server has not closed the socket on its
> > > side.
> >
> > That's correct.
> >
> > > That again means that we cannot re-establish a connection using
> > > the same source IP+port to the server, which is problematic for
> > > protocols such as NFSv3 which rely on standard duplicate reply
> > > cache
> > > for correct replay semantics.
> >
> > that's exactly what's happening that a client is unable to establish
> > a
> > new connection to the server. With the patch, the client does an RST
> > and it re-uses the port and all is well for NFSv3.
>
> RST is not guaranteed to be delivered to the recipient. That's why the
> TCP protocol defines FIN: it is a guaranteed to be delivered because it
> is ACKed.
>
> > > This is why we don't just set the TCP_LINGER2 socket option and
> > > call
> > > sock_release(). The choice to try to wait it out is deliberate
> > > because
> > > the alternative is that we end up with busy-waiting re-connection
> > > attempts.
> >
> > Why would it busy-wait? In my testing, RST happens and new connection
> > is established?
>
> Only if the server has dropped the connection without notifying the
> client.

Yes the server dropped the connection without notifying the client (or
perhaps something in the middle did it as an attack). Again, I raise
this concern for the sake of dealing with this as an attack. I have no
intentions of catering to broken servers. If this is not a possible
attack, then we don't have to deal with it.
