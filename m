Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:60082 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753125AbeFGLWO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 7 Jun 2018 07:22:14 -0400
MIME-Version: 1.0
In-Reply-To: <CAJKOXPd2rntNOpU1quR9Zm_J22+=pEaj4ZTC_tdZ0zcRYUciFg@mail.gmail.com>
References: <CAJKOXPd2rntNOpU1quR9Zm_J22+=pEaj4ZTC_tdZ0zcRYUciFg@mail.gmail.com>
From: Krzysztof Kozlowski <krzk@kernel.org>
Date: Thu, 7 Jun 2018 13:22:11 +0200
Message-ID: <CAJKOXPcD3NecVq7yhpJb3whUZe28yq9OrwUpAyEt103KcSNtJA@mail.gmail.com>
Subject: Re: [BUG BISECT] NFSv4 client fails on Flush Journal to Persistent Storage
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "linux-samsung-soc@vger.kernel.org"
        <linux-samsung-soc@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 7, 2018 at 1:19 PM, Krzysztof Kozlowski <krzk@kernel.org> wrote=
:
> Hi,
>
> When booting my boards under recent linux-next, I see failures of systemd=
:
>
> [FAILED] Failed to start Flush Journal to Persistent Storage.
> See 'systemctl status systemd-journal-flush.service' for details.
>          Starting Create Volatile Files and Directories...
> [**    ] A start job is running for Create V=E2=80=A6 [  223.209289] nfs:
> server 192.168.1.10 not responding, still trying
> [  223.209377] nfs: server 192.168.1.10 not responding, still trying
>
> Effectively the boards fails to boot. Example is here:
> https://krzk.eu/#/builders/1/builds/2157
>
> This was bisected to:
> commit 37ac86c3a76c113619b7d9afe0251bbfc04cb80a
> Author: Chuck Lever <chuck.lever@oracle.com>
> Date:   Fri May 4 15:34:53 2018 -0400
>
>     SUNRPC: Initialize rpc_rqst outside of xprt->reserve_lock
>
>     alloc_slot is a transport-specific op, but initializing an rpc_rqst
>     is common to all transports. In addition, the only part of initial-
>     izing an rpc_rqst that needs serialization is getting a fresh XID.
>
>     Move rpc_rqst initialization to common code in preparation for
>     adding a transport-specific alloc_slot to xprtrdma.
>
>     Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>     Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
>
>
> Bisect log attached. Full configuration:
> 1. exynos_defconfig
> 2. ARMv7, octa-core, Exynos5422 and Exynos4412 (Odroid XU3, U3 and others=
)
> 3. NFSv4 client (from Raspberry Pi)
>
> Let me know if you need any more information.

Ah, I forgot maybe the most important information in reproducment -
client uses NFS root (NFSv4).

Best regards,
Krzysztof
