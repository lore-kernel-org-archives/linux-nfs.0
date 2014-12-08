Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56204 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750908AbaLHRdY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Dec 2014 12:33:24 -0500
Message-ID: <5485E0DF.10501@RedHat.com>
Date: Mon, 08 Dec 2014 12:33:19 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: =?UTF-8?B?RGF2aWQgSMOkcmRlbWFu?= <david@hardeman.nu>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] nfs-utils: fix gssd build flags
References: <20141202123805.13015.25151.stgit@zeus.muc.hardeman.nu> <20141202123954.13015.95501.stgit@zeus.muc.hardeman.nu>
In-Reply-To: <20141202123954.13015.95501.stgit@zeus.muc.hardeman.nu>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/02/2014 07:39 AM, David Härdeman wrote:
> The tirpc variable is another library to add, not additional flags.
> I'm guessing the reason this hasn't caused problems is that it only
> shows up with static libraries.
> 
> Signed-off-by: David Härdeman <david@hardeman.nu>
Committed... 

steved.
> ---
>  utils/gssd/Makefile.am |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/gssd/Makefile.am b/utils/gssd/Makefile.am
> index 9835117..e12a480 100644
> --- a/utils/gssd/Makefile.am
> +++ b/utils/gssd/Makefile.am
> @@ -46,8 +46,8 @@ gssd_SOURCES = \
>  	write_bytes.h
>  
>  gssd_LDADD =	../../support/nfs/libnfs.a \
> -		$(RPCSECGSS_LIBS) $(KRBLIBS) $(GSSAPI_LIBS)
> -gssd_LDFLAGS = $(KRBLDFLAGS) $(LIBTIRPC)
> +		$(RPCSECGSS_LIBS) $(KRBLIBS) $(GSSAPI_LIBS) $(LIBTIRPC)
> +gssd_LDFLAGS = $(KRBLDFLAGS)
>  
>  gssd_CFLAGS = $(AM_CFLAGS) $(CFLAGS) \
>  	      $(RPCSECGSS_CFLAGS) $(KRBCFLAGS) $(GSSAPI_CFLAGS)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
