Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36431 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751266AbcLLHtE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Dec 2016 02:49:04 -0500
Received: by mail-pg0-f68.google.com with SMTP id x23so205644pgx.3
        for <linux-nfs@vger.kernel.org>; Sun, 11 Dec 2016 23:49:04 -0800 (PST)
Subject: Re: [PATCH v2 2/2] lockd: change the proc_handler for
 nsm_use_hostnames from int to u8
To: "Eric W. Biederman" <ebiederm@xmission.com>
References: <1481527065-26109-1-git-send-email-hejianet@gmail.com>
 <1481527065-26109-3-git-send-email-hejianet@gmail.com>
 <87inqphaba.fsf@xmission.com>
Cc: linux-nfs@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
        Dmitry Torokhov <dmitry.torokhov@gmail.com>,
        Serge Hallyn <serge@hallyn.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Dobriyan <adobriyan@gmail.com>,
        Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Mel Gorman <mgorman@techsingularity.net>,
        Kees Cook <keescook@chromium.org>, Hugh Dickins <hughd@google.com>,
        Daniel Bristot de Oliveira <bristot@redhat.com>,
        Daniel Cashman <dcashman@google.com>, Arnd Bergmann <arnd@arndb.de>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, Olaf Kirch <okir@suse.de>
From: hejianet <hejianet@gmail.com>
Message-ID: <9daaf5a9-b233-9998-9d0a-26054b636b06@gmail.com>
Date: Mon, 12 Dec 2016 15:48:12 +0800
MIME-Version: 1.0
In-Reply-To: <87inqphaba.fsf@xmission.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Eric


On 12/12/16 3:32 PM, Eric W. Biederman wrote:
> Added Olaf Kirch the originator of nsm_use_hostnames to the cc.
>
> Jia He <hejianet@gmail.com> writes:
>
>> nsm_use_hostnames is a module paramter and it will be exported to sysctl
>> procfs. This is to let user sometimes change it from userspace. But the
>> minimal unit for sysctl procfs read/write it sizeof(int).
>> In big endian system, the converting from/to  bool to/from int will cause
>> error for proc items.
>>
>> This patch use a new proc_handler proc_dou8vec.
>>
>> Suggested-by: Pan Xinhui <xinhui@linux.vnet.ibm.com>
>> Signed-off-by: Jia He <hejianet@gmail.com>
>> ---
>>   fs/lockd/svc.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
>> index fc4084e..7a4ad9d 100644
>> --- a/fs/lockd/svc.c
>> +++ b/fs/lockd/svc.c
>> @@ -561,7 +561,7 @@ static struct ctl_table nlm_sysctls[] = {
>>   		.data		= &nsm_use_hostnames,
>>   		.maxlen		= sizeof(int),
>>   		.mode		= 0644,
>> -		.proc_handler	= proc_dointvec,
>> +		.proc_handler	= proc_dou8vec,
> proc_dou8vec does not exist in my tree so I don't know what it does,
> but if it's name is accurate this change is wrong.  As the maxlen has
> not changed so you are implying that it is a vector of u8 and
> sizeof(int) long.
Please see my previous patch mail in the same thread.
The new proc handler looks like:
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -2112,6 +2112,30 @@ static int proc_put_char(void __user **buf, size_t *size, 
char c)
         return 0;
  }

+
+static int do_proc_dou8vec_conv(bool *negp, unsigned long *lvalp,
+                               int *valp,
+                               int write, void *data)
+{
+       if (write) {
+               if (*negp)
+                       *(u8 *)valp = -*lvalp;
+               else
+                       *(u8 *)valp = *lvalp;
+       } else {
+               int val = *(u8 *)valp;
+
+               if (val < 0) {
+                       *negp = true;
+                       *lvalp = -(unsigned long)val;
+               } else {
+                       *negp = false;
+                       *lvalp = (unsigned long)val;
+               }
+       }
+       return 0;
+}
+

[...]
+int proc_dou8vec(struct ctl_table *table, int write,
+               void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+       return do_proc_dointvec(table, write, buffer, lenp, ppos,
+                               do_proc_dou8vec_conv, NULL);
+}
+
I didn't change much logic in
do_proc_dou8vec_conv compared with do_proc_dointvec_cov.
Just let the variable int *valp be used as a (u8 *)
>
> Further this is wrong if nsm_use_hostnames is a bool as this sysctl
> can be assigned values that are out of bounds for a bool.
I thought even without this patch, the assignment is also _correct_.
The error is just the output of procfs and sysctl
>
> Furthermore this is wrong in that a bool is not necessarily a u8, the
> size of bool is very architecture dependent.  So for either
> nsm_use_hostnames needs to become an int, a proc_dobool helper needs
> to be added, or the sysctl needs to be removed entirely as module
> parameters can be edited at runtime through sysfs.
Yes, ;) this is what I did in Patchv1: change nsm_use_hostnames from
bool to u32/int. But as suggested by Pan Xinhui, I thought Patchv3
is better.
e.g. you can insmod lockd.ko nsm_use_hostnames=y if nsm_use_hostnames
is still bool type

>
> But I completely agree that this decade old bug needs to be fixed.
indeed
> Eric
>
>
>>   	},
>>   	{
>>   		.procname	= "nsm_local_state",

