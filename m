Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:33145 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487AbbIQNid (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Sep 2015 09:38:33 -0400
Received: by oixx17 with SMTP id x17so9490240oix.0
        for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2015 06:38:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150915145229.4e69d5f7@synchrony.poochiereds.net>
References: <1442332163-9230-1-git-send-email-suzuki.poulose@arm.com>
	<20150915145229.4e69d5f7@synchrony.poochiereds.net>
Date: Thu, 17 Sep 2015 09:38:33 -0400
Message-ID: <CAHQdGtTzHbuBQTdW7vfxpOzET8hOQrXV-AE1Px7rNwu1zBMKNw@mail.gmail.com>
Subject: Re: [PATCH] SUNRPC: Fix a race in xs_reset_transport
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: "Suzuki K. Poulose" <suzuki.poulose@arm.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 15, 2015 at 2:52 PM, Jeff Layton <jlayton@poochiereds.net> wrote:
> On Tue, 15 Sep 2015 16:49:23 +0100
> "Suzuki K. Poulose" <suzuki.poulose@arm.com> wrote:
>
>>  net/sunrpc/xprtsock.c |    9 ++++++++-
>>  1 file changed, 8 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>> index 7be90bc..6f4789d 100644
>> --- a/net/sunrpc/xprtsock.c
>> +++ b/net/sunrpc/xprtsock.c
>> @@ -822,9 +822,16 @@ static void xs_reset_transport(struct sock_xprt *transport)
>>       if (atomic_read(&transport->xprt.swapper))
>>               sk_clear_memalloc(sk);
>>
>> -     kernel_sock_shutdown(sock, SHUT_RDWR);
>> +     if (sock)
>> +             kernel_sock_shutdown(sock, SHUT_RDWR);
>>
>
> Good catch, but...isn't this still racy? What prevents transport->sock
> being set to NULL after you assign it to "sock" but before calling
> kernel_sock_shutdown?

The XPRT_LOCKED state.

Cheers
   Trond
