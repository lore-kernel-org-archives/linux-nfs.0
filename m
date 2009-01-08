From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/1] rpc.statd: fix the failure of SM_DIR creation
Date: Thu, 8 Jan 2009 11:49:00 -0500
Message-ID: <EA19F964-2A6B-474C-836F-34804F535D0E@oracle.com>
References: <200901081345.n08Dje4F025471@rgminet15.oracle.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org, greg.marsden@oracle.com
To: wengang wang <wen.gang.wang@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:49864 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755573AbZAHQtK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jan 2009 11:49:10 -0500
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by rgminet12.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n08GmlvL008432
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 8 Jan 2009 16:48:49 GMT
Received: from acsmt701.oracle.com (acsmt701.oracle.com [141.146.40.71])
	by rgminet15.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n08Gn493016978
	for <linux-nfs@vger.kernel.org>; Thu, 8 Jan 2009 16:49:05 GMT
In-Reply-To: <200901081345.n08Dje4F025471-ZlU+UDTPhmH/PLQtoiUQIVaTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 8, 2009, at Jan 8, 2009, 8:44 AM, wengang wang wrote:
> Please let me if here is not the place talking about rpc.statd.
>
> this's going to talk about rpc.statd.
> in case SM_DIR doesn't exist, it may not be created.
> according code in shuffle_dirs(), since st is not initailized, whether
> the SM_DIR is created depends on the thread stack of rpc.statd.
> the fix is to insert a memset() before calling stat().
>
> #the patch is against nfs-utils 1.0.9

There is no utils/statd/state.c in the current nfs-utils repo (1.1.4  
+).  That code was replaced a year or two ago with a new split sm- 
notify / rpc.statd implementation from SuSE.

Can you take a look at the latest nfs-utils source code and see if the  
problem you encountered is in the new code base?  We have been  
discussing some changes in that area already, as the sm-notify code  
does a rename(2) in the state directory and then a sync(2) during  
system boot, and that causes a slow-down during system start-up.  The  
creation of that directory and those files was a key discussion point.

> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
> --
> state.c |    2 ++
> 1 file changed, 2 insertions(+)
> diff -up ./utils/statd/state.c.orig ./utils/statd/state.c
> --- ./utils/statd/state.c.orig	2009-01-08 20:32:44.000000000 +0800
> +++ ./utils/statd/state.c	2009-01-08 20:33:07.000000000 +0800
> @@ -89,6 +89,8 @@ shuffle_dirs (void)
>   char *src, *dst;
>   int len1, len2, len;
>
> +  memset (&st, 0, sizeof st);
> +
>   if (stat (SM_DIR, &st) == -1 && errno != ENOENT)
>     die ("stat (%s): %s", SM_DIR, strerror (errno));
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




