Return-Path: linux-kernel-owner@vger.kernel.org
MIME-Version: 1.0
In-Reply-To: <1423748102.4004.2.camel@primarydata.com>
References: <CA+r1ZhinMg425ecr4F_XqhRUyCs1FOMDBjvVvf0jV_O-WmpcgA@mail.gmail.com>
	<1423748102.4004.2.camel@primarydata.com>
Date: Thu, 12 Feb 2015 15:21:03 +0100
Message-ID: <CAMuHMdX+YTjnPaK8Vvjq3_92ieUw076tR7UHGAdecw-yRHj2Rg@mail.gmail.com>
Subject: Re: randconfig build error with next-20150209, in fs/nfs/client.c
From: Geert Uytterhoeven <geert@linux-m68k.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Jim Davis <jim.epost@gmail.com>,
        Thomas D Haynes <thomas.haynes@primarydata.com>,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        linux-next <linux-next@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>, anna.schumaker@netapp.com,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 12, 2015 at 2:35 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
>> include/linux/sunrpc/metrics.h:93:18: error: parameter name omitted
>>            struct rpc_iostats *) {}
>>                   ^
>>   CC      net/ipv4/ip_vti.o
>>   CC      net/ipv6/addrconf_core.o
>> make[2]: *** [fs/nfs/client.o] Error 1
>
> Thanks for the report! I'm adding the following fix to my linux-next
> branch and will push it to Linus before the merge window ends.

Thanks! I was just gonna git-send-email a similar patch...
>
> 8<------------------------------------------------------------------
> From 54d7e72a758609da5936d7452320d799cfc6a25c Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Thu, 12 Feb 2015 08:28:12 -0500
> Subject: [PATCH] SUNRPC: Fix a compile error when #undef CONFIG_PROC_FS
>
> The definition of rpc_count_iostats_metrics() is borked.
>
> Reported by: Jim Davis <jim.epost@gmail.com>
> Fixes: d67ae825a59d6 ("pnfs/flexfiles: Add the FlexFile Layout Driver")
> Cc: Tom Haynes <thomas.haynes@primarydata.com>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
