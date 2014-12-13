Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:44315 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966626AbaLMOkS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 13 Dec 2014 09:40:18 -0500
Message-ID: <548C4FC7.6010001@RedHat.com>
Date: Sat, 13 Dec 2014 09:40:07 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Yann E. MORIN" <yann.morin.1998@free.fr>,
        libtirpc-devel@lists.sourceforge.net
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH libtirpc v2] pkg-config: needs pthread as private library
References: <1416764609-1822-1-git-send-email-yann.morin.1998@free.fr>
In-Reply-To: <1416764609-1822-1-git-send-email-yann.morin.1998@free.fr>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/23/2014 12:43 PM, Yann E. MORIN wrote:
> libtirpc needs pthreads. This is automatically pulled in when linking
> with the shared library, thanks to the DT_NEEDED ELF tags.
> 
> But for a static library, there is no such mechanism to identify
> required libraries.
> 
> Thus, add -lpthread to the private libraries in the pkg-config file.
> 
> Signed-off-by: "Yann E. MORIN" <yann.morin.1998@free.fr>
> Cc: Steve Dickson <steved@redhat.com>
Committed... 

steved.

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
> 
