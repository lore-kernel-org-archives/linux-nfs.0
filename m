Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:19105 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752377AbaHLOwc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Aug 2014 10:52:32 -0400
Message-ID: <53EA2A1F.7020006@RedHat.com>
Date: Tue, 12 Aug 2014 10:52:15 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Mike Frysinger <vapier@gentoo.org>, libtirpc-devel@lists.sourceforge.net
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH [libtirpc]] include stdarg.h when used
References: <1407827532-31173-1-git-send-email-vapier@gentoo.org>
In-Reply-To: <1407827532-31173-1-git-send-email-vapier@gentoo.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/12/2014 03:12 AM, Mike Frysinger wrote:
> The debug.h header uses va_list but doesn't include stdarg.h which
> can lead to random build failures.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
Committed... 

steved.
> ---
>  src/debug.h | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/src/debug.h b/src/debug.h
> index afc8d57..c971ac3 100644
> --- a/src/debug.h
> +++ b/src/debug.h
> @@ -21,6 +21,8 @@
>  
>  #ifndef _DEBUG_H
>  #define _DEBUG_H
> +
> +#include <stdarg.h>
>  #include <syslog.h>
>  
>  extern int libtirpc_debug_level;
> 
