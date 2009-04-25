From: Greg Banks <gnb-xTcybq6BZ68@public.gmane.org>
Subject: Re: [patch 01/29] knfsd: Add infrastructure for measuring RPC service
	times.
Date: Sat, 25 Apr 2009 12:52:44 +1000
Message-ID: <ac442c870904241952sc37bb42kcb77146e4ec0fab5@mail.gmail.com>
References: <20090331202800.739621000@sgi.com>
	 <20090331202937.980076000@sgi.com>
	 <20090425021315.GA24770@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:46377 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751762AbZDYCwp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2009 22:52:45 -0400
Received: by qw-out-2122.google.com with SMTP id 5so1193324qwd.37
        for <linux-nfs@vger.kernel.org>; Fri, 24 Apr 2009 19:52:44 -0700 (PDT)
In-Reply-To: <20090425021315.GA24770@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Apr 25, 2009 at 12:13 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Wed, Apr 01, 2009 at 07:28:01AM +1100, Greg Banks wrote:
>> Two new functions; svc_time_mark() remembers the current time
>> in a struct svc_time; svc_time_elapsed() calculates and returns
>> the time since a svc_time was marked.
>>
>> Signed-off-by: Greg Banks <gnb@sgi.com>
>> ---
>>
>>  include/linux/sunrpc/svc.h |   12 ++++++++++++
>>  net/sunrpc/svc.c           |   25 +++++++++++++++++++++++++
>>  2 files changed, 37 insertions(+)
>>
>> Index: bfields/include/linux/sunrpc/svc.h
>> ===================================================================
>> --- bfields.orig/include/linux/sunrpc/svc.h
>> +++ bfields/include/linux/sunrpc/svc.h
>> @@ -18,6 +18,16 @@
>>  #include <linux/sunrpc/svcauth.h>
>>  #include <linux/wait.h>
>>  #include <linux/mm.h>
>> +#include <linux/time.h>
>> +
>> +/*
>> + * Structure used to implement a fast lockless elapsed time measure.
>> + */
>> +struct svc_time
>> +{
>> +     struct timespec st_spec;
>> +};
>
> Are struct svc_time, ...
>
>> +void
>> +svc_time_mark(struct svc_time *st)
>> +{
>> +     getnstimeofday(&st->st_spec);
>> +}
>> +EXPORT_SYMBOL(svc_time_mark);
>
> ... and this function really necessary?  If you're not too attached to
> them: it would seem simpler just to use struct timespec and
> getnstimeofday directly.  (Well, at least simpler to read for someone
> familiar with the kernel but not with th nfs code.)

To be quite frank, no.  They're historical; they were very necessary
in the original SLES10-based version of these patches because that
ancient kernel was missing some important time infrastructure bits.
In that code, the structure and functions did some very hairy and
arch-specific things involving jiffies and ITC/TSC registers.  I was
being lazy by not eliding them during forward porting, and I'll do so
in the next version.

-- 
Greg.
