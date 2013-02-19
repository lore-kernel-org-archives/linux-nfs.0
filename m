Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:29053 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933677Ab3BSSyi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2013 13:54:38 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: [PATCH [rpcbind]] fix building one systems w/out nss.h
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1361299690-19402-1-git-send-email-vapier@gentoo.org>
Date: Tue, 19 Feb 2013 13:54:19 -0500
Cc: libtirpc-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
Message-Id: <D1025EAD-8EEB-40A4-8EA4-0D21ECC16B66@oracle.com>
References: <1361299690-19402-1-git-send-email-vapier@gentoo.org>
To: Mike Frysinger <vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

On Feb 19, 2013, at 1:48 PM, Mike Frysinger <vapier@gentoo.org> wrote:

> The nss.h header is glibc-specific, so use the existing HAVE_NSS_H define
> to avoid including/using it when it is not available.
> 
> URL: http://bugs.gentoo.org/458024
> Reported-by: Mark Reiche <porphyr@gmx.de>
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> ---
> src/rpcbind.c | 4 ++++
> 1 file changed, 4 insertions(+)
> 
> diff --git a/src/rpcbind.c b/src/rpcbind.c
> index 9a0504d..83dbe93 100644
> --- a/src/rpcbind.c
> +++ b/src/rpcbind.c
> @@ -67,7 +67,11 @@
> #include <pwd.h>
> #include <string.h>
> #include <errno.h>
> +#ifdef HAVE_NSS_H
> #include <nss.h>
> +#else
> +static inline void __nss_configure_lookup(const char *db, const char *s) {}
> +#endif

Where is rpcbind getting the __nss_configure_lookup() function in this case?  I don't see that the call sites are ifdef-d out if HAVE_NSS_H is not defined.

> #include "rpcbind.h"
> 
> /*#define RPCBIND_DEBUG*/

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




