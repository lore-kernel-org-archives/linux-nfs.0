Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f44.google.com ([209.85.192.44]:36383 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752428AbaEWOVL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 May 2014 10:21:11 -0400
Received: by mail-qg0-f44.google.com with SMTP id i50so8269566qgf.31
        for <linux-nfs@vger.kernel.org>; Fri, 23 May 2014 07:21:10 -0700 (PDT)
Message-ID: <537F5940.7060908@gmail.com>
Date: Fri, 23 May 2014 22:20:48 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/5] NFSD: Cleanup unneeded including linux/user_namespace.h
References: <537F44B1.6080507@gmail.com> <20140523141855.GN25423@fieldses.org>
In-Reply-To: <20140523141855.GN25423@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 5/23/2014 22:18, J. Bruce Fields wrote:
> Thanks, applied all five.
> 
> On Fri, May 23, 2014 at 08:53:05PM +0800, Kinglong Mee wrote:
>> commit 4c1e1b34d5c800ad3ac9a7e2805b0bea70ad2278 using kuid/kgid for
> 
> In future, when referring to another commit, could you also include the
> summary line?  E.g.: Commit 8f6c5ffc8987 ("kernel/groups.c: remove
> return value of set_groups") removed the last use of "ret"....

Got it, i will do that in the future.

thanks,
Kinglong Mee

> 
> --b.
> 
>> ex_anon_uid/ex_anon_gid, user_namespace.h is not needed now, clean it.
>>
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>>  fs/nfsd/auth.c | 1 -
>>  1 file changed, 1 deletion(-)
>>
>> diff --git a/fs/nfsd/auth.c b/fs/nfsd/auth.c
>> index 2645be4..1042325 100644
>> --- a/fs/nfsd/auth.c
>> +++ b/fs/nfsd/auth.c
>> @@ -1,7 +1,6 @@
>>  /* Copyright (C) 1995, 1996 Olaf Kirch <okir@monad.swb.de> */
>>  
>>  #include <linux/sched.h>
>> -#include <linux/user_namespace.h>
>>  #include "nfsd.h"
>>  #include "auth.h"
>>  
>> -- 
>> 1.9.3
>>
> 
