Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 504ECC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 14:44:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2253B20823
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 14:44:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="h7J82OEB"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726131AbfBVOop (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 09:44:45 -0500
Received: from mail-vk1-f193.google.com ([209.85.221.193]:46347 "EHLO
        mail-vk1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725978AbfBVOop (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Feb 2019 09:44:45 -0500
Received: by mail-vk1-f193.google.com with SMTP id j68so527203vke.13
        for <linux-nfs@vger.kernel.org>; Fri, 22 Feb 2019 06:44:44 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Rn2+i5m7v0D/CQE/7pk+EqXn9+jWk2lvNkNpHSnUURc=;
        b=h7J82OEBWwQNNYD8KILd9yB2iYPi1yDnVdgvGFICvBImb5Bu8DMl6Zjwdsvvyd80Cg
         mMHAmU+GpoBmpxFRovFrrI9qstVzrxkrcCmGsj70dlpBHUkvirI7HrzBMNpeyC19qDEs
         np4jFUhFdRoY/NMFKIutCfNuDRSV52xk1CGXZML//v/SRyTlyduTPN44y/sKwuEFCjZ0
         dfTII+bfJ8ibJflZ6fnNEYcD8otb9Jq2blTloZZYKcGwB+7VD+Wi3QZHAhJTU92UdP9Y
         hZ1Ito3NDzR3t9rGizPBcwJo9HFiSYmk+Uxu+7WE3PAAf7OVxR6wv2lprcqw8aZQHwGc
         ZPXA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=Rn2+i5m7v0D/CQE/7pk+EqXn9+jWk2lvNkNpHSnUURc=;
        b=iRembyOe5qOeBEp6OZ8mXKv8s6XbR6Fd9OZU5bnhPasmfOC5RdK1fRzXHVArvPnTvb
         6O2RiW+wbcUTePi6t5TbLIjx/kqydaT8QTyj1VD8gUpPdrVG/bKthAho7pVGjQdaOJQ0
         Vh/OGZyQYRsUp2WFdHyL/tOQFU6WXpXXv+q5qvCTaGwSzWeyUlLJYl38RwFR8tXd9trE
         rLeqxik1Neey61yia2KksWdLqZM0wcH6P02WOPWT2zsD2EVRo6RW1vUP/pUooTJqmCuR
         INf7WZakybVnsTBxlVySJcJjO0VOxFc02optO4+Jv8eGz9s56bQ4PAJJZgVymF2Isr4J
         sROw==
X-Gm-Message-State: AHQUAubBzNtyJEFhgw6NA1AFrVXCFNPfuyz/urZKcT6RQDTB6Po5ROK1
        pJPz2xtPu5v5kgAwz9pKZhYquk0Il/lCGL9tS4E=
X-Google-Smtp-Source: AHgI3Ib/572Y/6S8uBOihk1VqR9dDvAXA1v6VG1DrhLUVxBemLsYlLgUeOueYKyTvH4S7lLO+JkT9pjiHLvPmSmZ2RM=
X-Received: by 2002:a1f:1ac3:: with SMTP id a186mr2359090vka.34.1550846683404;
 Fri, 22 Feb 2019 06:44:43 -0800 (PST)
MIME-Version: 1.0
References: <20190220145650.21566-1-olga.kornievskaia@gmail.com> <1550837576.6456.3.camel@redhat.com>
In-Reply-To: <1550837576.6456.3.camel@redhat.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Fri, 22 Feb 2019 09:44:31 -0500
Message-ID: <CAN-5tyH1e_cakjmU5VkQraw=ht71y8vxvaZbe2W6zAdfEnWLPA@mail.gmail.com>
Subject: Re: [PATCH 1/1] SUNRPC: fix handling of half-closed connection
To:     Dave Wysochanski <dwysocha@redhat.com>
Cc:     trond.myklebust@hammerspace.com,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Dave,

A re-producer is a server that sends an ACK to the client's FIN/ACK
request and does nothing afterwards (I can reproduce it 100% with a
hacked up server. It was discovered with a "broken" server that
doesn't fully closes a connection). It leave this client unable to
connect to this server again indefinitely/forever/reboot required kind
of state. Once it was considered that doing something like that to the
client is a form of an attack (denial-of-server) and thus the kernel
has a tcp_fin_timeout option after which the kernel will abort the
connection. However this only applies to the sockets that have been
closed by the client. This is NOT the case. NFS does not close the
connection and it ignores kernel's notification of FIN_WAIT2 state.

One can argue that this is a broken server and we shouldn't bother.
But this patch is an attempt to argue that the client still should
care and deal with this condition. However, if the community feels
that a broken server is a broken server and this form of an attack is
not interested, this patch can live will be an archive for later or
never.

On Fri, Feb 22, 2019 at 7:12 AM Dave Wysochanski <dwysocha@redhat.com> wrote:
>
> Hi Olga,
>
> Do you have a reproducer for this?  A number of months ago I did a
> significant amount of testing with half-closed connections, after we
> had reports of connections stuck in FIN_WAIT2 in some older kernels.
> What I found was with kernels that had the tcp keepalives (commit
> 7f260e8575bf53b93b77978c1e39f8e67612759c), I could only reproduce a
> hang of a few minutes, after which time the tcp keepalive code would
> reset the connection.
>
> That said it was a while ago and something subtle may have changed.
> Also I'm not not sure if your header implies an indefinite hang or just
> a few minutes.
>
> Thanks.
>
>
> On Wed, 2019-02-20 at 09:56 -0500, Olga Kornievskaia wrote:
> > From: Olga Kornievskaia <kolga@netapp.com>
> >
> > When server replies with an ACK to client's FIN/ACK, client ends
> > up stuck in a TCP_FIN_WAIT2 state and client's mount hangs.
> > Instead, make sure to close and reset client's socket and transport
> > when transitioned into that state.
> >
> > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > ---
> >  net/sunrpc/xprtsock.c | 2 ++
> >  1 file changed, 2 insertions(+)
> >
> > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > index 618e9c2..812e5e3 100644
> > --- a/net/sunrpc/xprtsock.c
> > +++ b/net/sunrpc/xprtsock.c
> > @@ -1502,6 +1502,7 @@ static void xs_tcp_state_change(struct sock
> > *sk)
> >               clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
> >               smp_mb__after_atomic();
> >               break;
> > +     case TCP_FIN_WAIT2:
> >       case TCP_CLOSE_WAIT:
> >               /* The server initiated a shutdown of the socket */
> >               xprt->connect_cookie++;
> > @@ -2152,6 +2153,7 @@ static void xs_tcp_shutdown(struct rpc_xprt
> > *xprt)
> >               kernel_sock_shutdown(sock, SHUT_RDWR);
> >               trace_rpc_socket_shutdown(xprt, sock);
> >               break;
> > +     case TCP_FIN_WAIT2:
> >       case TCP_CLOSE:
> >       case TCP_TIME_WAIT:
> >               xs_reset_transport(transport);
