Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pl0-f67.google.com ([209.85.160.67]:36392 "EHLO
        mail-pl0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751716AbdK1KBR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Nov 2017 05:01:17 -0500
Received: by mail-pl0-f67.google.com with SMTP id b12so10349991plm.3
        for <linux-nfs@vger.kernel.org>; Tue, 28 Nov 2017 02:01:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1511544841.14300.4.camel@primarydata.com>
References: <CACT4Y+bXN5vHCcwEk9NYbPe=RXmweMK09g=nW5D5ww+PTegL5w@mail.gmail.com>
 <1511544841.14300.4.camel@primarydata.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 28 Nov 2017 11:00:56 +0100
Message-ID: <CACT4Y+YDbE5n5VRTma4J5sGgk5Z4ctSwXGRxFUPf=8KEhd7pjQ@mail.gmail.com>
Subject: Re: sunrpc: infinite unkillable console spam in xs_tcp_setup_socket
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "syzkaller@googlegroups.com" <syzkaller@googlegroups.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 24, 2017 at 6:34 PM, Trond Myklebust
<trondmy@primarydata.com> wrote:
> On Mon, 2017-11-20 at 14:02 +0100, Dmitry Vyukov wrote:
>> Hello,
>>
>> The following program triggers infinite stream of the following
>> output
>> on console. The program is unkillable and this effectively brings the
>> machine down:
>>
>>
>> ** 16 printk messages dropped ** [12875.022917] xs_tcp_setup_socket:
>> connect returned unhandled error -113
>>
>
> Does the following fix the issue?


Re-run the provided reproducer with the patch.
I don't see any kernel output and the process is perfectly killable now.

Tested-by: Dmitry Vyukov <dvyukov@google.com>





> 8<-----------------------------------------------------
> From f48d3f01df45f50f0145060f5272ccf1aea855ac Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Fri, 24 Nov 2017 12:00:24 -0500
> Subject: [PATCH] SUNRPC: Allow connect to return EHOSTUNREACH
>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  net/sunrpc/xprtsock.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 4dad5da388d6..8cb40f8ffa5b 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -2437,6 +2437,7 @@ static void xs_tcp_setup_socket(struct work_struct *work)
>         case -ECONNREFUSED:
>         case -ECONNRESET:
>         case -ENETUNREACH:
> +       case -EHOSTUNREACH:
>         case -EADDRINUSE:
>         case -ENOBUFS:
>                 /*
> --
> 2.14.3
>
> --
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
