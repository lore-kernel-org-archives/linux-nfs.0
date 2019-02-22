Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFF7DC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 14:47:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9D0F3206A3
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 14:47:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fzlhDPLa"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726798AbfBVOrK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 09:47:10 -0500
Received: from mail-ua1-f66.google.com ([209.85.222.66]:46446 "EHLO
        mail-ua1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725978AbfBVOrJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Feb 2019 09:47:09 -0500
Received: by mail-ua1-f66.google.com with SMTP id j8so2113384uae.13
        for <linux-nfs@vger.kernel.org>; Fri, 22 Feb 2019 06:47:09 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yUfhcpmpMfdg9+8PJndXjFHOmyPOT5v3mdQLXDj7FMo=;
        b=fzlhDPLa4fXkV1qtmEdbMmlTYedrS4Xin0IB8oCLNnN48DsMREUVAIiypiGIgWAike
         x89nTW+9+oK1kytfelOfAFV2SKz+/m+xma6m/DBRbU4u8rieuGaj7sZVGqt7zlsJKWF2
         dY/1Tk2DXEHvpSqdWYwBnFt4qHRObEgziT9DrMQXwF6pM2VujbXCZPzEDEgRWXss1hc5
         sXj9SMiZTxsRGqa4/VGD3frWnCW04UFwbXR+xN09FC6iq579Yb+kFZF0yaBux28gIv6w
         NVQ/ayS519fGb5DiDEGTvrhaTGMgAgDeB8PuX65U/yY93sL8qnN06CykOTRfr3JPaPgv
         uCCA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=yUfhcpmpMfdg9+8PJndXjFHOmyPOT5v3mdQLXDj7FMo=;
        b=Lx/X14aXcdyT6ZYbz7Lsi33F/6AfK8EowHuHxc6rjU+1Ry5nV63wWnNZ/OMRip+4Pu
         kClp3Hb2KB/7UkI+T8MS9BqlezvxQdDnJAu+0I4nDIY15dIKNf/nxS3ywtlKIP2g0NKK
         xsKAobSTuzakeEAX3KO8rpm6m4eBbFrYVqQGIENmjVRoIavd7xSBKdnY7MiD5fFPvJP9
         jxa3o53erdEzVZEisbdr4tw5WlM+PYmGK3WV3EE/1uPgk7DAaL8uFSYFeBqqam+BHoWb
         FDLK954MQzh6F8bs5yhJqLqsAyXCTcuYT+QyrQA6DMHSQY1squQYQxcXpqqBIuQNQ9xg
         XNAA==
X-Gm-Message-State: AHQUAubvQpdVwipIIFUOPTPQznp/S/Ymh80ZBl8Ly9oa9Bz5zrDDf9eS
        fi1+l8nlelkedGaCSEUiJ6MV1GwPw+CwIsB7KwfZ3w==
X-Google-Smtp-Source: AHgI3Ib346KBk4J3kqT9O0Xmlz0jk4EF0K0WmhWnMIc0cntLUB4U0FM5xG5DP1azyGNJMh06GOcR9VimJE9CKjd1Zrc=
X-Received: by 2002:a05:6102:150:: with SMTP id a16mr2365590vsr.134.1550846828568;
 Fri, 22 Feb 2019 06:47:08 -0800 (PST)
MIME-Version: 1.0
References: <20190220145650.21566-1-olga.kornievskaia@gmail.com>
 <1550837576.6456.3.camel@redhat.com> <a124c78ca5a5eefce34e8a84e92d87516345ee0c.camel@hammerspace.com>
In-Reply-To: <a124c78ca5a5eefce34e8a84e92d87516345ee0c.camel@hammerspace.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Fri, 22 Feb 2019 09:46:57 -0500
Message-ID: <CAN-5tyE5dm07V_8Qqse5qrLQVzrYXELM1EY2ySpCedBUBKYsLQ@mail.gmail.com>
Subject: Re: [PATCH 1/1] SUNRPC: fix handling of half-closed connection
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "dwysocha@redhat.com" <dwysocha@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Feb 22, 2019 at 8:45 AM Trond Myklebust <trondmy@hammerspace.com> wrote:
>
> On Fri, 2019-02-22 at 07:12 -0500, Dave Wysochanski wrote:
> > Hi Olga,
> >
> > Do you have a reproducer for this?  A number of months ago I did a
> > significant amount of testing with half-closed connections, after we
> > had reports of connections stuck in FIN_WAIT2 in some older kernels.
> > What I found was with kernels that had the tcp keepalives (commit
> > 7f260e8575bf53b93b77978c1e39f8e67612759c), I could only reproduce a
> > hang of a few minutes, after which time the tcp keepalive code would
> > reset the connection.
> >
> > That said it was a while ago and something subtle may have changed.
> > Also I'm not not sure if your header implies an indefinite hang or
> > just
> > a few minutes.
> >
> > Thanks.
> >
> >
> > On Wed, 2019-02-20 at 09:56 -0500, Olga Kornievskaia wrote:
> > > From: Olga Kornievskaia <kolga@netapp.com>
> > >
> > > When server replies with an ACK to client's FIN/ACK, client ends
> > > up stuck in a TCP_FIN_WAIT2 state and client's mount hangs.
> > > Instead, make sure to close and reset client's socket and transport
> > > when transitioned into that state.
>

Hi Trond,

> So, please do note that we do not want to ignore the FIN_WAIT2 state

But we do ignore the FIN_WAIT2 state.

> because it implies that the server has not closed the socket on its
> side.

That's correct.

> That again means that we cannot re-establish a connection using
> the same source IP+port to the server, which is problematic for
> protocols such as NFSv3 which rely on standard duplicate reply cache
> for correct replay semantics.

that's exactly what's happening that a client is unable to establish a
new connection to the server. With the patch, the client does an RST
and it re-uses the port and all is well for NFSv3.

> This is why we don't just set the TCP_LINGER2 socket option and call
> sock_release(). The choice to try to wait it out is deliberate because
> the alternative is that we end up with busy-waiting re-connection
> attempts.

Why would it busy-wait? In my testing, RST happens and new connection
is established?


>
> Cheers
>   Trond
> --
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com
>
>
