Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:59084 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S965013AbeBMOXa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Feb 2018 09:23:30 -0500
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.rdu2.redhat.com [10.11.54.5])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 868F8EAEB0
        for <linux-nfs@vger.kernel.org>; Tue, 13 Feb 2018 14:23:30 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 67F8676F5
        for <linux-nfs@vger.kernel.org>; Tue, 13 Feb 2018 14:23:30 +0000 (UTC)
Subject: Re: [PATCH 1/1] Remove warnings from rpcgen generated files
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20180209155042.28461-1-steved@redhat.com>
 <20180209155042.28461-2-steved@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <d8e83c5e-a271-be11-57b6-037465d4bad8@RedHat.com>
Date: Tue, 13 Feb 2018 09:23:29 -0500
MIME-Version: 1.0
In-Reply-To: <20180209155042.28461-2-steved@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/09/2018 10:50 AM, Steve Dickson wrote:
> The xdr c-files, generated from .x by rpcgen, in both
> libnsm.a and libexport.a libraries cause the
> following warnings:
> 
> mount_xdr.c:43:20: warning: unused variable 'buf' [-Wunused-variable]
> sm_inter_xdr.c:37:20: warning: unused variable 'buf' [-Wunused-variable]
> sm_inter_xdr.c:51:6: warning: unused variable 'i' [-Wunused-variable]
> 
> These warnings are caused by rpcgen trying in inline
> the xdr routines. It turns out no inlining was happening,
> except for one routine. So turning off inlining eliminated
> these warnings.
> 
> This patch also eliminates a Werror missing-prototypes in sm_inter.h
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.

> ---
>  support/export/Makefile.am | 2 +-
>  support/nsm/Makefile.am    | 3 ++-
>  2 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/support/export/Makefile.am b/support/export/Makefile.am
> index be3de69..13f7a49 100644
> --- a/support/export/Makefile.am
> +++ b/support/export/Makefile.am
> @@ -35,7 +35,7 @@ $(GENFILES_CLNT): %_clnt.c: %.x $(RPCGEN)
>  
>  $(GENFILES_XDR): %_xdr.c: %.x $(RPCGEN)
>  	test -f $@ && rm -rf $@ || true
> -	$(RPCGEN) -c -o $@ $<
> +	$(RPCGEN) -c -i 0 -o $@ $<
>  
>  $(GENFILES_H): %.h: %.x $(RPCGEN)
>  	test -f $@ && rm -rf $@ || true
> diff --git a/support/nsm/Makefile.am b/support/nsm/Makefile.am
> index 2038e68..8f5874e 100644
> --- a/support/nsm/Makefile.am
> +++ b/support/nsm/Makefile.am
> @@ -32,11 +32,12 @@ $(GENFILES_SVC): %_svc.c: %.x $(RPCGEN)
>  
>  $(GENFILES_XDR): %_xdr.c: %.x $(RPCGEN)
>  	test -f $@ && rm -rf $@ || true
> -	$(RPCGEN) -c -o $@ $<
> +	$(RPCGEN) -c -i 0 -o $@ $<
>  
>  $(GENFILES_H): %.h: %.x $(RPCGEN)
>  	test -f $@ && rm -rf $@ || true
>  	$(RPCGEN) -h -o $@ $<
> +	echo "void sm_prog_1(struct svc_req *, SVCXPRT *);" >> $@
>  	rm -f $(top_builddir)/support/include/sm_inter.h
>  	$(LN_S) ../nsm/sm_inter.h $(top_builddir)/support/include/sm_inter.h
>  
> 
