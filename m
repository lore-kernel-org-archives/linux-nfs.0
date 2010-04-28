From: Alex Riesen <raa.lkml@gmail.com>
Subject: Re: [patch 1/1] sunrpc: use formatting of module name in SUNRPC
Date: Wed, 28 Apr 2010 09:40:36 +0200
Message-ID: <l2l81b0412b1004280040t415657c7qe7de59f152cd49aa@mail.gmail.com>
References: <201004272115.o3RLFnKj020353@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org,
	Trond.Myklebust@netapp.com, cel@citi.umich.edu,
	davem@davemloft.net, tmtalpey@gmail.com, akpm@linux-foundation.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:52819 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751284Ab0D1Hki convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Apr 2010 03:40:38 -0400
In-Reply-To: <201004272115.o3RLFnKj020353-AB4EexQrvXRQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 27, 2010 at 23:15,  <akpm@linux-foundation.org> wrote:
> From: Alex Riesen <raa.lkml@gmail.com>
>
> gcc-4.3.3 produces the warning:
> =C2=A0"format not a string literal and no format arguments"
>
> Signed-off-by: Alex Riesen <raa.lkml@gmail.com>
> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: Chuck Lever <cel@citi.umich.edu>
> Cc: David S. Miller <davem@davemloft.net>
> Acked-by: Tom Talpey <tmtalpey@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>
> =C2=A0net/sunrpc/xprt.c | =C2=A0 =C2=A05 +----
> =C2=A01 file changed, 1 insertion(+), 4 deletions(-)
>

This is one tough little patch... 2 years and counting...
