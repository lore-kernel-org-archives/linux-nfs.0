Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55994 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932485AbdHWS7t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 23 Aug 2017 14:59:49 -0400
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id A34B4883BC
        for <linux-nfs@vger.kernel.org>; Wed, 23 Aug 2017 18:59:49 +0000 (UTC)
Subject: Re: [nfs-utils PATCH] idmapd: fix object order in idmapd_LDADD
To: Scott Mayhew <smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
References: <20170807190906.7360-1-smayhew@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <9a30111e-71f9-f502-0e36-09a1fedf5b60@RedHat.com>
Date: Wed, 23 Aug 2017 14:59:48 -0400
MIME-Version: 1.0
In-Reply-To: <20170807190906.7360-1-smayhew@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/07/2017 03:09 PM, Scott Mayhew wrote:
> nfs-utils and libnfsidmap have similar configuration parsing routines.
> They were the same up until nfs-utils commit 7b33590f (config: Remove
> the conf_path global), where conf_init() was changed to take a path as
> an argument.  With the current idmap_LDADD ordering in Makefile.am, the
> conf_init() from libnfsidmap is called, resulting in the following error
> along with the failure to parse idmapd.conf:
> 
> rpc.idmapd[391]: rpc.idmapd: conf_reinit: open ("(null)", O_RDONLY) failed
> 
> Placing libnfs.a first in idmap_LDADD ensures that idmapd uses the config
> parsing routines from nfs-utils instead of libnfsidmap.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed.... 

steved.
> ---
>  utils/idmapd/Makefile.am | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/utils/idmapd/Makefile.am b/utils/idmapd/Makefile.am
> index c2f8ba1..1e8e9e6 100644
> --- a/utils/idmapd/Makefile.am
> +++ b/utils/idmapd/Makefile.am
> @@ -15,7 +15,7 @@ idmapd_SOURCES = \
>  	nfs_idmap.h \
>  	queue.h
>  
> -idmapd_LDADD = $(LIBEVENT) $(LIBNFSIDMAP) ../../support/nfs/libnfs.a
> +idmapd_LDADD = ../../support/nfs/libnfs.a $(LIBEVENT) $(LIBNFSIDMAP)
>  
>  MAINTAINERCLEANFILES = Makefile.in
>  
> 
