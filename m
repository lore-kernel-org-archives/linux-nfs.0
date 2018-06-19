Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:40106 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750807AbeFSGeG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Jun 2018 02:34:06 -0400
Received: from mail-wr0-f174.google.com (mail-wr0-f174.google.com [209.85.128.174])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 466FD20883
        for <linux-nfs@vger.kernel.org>; Tue, 19 Jun 2018 06:34:05 +0000 (UTC)
Received: by mail-wr0-f174.google.com with SMTP id v13-v6so19188395wrp.13
        for <linux-nfs@vger.kernel.org>; Mon, 18 Jun 2018 23:34:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180618195510.26098.42839.stgit@manet.1015granger.net>
References: <20180618195510.26098.42839.stgit@manet.1015granger.net>
From: Krzysztof Kozlowski <krzk@kernel.org>
Date: Tue, 19 Jun 2018 08:34:03 +0200
Message-ID: <CAJKOXPdpYR+CGeDGpbYeEvR87x70enEMCD2tCbz5umjj71iG6g@mail.gmail.com>
Subject: Re: [PATCH v1] sunrpc: Prevent duplicate XID allocation
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org, geert@linux-m68k.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 18 June 2018 at 21:55, Chuck Lever <chuck.lever@oracle.com> wrote:
> Krzysztof Kozlowski <krzk@kernel.org> reports that a heavy NFSv4
> WRITE workload against a slow NFS server causes his Raspberry Pi
> clients to stall. Krzysztof bisected it to commit 37ac86c3a76c
> ("SUNRPC: Initialize rpc_rqst outside of xprt->reserve_lock") .
>
> I was able to reproduce similar behavior and it appears that rarely
> the RPC client layer is re-allocating an XID for an RPC that it has
> already partially sent. This results in the client ignoring the
> subsequent reply, which carries the original XID.
>
> For various reasons, checking !req->rq_xmit_bytes_sent in
> xprt_prepare_transmit is not a 100% reliable mechanism for
> determining when a fresh XID is needed.
>
> Trond's preference is to allocate the XID at the time each rpc_rqst
> slot is initialized.
>
> This patch should also address a gcc 4.1.2 complaint reported by
> Geert Uytterhoeven <geert@linux-m68k.org>.
>
> Reported-by: Krzysztof Kozlowski <krzk@kernel.org>
> Fixes: 37ac86c3a76c ("SUNRPC: Initialize rpc_rqst outside of ... ")
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprt.c |   10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)

This fixes the problems, thanks!

Tested-by: Krzysztof Kozlowski <krzk@kernel.org>

Best regards,
Krzysztof
