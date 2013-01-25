Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:2253 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753116Ab3AYXEb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jan 2013 18:04:31 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Arnd Bergmann <arnd@arndb.de>,
        "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Subject: RE: [PATCH 15/19] sunrpc: don't warn for unused variable 'buf'
Date: Fri, 25 Jan 2013 23:04:28 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91833C205@sacexcmbx05-prd.hq.netapp.com>
References: <1359123276-15833-1-git-send-email-arnd@arndb.de>
 <1359153858-31992-1-git-send-email-arnd@arndb.de>
 <1359153858-31992-16-git-send-email-arnd@arndb.de>
In-Reply-To: <1359153858-31992-16-git-send-email-arnd@arndb.de>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Arnd Bergmann [mailto:arnd@arndb.de]
> Sent: Friday, January 25, 2013 5:44 PM
> To: linux-arm-kernel@lists.infradead.org
> Cc: linux-kernel@vger.kernel.org; Arnd Bergmann; J. Bruce Fields;
> Myklebust, Trond; linux-nfs@vger.kernel.org; netdev@vger.kernel.org
> Subject: [PATCH 15/19] sunrpc: don't warn for unused variable 'buf'
> 
> When RPC_DEBUG is unset, the dprintk() macro does nothing, causing the
> 'buf' variable in svc_printk to become unused.
> Marking it as __maybe_unused avoids a harmless gcc warning.
> 
> Without this patch, building at91_dt_defconfig results in:
> 
> net/sunrpc/svc.c: In function 'svc_printk':
> net/sunrpc/svc.c:1051:7: warning: unused variable 'buf' [-Wunused-variable]
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Cc: "J. Bruce Fields" <bfields@redhat.com>
> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: linux-nfs@vger.kernel.org
> Cc: netdev@vger.kernel.org
> ---
>  net/sunrpc/svc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c index dbf12ac..b1f5223
> 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -1047,7 +1047,7 @@ void svc_printk(struct svc_rqst *rqstp, const char
> *fmt, ...)  {
>  	struct va_format vaf;
>  	va_list args;
> -	char 	buf[RPC_MAX_ADDRBUFLEN];
> +	char buf[RPC_MAX_ADDRBUFLEN] __maybe_unused;
> 
>  	va_start(args, fmt);

Alternatively, just declare it using the RPC_IFDEBUG() macro.

Cheers
  Trond
