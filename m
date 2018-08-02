Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:39364 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726891AbeHBUmm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Aug 2018 16:42:42 -0400
Received: by mail-it0-f49.google.com with SMTP id g141-v6so4904665ita.4
        for <linux-nfs@vger.kernel.org>; Thu, 02 Aug 2018 11:50:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <8dd8a352-aaca-71af-aca7-9be6c7039ff4@jpl.nasa.gov>
References: <8dd8a352-aaca-71af-aca7-9be6c7039ff4@jpl.nasa.gov>
From: Cedric Blancher <cedric.blancher@gmail.com>
Date: Thu, 2 Aug 2018 20:50:20 +0200
Message-ID: <CALXu0UdHWGOnMYk-xGG6_GWGfdpXffc0U-+Ark0joEYvhPSh_g@mail.gmail.com>
Subject: Re: NFSv4 file lock reporting interface request
To: Peter Scott <pjscott@jpl.nasa.gov>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Solaris and FreeBSD dtrace facility supports this functionality.
Unfortunately, Linux rejected dtrace for license issues, and instead
did... nothing.

Ced

On 10 July 2018 at 04:28, Peter Scott <pjscott@jpl.nasa.gov> wrote:
> Hello.  I am with the institutional hosting service at NASA's Jet Propulsion
> Laboratory and we have been trying to find the answer to an apparently
> simple question.
>
> We are running an NFSv4 server on Centos 7 and we need to get the server to
> tell us which files it thinks are locked by which clients.  This is because
> we have observed failure modes where something apparently has a lock
> (because attempting to lock the file again blocks) but we can't find a
> client that has the lock. Finding out what the server believes would be
> critical to troubleshooting this.
>
> We tracked down Trond Myklebust and Neil Brown and conversation suggests
> that this is a function that is (a) not currently available and (b)
> reasonable to ask for.  So this is me suggesting that an interface be
> provided to have knfsd output its list of locked files and clients.
>
> Regards,
> Peter Scott
> Office of the CIO
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Cedric Blancher <cedric.blancher@gmail.com>
[https://plus.google.com/u/0/+CedricBlancher/]
Institute Pasteur
