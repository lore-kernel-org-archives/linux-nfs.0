Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:7856 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754822Ab2E2TSt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 May 2012 15:18:49 -0400
Message-ID: <4FC520EE.9080303@RedHat.com>
Date: Tue, 29 May 2012 15:18:06 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Adam Sampson <ats@offog.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils 1.2.6: nsm_client needs to link with libtirpc
References: <20120526213213.GY25787@cartman.at.offog.org>
In-Reply-To: <20120526213213.GY25787@cartman.at.offog.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Committed...

steved.

On 05/26/2012 05:32 PM, Adam Sampson wrote:
> nsm_client needs to link against libtirpc.
> 
> diff -x config.log -x config.status -ru tmp/nfs-utils-1.2.6/tests/nsm_client/Makefile.am work/nfs-utils-1.2.6/tests/nsm_client/Makefile.am
> --- tmp/nfs-utils-1.2.6/tests/nsm_client/Makefile.am	2012-05-14 15:40:52.000000000 +0100
> +++ work/nfs-utils-1.2.6/tests/nsm_client/Makefile.am	2012-05-26 22:18:50.999001661 +0100
> @@ -13,7 +13,7 @@
>  
>  BUILT_SOURCES = $(GENFILES)
>  nsm_client_LDADD = ../../support/nfs/libnfs.a \
> -		   ../../support/nsm/libnsm.a $(LIBCAP)
> +		   ../../support/nsm/libnsm.a $(LIBCAP) $(LIBTIRPC)
>  
>  if CONFIG_RPCGEN
>  RPCGEN	= $(top_builddir)/tools/rpcgen/rpcgen
> 
