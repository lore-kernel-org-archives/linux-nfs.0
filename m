Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:61500 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755760Ab2B2Us5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Feb 2012 15:48:57 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q1TKmvcI006306
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 29 Feb 2012 15:48:57 -0500
Message-ID: <4F4E8F3A.8070708@RedHat.com>
Date: Wed, 29 Feb 2012 15:48:58 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Gregor Gruener <ggruner@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2.6.32-131.6.1.el6.x86_64] idmapd.c: deactivate the ASCII
 characters check
References: <4F4603EC.9030404@redhat.com>
In-Reply-To: <4F4603EC.9030404@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/23/2012 04:16 AM, Gregor Gruener wrote:
> Customers are using Unicode characters umlauts (ö,ä,ü) in group names and this
> creates problems with NFS ID Mapping. Groups with umlauts will be redirected to
> the group NFS "nobody".
> This patch deactivate the ASCII characters check. It's maybe more like a temporary fix and I think it would be nicer to
> adjust the check to support Unicode characters instead to deactivate the check.
> 
> ========================================================================================================
> 
> diff -Nurp nfs-utils-1.2.2/utils/idmapd/idmapd.c nfs-utils-1.2.2-fag/utils/idmapd/idmapd.c
> --- nfs-utils-1.2.2/utils/idmapd/idmapd.c    2010-02-18 13:35:00.000000000 +0100
> +++ nfs-utils-1.2.2-fag/utils/idmapd/idmapd.c    2011-10-05 09:09:05.815103100 +0200
> @@ -850,9 +850,6 @@ validateascii(char *string, u_int32_t le
>      for (i = 0; i<  len; i++) {
>          if (string[i] == '\0')
>              break;
> -
> -        if (string[i]&  0x80)
> -            return (-1);
>      }
> 
>      if ((i>= len) || string[i] != '\0')
> 
> 
> 
> =========================================================================================================
> 
> 
> 
> 
> Developer's Certificate of Origin 1.1
> 
>         By making a contribution to this project, I certify that:
> 
>         (a) The contribution was created in whole or in part by me and I
>             have the right to submit it under the open source license
>             indicated in the file; or
> 
>         (b) The contribution is based upon previous work that, to the best
>             of my knowledge, is covered under an appropriate open source
>             license and I have the right under that license to submit that
>             work with modifications, whether created in whole or in part
>             by me, under the same open source license (unless I am
>             permitted to submit under a different license), as indicated
>             in the file; or
> 
>         (c) The contribution was provided directly to me by some other
>             person who certified (a), (b) or (c) and I have not modified
>             it.
> 
>         (d) I understand and agree that this project and the contribution
>             are public and that a record of the contribution (including all
>             personal information I submit with it, including my sign-off) is
>             maintained indefinitely and may be redistributed consistent with
>             this project or the open source license(s) involved.
> 
> Signed-off-by: Gregor Gruener<ggruner@redhat.com>
Committed... 

steved.

> 
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
