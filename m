Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33162 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753793AbdAECqJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jan 2017 21:46:09 -0500
Subject: Re: [PATCH v5 1/2] sysctl: introduce new proc handler proc_dobool
To: Alexey Dobriyan <adobriyan@gmail.com>
References: <1481786661-973-1-git-send-email-hejianet@gmail.com>
 <1481786661-973-2-git-send-email-hejianet@gmail.com>
 <20170104210933.GB21562@fieldses.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Dmitry Torokhov <dmitry.torokhov@gmail.com>,
        Serge Hallyn <serge@hallyn.com>,
        "David S. Miller" <davem@davemloft.net>,
        Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Mel Gorman <mgorman@techsingularity.net>,
        Kees Cook <keescook@chromium.org>, Hugh Dickins <hughd@google.com>,
        Daniel Bristot de Oliveira <bristot@redhat.com>,
        Daniel Cashman <dcashman@google.com>, Arnd Bergmann <arnd@arndb.de>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
From: hejianet <hejianet@gmail.com>
Message-ID: <1986753d-d7f7-120d-f6ec-011896b54849@gmail.com>
Date: Thu, 5 Jan 2017 10:45:46 +0800
MIME-Version: 1.0
In-Reply-To: <20170104210933.GB21562@fieldses.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/01/2017 5:09 AM, J. Bruce Fields wrote:
> On Thu, Dec 15, 2016 at 03:24:20PM +0800, Jia He wrote:
>> This is to let bool variable could be correctly displayed in
>> big/little endian sysctl procfs. sizeof(bool) is arch dependent,
>> proc_dobool should work in all arches.
> Did Alexey Debriyan agree that this dealt with his objections?
Hi Alexey, any thoughts? ;-)
Thanks

B.R.
Jia
> Also it'd be nice to have a sign-off from somebody that's actually
> touched sysctl.c.  Then I could take it through the nfsd tree if that
> doesn't cause anyone trouble.
>
> --b.
>
>> Suggested-by: Pan Xinhui <xinhui@linux.vnet.ibm.com>
>> Signed-off-by: Jia He <hejianet@gmail.com>
>> ---
>>   include/linux/sysctl.h |  2 ++
>>   kernel/sysctl.c        | 41 +++++++++++++++++++++++++++++++++++++++++
>>   2 files changed, 43 insertions(+)
>>
>> diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
>> index adf4e51..255a9c7 100644
>> --- a/include/linux/sysctl.h
>> +++ b/include/linux/sysctl.h
>> @@ -41,6 +41,8 @@ typedef int proc_handler (struct ctl_table *ctl, int write,
>>   
>>   extern int proc_dostring(struct ctl_table *, int,
>>   			 void __user *, size_t *, loff_t *);
>> +extern int proc_dobool(struct ctl_table *, int,
>> +			void __user *, size_t *, loff_t *);
>>   extern int proc_dointvec(struct ctl_table *, int,
>>   			 void __user *, size_t *, loff_t *);
>>   extern int proc_douintvec(struct ctl_table *, int,
>> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
>> index 706309f..c4bec65 100644
>> --- a/kernel/sysctl.c
>> +++ b/kernel/sysctl.c
>> @@ -2112,6 +2112,20 @@ static int proc_put_char(void __user **buf, size_t *size, char c)
>>   	return 0;
>>   }
>>   
>> +static int do_proc_dobool_conv(bool *negp, unsigned long *lvalp,
>> +				int *valp,
>> +				int write, void *data)
>> +{
>> +	if (write)
>> +		*(bool *)valp = *lvalp;
>> +	else {
>> +		int val = *(bool *)valp;
>> +
>> +		*lvalp = (unsigned long)val;
>> +	}
>> +	return 0;
>> +}
>> +
>>   static int do_proc_dointvec_conv(bool *negp, unsigned long *lvalp,
>>   				 int *valp,
>>   				 int write, void *data)
>> @@ -2258,6 +2272,26 @@ static int do_proc_dointvec(struct ctl_table *table, int write,
>>   }
>>   
>>   /**
>> + * proc_dobool - read/write a bool
>> + * @table: the sysctl table
>> + * @write: %TRUE if this is a write to the sysctl file
>> + * @buffer: the user buffer
>> + * @lenp: the size of the user buffer
>> + * @ppos: file position
>> + *
>> + * Reads/writes up to table->maxlen/sizeof(unsigned int) integer
>> + * values from/to the user buffer, treated as an ASCII string.
>> + *
>> + * Returns 0 on success.
>> + */
>> +int proc_dobool(struct ctl_table *table, int write,
>> +		void __user *buffer, size_t *lenp, loff_t *ppos)
>> +{
>> +	return do_proc_dointvec(table, write, buffer, lenp, ppos,
>> +				do_proc_dobool_conv, NULL);
>> +}
>> +
>> +/**
>>    * proc_dointvec - read a vector of integers
>>    * @table: the sysctl table
>>    * @write: %TRUE if this is a write to the sysctl file
>> @@ -2885,6 +2919,12 @@ int proc_dostring(struct ctl_table *table, int write,
>>   	return -ENOSYS;
>>   }
>>   
>> +int proc_dobool(struct ctl_table *table, int write,
>> +                  void __user *buffer, size_t *lenp, loff_t *ppos)
>> +{
>> +        return -ENOSYS;
>> +}
>> +
>>   int proc_dointvec(struct ctl_table *table, int write,
>>   		  void __user *buffer, size_t *lenp, loff_t *ppos)
>>   {
>> @@ -2941,6 +2981,7 @@ int proc_doulongvec_ms_jiffies_minmax(struct ctl_table *table, int write,
>>    * No sense putting this after each symbol definition, twice,
>>    * exception granted :-)
>>    */
>> +EXPORT_SYMBOL(proc_dobool);
>>   EXPORT_SYMBOL(proc_dointvec);
>>   EXPORT_SYMBOL(proc_douintvec);
>>   EXPORT_SYMBOL(proc_dointvec_jiffies);
>> -- 
>> 2.5.5

