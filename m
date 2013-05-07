Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:17312 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756820Ab3EGP7w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 May 2013 11:59:52 -0400
Message-ID: <518924F3.5090208@RedHat.com>
Date: Tue, 07 May 2013 11:59:47 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: Simo Sorce <simo@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Avoid DNS reverse resolution for server names (take 3)
References: <1366380998-2581-1-git-send-email-steved@redhat.com> <20130502131332.5c0ce2b0@notabene.brown> <20130502165302.593ec4b6@notabene.brown>
In-Reply-To: <20130502165302.593ec4b6@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/05/13 02:53, NeilBrown wrote:
> On Thu, 2 May 2013 13:13:32 +1000 NeilBrown <neilb@suse.de> wrote:
> 
> 
>> Possible patch below.
> 
> BTW if you end up applying that without requiring a second revision, please
> add
> 
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -67,7 +67,6 @@
>  #include <errno.h>
>  #include <gssapi/gssapi.h>
>  #include <netdb.h>
> -#include <ctype.h>
>  
>  #include "gssd.h"
>  #include "err_util.h"
> 
> 
> original patch added this include, but doesn't need it.
Fixed... 

steved.

> 
> NeilBrown
> 
