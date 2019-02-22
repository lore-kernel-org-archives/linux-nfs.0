Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F807C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 17:02:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C3EDD20665
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 17:02:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QO0+7+YX"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726278AbfBVRCz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 12:02:55 -0500
Received: from mail-vk1-f196.google.com ([209.85.221.196]:43057 "EHLO
        mail-vk1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726131AbfBVRCz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Feb 2019 12:02:55 -0500
Received: by mail-vk1-f196.google.com with SMTP id e131so640021vkf.10
        for <linux-nfs@vger.kernel.org>; Fri, 22 Feb 2019 09:02:54 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=m32GruMd1eaLlOkFjwg0cbB604+C7nCBqjthm+T9xGI=;
        b=QO0+7+YXzZljj51u8uxG/0WeMxpui/iRktNyve/XzW4yJfpb55m8tRlW8NxqY06GBl
         4+5b1sA4xq/09Kg7DQOcaeE5IkOCYDt8Li5AoEBrNQLKzhR8c9mJSjOQ/4c3ApoUd8H4
         cLX4a30+jfBWeaA/Qo0D9nkk9bYil9xutvaHlSseR54T4NTceE9R2+CXpqz3NYJhnSen
         fOff7cmDMuNY8mCHB3tzqmTBba/fVXYHUoFl6tFulIUKyo41iCzc0OzKog5uNa5PlpN4
         /15K5A0bkzxvWFcHPQdjKBpJCzKef21qVookn7XJgKOwVRAu4Aalc/MklbdgmgQNZf50
         cNZQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=m32GruMd1eaLlOkFjwg0cbB604+C7nCBqjthm+T9xGI=;
        b=VNtOgA0jcCJSMcGyGglJFnJKj9ULw27PmL3d0BdvNpqrH+tIiK6aFSbHeyXKOy4hN4
         S0T6K4SLLx76+d84afnmb5iiflmePSn5L4UP/VdYKp9XtUX2vMKszQIaFLVQzmaHeUaV
         dH8OcOrBSCRj3ffeuPFPLd0MU3kSdSJsXVMwIZnbWl0cZ0GiJ6DjJ7HjatuCXQuLJ2bj
         2QEQaAdVWKCX9n5E6s+5s7wg9k6v/l+gi5hn0ooINKbNNGFDRt0219w92dzXnYNHWa3z
         hj+cSLC682PDamD1sLNVq0GThWL2/J900FHOSQ0zPYMCWkp8ThLMw8ig73gjpU1i0BWp
         a4dA==
X-Gm-Message-State: AHQUAuZWOH/ycHrYCoxwgAvW780VspD768KLYonvRq5yl3nvTb/4aANT
        3UUwGO+xkVboeB7u/0R82Nx7I6Jjnix+2r2WThw=
X-Google-Smtp-Source: AHgI3IbSmekcvbZD/Rem5McmMvx3mD36irOlIaTHmIuu6E7otbsQRdP3Vo5lYPO4BBbolzQPaOUb/NLzg982VSxOr8A=
X-Received: by 2002:a1f:7f10:: with SMTP id o16mr2704005vki.31.1550854973574;
 Fri, 22 Feb 2019 09:02:53 -0800 (PST)
MIME-Version: 1.0
References: <20190220145650.21566-1-olga.kornievskaia@gmail.com>
 <1550837576.6456.3.camel@redhat.com> <a124c78ca5a5eefce34e8a84e92d87516345ee0c.camel@hammerspace.com>
 <CAN-5tyE5dm07V_8Qqse5qrLQVzrYXELM1EY2ySpCedBUBKYsLQ@mail.gmail.com>
 <05e439b3c419f3ac173feb770d3d2ae1d7500a2d.camel@hammerspace.com>
 <CAN-5tyFu4g40XJ7JzTSbidaEA30NeLQXFWD4t9pkRufesV-vJw@mail.gmail.com> <132998d93b8eb3d85c63a4176536b7b1403e0f88.camel@hammerspace.com>
In-Reply-To: <132998d93b8eb3d85c63a4176536b7b1403e0f88.camel@hammerspace.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Fri, 22 Feb 2019 12:02:42 -0500
Message-ID: <CAN-5tyE3iWR1655w-ixRpo3v-_C2+t44F8W=ou7oByHGnn8+cg@mail.gmail.com>
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

On Fri, Feb 22, 2019 at 10:50 AM Trond Myklebust
<trondmy@hammerspace.com> wrote:
>
> On Fri, 2019-02-22 at 10:11 -0500, Olga Kornievskaia wrote:
> > On Fri, Feb 22, 2019 at 10:06 AM Trond Myklebust
> > <trondmy@hammerspace.com> wrote:
> > > On Fri, 2019-02-22 at 09:46 -0500, Olga Kornievskaia wrote:
> > > > On Fri, Feb 22, 2019 at 8:45 AM Trond Myklebust <
> > > > trondmy@hammerspace.com> wrote:
> > > > > On Fri, 2019-02-22 at 07:12 -0500, Dave Wysochanski wrote:
> > > > > > Hi Olga,
> > > > > >
> > > > > > Do you have a reproducer for this?  A number of months ago I
> > > > > > did
> > > > > > a
> > > > > > significant amount of testing with half-closed connections,
> > > > > > after
> > > > > > we
> > > > > > had reports of connections stuck in FIN_WAIT2 in some older
> > > > > > kernels.
> > > > > > What I found was with kernels that had the tcp keepalives
> > > > > > (commit
> > > > > > 7f260e8575bf53b93b77978c1e39f8e67612759c), I could only
> > > > > > reproduce
> > > > > > a
> > > > > > hang of a few minutes, after which time the tcp keepalive
> > > > > > code
> > > > > > would
> > > > > > reset the connection.
> > > > > >
> > > > > > That said it was a while ago and something subtle may have
> > > > > > changed.
> > > > > > Also I'm not not sure if your header implies an indefinite
> > > > > > hang
> > > > > > or
> > > > > > just
> > > > > > a few minutes.
> > > > > >
> > > > > > Thanks.
> > > > > >
> > > > > >
> > > > > > On Wed, 2019-02-20 at 09:56 -0500, Olga Kornievskaia wrote:
> > > > > > > From: Olga Kornievskaia <kolga@netapp.com>
> > > > > > >
> > > > > > > When server replies with an ACK to client's FIN/ACK, client
> > > > > > > ends
> > > > > > > up stuck in a TCP_FIN_WAIT2 state and client's mount hangs.
> > > > > > > Instead, make sure to close and reset client's socket and
> > > > > > > transport
> > > > > > > when transitioned into that state.
> > > >
> > > > Hi Trond,
> > > >
> > > > > So, please do note that we do not want to ignore the FIN_WAIT2
> > > > > state
> > > >
> > > > But we do ignore the FIN_WAIT2 state.
> > >
> > > We do not. We wait for the server to send a FIN, which is precisely
> > > the
> > > reason for which FIN_WAIT2 exists.
> > >
> > > > > because it implies that the server has not closed the socket on
> > > > > its
> > > > > side.
> > > >
> > > > That's correct.
> > > >
> > > > > That again means that we cannot re-establish a connection using
> > > > > the same source IP+port to the server, which is problematic for
> > > > > protocols such as NFSv3 which rely on standard duplicate reply
> > > > > cache
> > > > > for correct replay semantics.
> > > >
> > > > that's exactly what's happening that a client is unable to
> > > > establish
> > > > a
> > > > new connection to the server. With the patch, the client does an
> > > > RST
> > > > and it re-uses the port and all is well for NFSv3.
> > >
> > > RST is not guaranteed to be delivered to the recipient. That's why
> > > the
> > > TCP protocol defines FIN: it is a guaranteed to be delivered
> > > because it
> > > is ACKed.
> > >
> > > > > This is why we don't just set the TCP_LINGER2 socket option and
> > > > > call
> > > > > sock_release(). The choice to try to wait it out is deliberate
> > > > > because
> > > > > the alternative is that we end up with busy-waiting re-
> > > > > connection
> > > > > attempts.
> > > >
> > > > Why would it busy-wait? In my testing, RST happens and new
> > > > connection
> > > > is established?
> > >
> > > Only if the server has dropped the connection without notifying the
> > > client.
> >
> > Yes the server dropped the connection without notifying the client
> > (or
> > perhaps something in the middle did it as an attack). Again, I raise
> > this concern for the sake of dealing with this as an attack. I have
> > no
> > intentions of catering to broken servers. If this is not a possible
> > attack, then we don't have to deal with it.
>
> A man in the middle might be able to intercept the FIN from the server
> and ACK it, causing the connection to be closed on that server.
> However, as Dave pointed out, why wouldn't the keepalive mechanism then
> eventually kick in and close the socket on the client as well?

The mechanism is already kicked in and got stuck in FIN_WAIT2. NFS
connection was idle, so TCP layer was sending keep-alives. Then it
sent a FIN/ACK to which the server replied with just an ACK. Kernel
notified NFS that we are in FIN_WAIT2 and I believe it is NFS
responsibility to act accordingly. Kernel then keeps sending
"keep-alives" forever.  Because of this code:

        case TCP_FIN_WAIT1:
        case TCP_FIN_WAIT2:
                /* RFC 793 says to queue data in these states,
                 * RFC 1122 says we MUST send a reset.
                 * BSD 4.4 also does reset.
                 */
                if (sk->sk_shutdown & RCV_SHUTDOWN) {
                        if (TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq &&
                            after(TCP_SKB_CB(skb)->end_seq - th->fin,
tp->rcv_nxt)) {
                                NET_INC_STATS(sock_net(sk),
LINUX_MIB_TCPABORTONDATA);
                                tcp_reset(sk);   << this is never triggered
                                return 1;
                        }
                }

In our case TCP_SKB_CB(skb)->end_seq always equals
TCP_SKB_CB(skb)->seq. (No i don't know the meaning of end_seq and seq
:-/).

> If the FIN is not ACKed, then the server is supposed to keep
> retransmitting it. Until that ACK is received, it cannot close the
> socket without violating the TCP protocol.

Something in the middle can keep intercepting the the FIN/ACK from the
server and keep sending an ACK back?

>
> --
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com
>
>
