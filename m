Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f172.google.com ([209.85.217.172]:33610 "EHLO
        mail-ua0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966701AbeEJRkg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 May 2018 13:40:36 -0400
Received: by mail-ua0-f172.google.com with SMTP id i2-v6so1859755uah.0
        for <linux-nfs@vger.kernel.org>; Thu, 10 May 2018 10:40:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <C4BAD0ED-E05B-4A43-8A9A-51176123D6B9@oracle.com>
References: <C4BAD0ED-E05B-4A43-8A9A-51176123D6B9@oracle.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 10 May 2018 13:40:35 -0400
Message-ID: <CAN-5tyH8i0hmx8nvMUXhndZE_LcGAB0mySjBpDTq7eLQ-gFgiQ@mail.gmail.com>
Subject: Re: SETCLIENTID acceptor
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 9, 2018 at 5:19 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> I'm right on the edge of my understanding of how this all works.
>
> I've re-keyed my NFS server. Now on my client, I'm seeing this on
> vers=4.0,sec=sys mounts:
>
> May  8 16:40:30 manet kernel: NFS: NFSv4 callback contains invalid cred
> May  8 16:40:30 manet kernel: NFS: NFSv4 callback contains invalid cred
> May  8 16:40:30 manet kernel: NFS: NFSv4 callback contains invalid cred
>
> manet is my client, and klimt is my server. I'm mounting with
> NFS/RDMA, so I'm mounting hostname klimt.ib, not klimt.
>
> Because the client is using krb5i for lease management, the server
> is required to use krb5i for the callback channel (S 3.3.3 of RFC
> 7530).
>
> After a SETCLIENTID, the client copies the acceptor from the GSS
> context it set up, and uses that to check incoming callback
> requests. I instrumented the client's SETCLIENTID proc, and I see
> this:
>
> check_gss_callback_principal: acceptor=nfs@klimt.ib.1015granger.net, principal=host@klimt.1015granger.net
>
> The principal strings are not equal, and that's why the client
> believes the callback credential is bogus. Now I'm trying to
> figure out whether it is the server's callback client or the
> client's callback server that is misbehaving.
>
> To me, the server's callback principal (host@klimt) seems like it
> is correct. The client would identify as host@manet when making
> calls to the server, for example, so I'd expect the server to
> behave similarly when performing callbacks.
>
> Can anyone shed more light on this?

What are your full hostnames of each machine and does the reverse
lookup from the ip to hostname on each machine give you what you
expect?

Sounds like all of them need to be resolved to <>.ib.1015grager.net
but somewhere you are getting <>.1015grager.net instead.
