Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f54.google.com ([74.125.82.54]:65071 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751402AbaK2SPS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Nov 2014 13:15:18 -0500
Received: by mail-wg0-f54.google.com with SMTP id l2so11065879wgh.27
        for <linux-nfs@vger.kernel.org>; Sat, 29 Nov 2014 10:15:16 -0800 (PST)
Date: Sat, 29 Nov 2014 19:15:13 +0100
From: "Yann E. MORIN" <yann.morin.1998@free.fr>
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org, Steve Dickson <steved@redhat.com>
Subject: Re: [PATCH libtirpc v2] pkg-config: needs pthread as private library
Message-ID: <20141129181513.GC4217@free.fr>
References: <1416764609-1822-1-git-send-email-yann.morin.1998@free.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1416764609-1822-1-git-send-email-yann.morin.1998@free.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello All,

On 2014-11-23 18:43 +0100, Yann E. MORIN spake thusly:
> libtirpc needs pthreads. This is automatically pulled in when linking
> with the shared library, thanks to the DT_NEEDED ELF tags.
> 
> But for a static library, there is no such mechanism to identify
> required libraries.
> 
> Thus, add -lpthread to the private libraries in the pkg-config file.

Ping?

Regards,
Yann E. MORIN.

> Signed-off-by: "Yann E. MORIN" <yann.morin.1998@free.fr>
> Cc: Steve Dickson <steved@redhat.com>
> 
> ---
> Changes v1 -> v2:
>   - posted publicly in appropriate locations  (thanks Steve)
> ---
>  libtirpc.pc.in | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/libtirpc.pc.in b/libtirpc.pc.in
> index ec4cf75..38034c5 100644
> --- a/libtirpc.pc.in
> +++ b/libtirpc.pc.in
> @@ -8,4 +8,5 @@ Description: Transport Independent RPC Library
>  Requires:
>  Version: @PACKAGE_VERSION@
>  Libs: -L@libdir@ -ltirpc
> +Libs.private: -lpthread
>  Cflags: -I@includedir@/tirpc
> -- 
> 1.9.1
> 

-- 
.-----------------.--------------------.------------------.--------------------.
|  Yann E. MORIN  | Real-Time Embedded | /"\ ASCII RIBBON | Erics' conspiracy: |
| +33 662 376 056 | Software  Designer | \ / CAMPAIGN     |  ___               |
| +33 223 225 172 `------------.-------:  X  AGAINST      |  \e/  There is no  |
| http://ymorin.is-a-geek.org/ | _/*\_ | / \ HTML MAIL    |   v   conspiracy.  |
'------------------------------^-------^------------------^--------------------'
