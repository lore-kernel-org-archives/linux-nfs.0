Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:59355 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754655Ab2EQM3P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 May 2012 08:29:15 -0400
Message-ID: <4FB4EEFB.7070102@RedHat.com>
Date: Thu, 17 May 2012 08:28:43 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jim Rees <rees@umich.edu>
CC: Mike Frysinger <vapier@gentoo.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] osd_login: fix DESTDIR install
References: <1337232243-18088-1-git-send-email-vapier@gentoo.org> <20120517115330.GA3733@umich.edu>
In-Reply-To: <20120517115330.GA3733@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Jim,

On 05/17/2012 07:53 AM, Jim Rees wrote:
> Mike Frysinger wrote:
> 
>   diff --git a/utils/osd_login/Makefile.am b/utils/osd_login/Makefile.am
>   index adc493a..c85584c 100644
>   --- a/utils/osd_login/Makefile.am
>   +++ b/utils/osd_login/Makefile.am
>   @@ -1,12 +1,11 @@
>    ## Process this file with automake to produce Makefile.in
>    
>   -OSD_LOGIN_FILES= osd_login
>   -
>   -EXTRA_DIST= $(OSD_LOGIN_FILES)
>   +# These scripts go in /sbin (not /usr/sbin), and that cannot be
>   +# overriden at config time.
>   +sbindir = /sbin
> 
> You misspelled "overridden."  Yes, I know you just copied this line from
> mount/Makefile.am, but there is no sense compounding the error.
Thanks for pointing out the misspelling in mount/Makefile.am... its
been corrected... 

steved.

> 
> Also it might be worth mentioning in the comment why we have this
> restriction.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
