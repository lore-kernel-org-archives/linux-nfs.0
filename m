Return-Path: <SRS0=V3X6=Q4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33CE2C4360F
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 12:36:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EF94D2085A
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 12:36:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nqdfMV7a"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727781AbfBUMgA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 Feb 2019 07:36:00 -0500
Received: from mail-lj1-f195.google.com ([209.85.208.195]:44089 "EHLO
        mail-lj1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725385AbfBUMgA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Feb 2019 07:36:00 -0500
Received: by mail-lj1-f195.google.com with SMTP id q128so23794581ljb.11
        for <linux-nfs@vger.kernel.org>; Thu, 21 Feb 2019 04:35:58 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=N0+iCR752yav5z7A/FMmQZP0gDRyUppGU16PJuAs4E4=;
        b=nqdfMV7aqw/bQ5PywSfRz/qXuUqTxg7/sbuWwdUdd5p13ozxkFKuo61i+8YWdCBFeq
         qp4ai9dYMEYLuWCcwEku1aSltBzFbvn8uNtK+IicSwuf6SvU5VgZJppbXQt0Q0UZ+IP+
         M2YcwXjHeqqmzoBHrgoBcoQPI5+D8pipTv007IcxKhb+EKwcU6d9C38HbBUQg6OZ/Swz
         NJ378JpWN8LUOEmTaX2PDn+/VoS2UUHMl8AR5+mYQPBnp51cljYpPAV4QRCadGUMTZDq
         fWf+5RbHmqtUfxHEJR4WhcpLvFwcJuquGYSJzHYGAH+B8bSz0UV5x2IiCLp8nZHYmiKq
         Otiw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=N0+iCR752yav5z7A/FMmQZP0gDRyUppGU16PJuAs4E4=;
        b=YhlhEBxFwObPQ1ys7bsP1ivyEkB2WpmweDzQo5ZaFPsm82Vj/Nqn3Gxh6aZt9TD4Fo
         wkfM/3KI7jZ99YpaS7mixchanVd1pBPC8GwuDev46cJhT/YIH8EpGgsSrlbFod3NQgxu
         KMPHf6RA4JMc+YAKaEenYdARcuXJfvfq0wG6YWAanDw3SZ8IwzwN/MLqbAm3hiHhE+yM
         GM6iKbd8USEvbcbepE69pEeot8JBuGjCs8+jZGpcDQ4wZLHI92qQ5S98NL6aotW6stho
         RYjMkzYUYlwb+eix55Z1PADRqvuHGDWjsGAwUTAJV9MnmHB6zTNtD9IZ1XmP1TkEU0k4
         wSAA==
X-Gm-Message-State: AHQUAuYcenWI1PC6J48qfo71HQE0+lG0MBw89gOYfW19yxKYrIqXjfqQ
        J+TdFdIgegDAB9EuJuRPg/rwuqC22FtgfZ/rQWFTqbHW
X-Google-Smtp-Source: AHgI3Ib9YTObcYK+4GZiT8ofKgKx3wAbplI6wfCyCNYlF7IaPz2Rt4FBAK00DuvdHSUvRGPDuoaiWhF9lc6hWd3WKqs=
X-Received: by 2002:a2e:9c52:: with SMTP id t18-v6mr23547197ljj.149.1550752557994;
 Thu, 21 Feb 2019 04:35:57 -0800 (PST)
MIME-Version: 1.0
References: <CAK3fRr9EL-YOp3yUr5tMe5zuiERxHjkLDhAaWkxxEHjtfSwisQ@mail.gmail.com>
 <20190221041820.GA4625@fieldses.org>
In-Reply-To: <20190221041820.GA4625@fieldses.org>
From:   James Pearson <jcpearson@gmail.com>
Date:   Thu, 21 Feb 2019 12:35:46 +0000
Message-ID: <CAK3fRr-y3YjX-8hMtutvpy=MQCyqH8YmRBwxyGJ4HmJQwsLyGw@mail.gmail.com>
Subject: Re: nfsd thread limit and UDP ?
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, 21 Feb 2019 at 04:18, J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Wed, Feb 20, 2019 at 11:28:53AM +0000, James Pearson wrote:
> > On a very busy NFSv3 server (running CentOS 6), we recently upped the
> > nfsd thread count to 1024 - but this caused client mount requests over
> > UDP to fail.
> >
> > We configure all our clients to use TCP for NFS mounts, but the
> > automounter (automountd) on MacOS (up to version MacOS 10.12) seeds a
> > 'null call' to the NFS server over UDP before attempting the mount -
> > but the server appears to ignore any UDP requests - and the automount
> > fails
>
> By the way, you might also just turn off UDP.  (Start run rpc.nfsd with
> the -U option.)  Hopefully MacOS can handle that case.

We tried that - but when we restarted nfs, some existing mounts hung
(not sure why, as we should be just using TCP everywhere) ... although
when tested on a test server, the MacOS automounter worked fine

I tried your patch - it doesn't apply 'as is' on a CentOS 6 kernel -
but with a bit of manual hacking, I can get it to fit

However, the net/sunrpc/svcsock.c in these kernels has an extra call
to svc_sock_setbufsize() :

        /* Initialize the socket */
        if (sock->type == SOCK_DGRAM)
                svc_udp_init(svsk, serv);
        else {
                /* initialise setting must have enough space to
                 * receive and respond to one request.
                 */
                svc_sock_setbufsize(svsk->sk_sock, 4 * serv->sv_max_mesg,
                                        4 * serv->sv_max_mesg);
                svc_tcp_init(svsk, serv);
        }

I tried replacing that svc_sock_setbufsize() with:

                svc_sock_setbufsize(svsk, 4);

but that just caused the whole machine to lock up shortly after
sunrpc.ko was loaded ...

However, things seem to work fine if I call a copy of the original
svc_sock_setbufsize() at that point in the code with the original args
...

i.e. mounts over UDP (and MacOS automounts) now work with nfsd threads
over 1017 (I tried 2048 ... and it worked)

Incidentally, I came across an old thread on this list that appears to
be related to this issue (well, it mentions a 1020 thread limit and
buffer size wraps in svc_sock_setbufsize() ???) :

 https://www.spinics.net/lists/linux-nfs/msg34927.html

... but I'm not sure what the result of that was (nor if it is
actually related to the issue here) ?

Thanks

James Pearson
