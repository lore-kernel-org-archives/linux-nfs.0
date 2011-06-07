Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:44470 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919Ab1FGSYq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 14:24:46 -0400
Message-ID: <4DEE6CEA.8000909@candelatech.com>
Date: Tue, 07 Jun 2011 11:24:42 -0700
From: Ben Greear <greearb@candelatech.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Fix build on Fedora 13.
References: <1307469531-20595-1-git-send-email-greearb@candelatech.com> <E9E39B04-8045-44EF-970B-A1F1779C5A69@oracle.com>
In-Reply-To: <E9E39B04-8045-44EF-970B-A1F1779C5A69@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/07/2011 11:14 AM, Chuck Lever wrote:
> Hi Ben-
>
> On Jun 7, 2011, at 1:58 PM, greearb@candelatech.com wrote:
>
>> From: Ben Greear<greearb@candelatech.com>
>>
>> Need sys/stat.h for S_ISDIR and S_ISREG symbols.
>
> Can you tell when this problem was introduced?  What ./configure options might be relevant?

I haven't compiled nfs-utils in years.  Since I can't get ./configure to find libgssapi,
I'm compiling with:

./configure --disable-gss


Thanks,
Ben

>
>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>> ---
>> :100644 100644 99618c9... e057c5c... M	utils/exportfs/exportfs.c
>> :100644 100644 2aa3d4f... a8ce028... M	utils/mount/mount.c
>> utils/exportfs/exportfs.c |    4 ++++
>> utils/mount/mount.c       |    3 +++
>> 2 files changed, 7 insertions(+), 0 deletions(-)
>>
>> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
>> index 99618c9..e057c5c 100644
>> --- a/utils/exportfs/exportfs.c
>> +++ b/utils/exportfs/exportfs.c
>> @@ -12,6 +12,10 @@
>> #include<config.h>
>> #endif
>>
>> +#ifdef HAVE_SYS_STAT_H
>> +#include<sys/stat.h>
>> +#endif
>> +
>> #include<unistd.h>
>> #include<stdlib.h>
>> #include<string.h>
>> diff --git a/utils/mount/mount.c b/utils/mount/mount.c
>> index 2aa3d4f..a8ce028 100644
>> --- a/utils/mount/mount.c
>> +++ b/utils/mount/mount.c
>> @@ -20,6 +20,9 @@
>>
>> #include "config.h"
>> #include<unistd.h>
>> +#ifdef HAVE_SYS_STAT_H
>> +#include<sys/stat.h>
>> +#endif
>> #include<sys/types.h>
>> #include<stdio.h>
>> #include<string.h>
>> --
>> 1.7.3.4
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

