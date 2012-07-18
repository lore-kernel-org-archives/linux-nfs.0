Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:55691 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123Ab2GRVmh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Jul 2012 17:42:37 -0400
Message-ID: <50072DEE.2000205@gmail.com>
Date: Wed, 18 Jul 2012 23:43:10 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Jim Rees <rees@umich.edu>, Trond.Myklebust@netapp.com, davem@davemloft.net,
        davej@redhat.com, linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: Prevent kernel stack corruption on long values
 of flush
References: <1342476086-21638-1-git-send-email-levinsasha928@gmail.com> <20120718173913.GA1298@fieldses.org> <20120718200049.GA17964@umich.edu> <20120718210825.GA3145@fieldses.org> <50072BA7.6070205@gmail.com>
In-Reply-To: <50072BA7.6070205@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/18/2012 11:33 PM, Sasha Levin wrote:
> On 07/18/2012 11:08 PM, J. Bruce Fields wrote:
>> On Wed, Jul 18, 2012 at 04:00:49PM -0400, Jim Rees wrote:
>>> J. Bruce Fields wrote:
>>>
>>>   On Tue, Jul 17, 2012 at 12:01:26AM +0200, Sasha Levin wrote:
>>>   > The buffer size in read_flush() is too small for the longest possible values
>>>   > for it. This can lead to a kernel stack corruption:
>>>   
>>>   Thanks!
>>>   
>>>   > 
>>>   > diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
>>>   > index 2afd2a8..f86d95e 100644
>>>   > --- a/net/sunrpc/cache.c
>>>   > +++ b/net/sunrpc/cache.c
>>>   > @@ -1409,11 +1409,11 @@ static ssize_t read_flush(struct file *file, char __user *buf,
>>>   >  			  size_t count, loff_t *ppos,
>>>   >  			  struct cache_detail *cd)
>>>   >  {
>>>   > -	char tbuf[20];
>>>   > +	char tbuf[22];
>>>   
>>>   I wonder how common this sort of calculation is in the kernel?  It might
>>>   provide some peace of mind to be able to write this something like
>>>   
>>>   	char tbuf[MAXLEN_BASE10_UL + 2]  /* + 2 for final "\n\0" */
>>>
>>> You could use something like:
>>>
>>>     char tbuf[sizeof (unsigned long) * 24 / 10 + 1 + 2]; /* + 2 for final "\n\0" */
>>>
>>> since there are roughly 10 bits for every 3 decimal digits.
>>
>> So we could do something like this.  OK, I'm not sure I care enough.
>>
>> --b.
>>
>> diff --git a/include/linux/string.h b/include/linux/string.h
>> index e033564..ed34180 100644
>> --- a/include/linux/string.h
>> +++ b/include/linux/string.h
>> @@ -126,6 +126,10 @@ extern void argv_free(char **argv);
>>  extern bool sysfs_streq(const char *s1, const char *s2);
>>  extern int strtobool(const char *s, bool *res);
>>  
>> +/* length of the decimal representation of an unsigned integer.  Just an
>> + * approximation, but it's right for types of size 1 to 36 bytes: */
>> +#define base10len(i) (sizeof(i) * 24 / 10 + 1)
>> +
>>  #ifdef CONFIG_BINARY_PRINTF
>>  int vbin_printf(u32 *bin_buf, size_t size, const char *fmt, va_list args);
>>  int bstr_printf(char *buf, size_t size, const char *fmt, const u32 *bin_buf);
>> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
>> index 2afd2a8..1dcd2b3 100644
>> --- a/net/sunrpc/cache.c
>> +++ b/net/sunrpc/cache.c
>> @@ -1409,7 +1409,7 @@ static ssize_t read_flush(struct file *file, char __user *buf,
>>  			  size_t count, loff_t *ppos,
>>  			  struct cache_detail *cd)
>>  {
>> -	char tbuf[20];
>> +	char tbuf[base10len(unsigned long) + 2];
>>  	unsigned long p = *ppos;
>>  	size_t len;
>>  
>>
> 
> Learning from what happened in this specific case, there are actually 2 issues here:
> 
>  - Array size was constant and too small, which is solved by the patch above.
>  - We were blindly trying to sprintf() into that array, this issue may pop back up if someone decides to change the format string forgetting to modify the array declaration.
> 
> What about adding the following itoa() type helper:

Fat fingers :(

Something like this (which obviously needs tons of work):

#define base10len(i) (sizeof(i) * 24 / 10 + 1)
#define itoa(x) \
({ \
        static char str[base10len(x)]; \
        sprintf(str, "%lu", (x)); \
        str; \
})


