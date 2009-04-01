From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [Bugme-new] [Bug 12995] New: NFS mount from avr32 platform crashes on 2.6.29
Date: Wed, 1 Apr 2009 15:50:51 -0400
Message-ID: <AD89F6AE-DD50-4D8E-9C94-A403E9AFFC8C@oracle.com>
References: <bug-12995-10286@http.bugzilla.kernel.org/> <20090401124113.9026ea09.akpm@linux-foundation.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: brm-EoLPgbz1DBzQT0dZR+AlfA@public.gmane.org, bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org,
	Olaf Kirch <okir@suse.de>, linux-nfs@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:17455 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754921AbZDATwV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2009 15:52:21 -0400
In-Reply-To: <20090401124113.9026ea09.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 1, 2009, at 3:41 PM, Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not  
> via the
> bugzilla web interface).
>
> On Wed, 1 Apr 2009 12:31:51 GMT
> bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org wrote:
>
>> http://bugzilla.kernel.org/show_bug.cgi?id=12995
>>
>>           Summary: NFS mount from avr32 platform crashes on 2.6.29
>>           Product: File System
>>           Version: 2.5
>>          Platform: All
>>        OS/Version: Linux
>>              Tree: Mainline
>>            Status: NEW
>>          Severity: normal
>>          Priority: P1
>>         Component: NFS
>>        AssignedTo: trond.myklebust@fys.uio.no
>>        ReportedBy: brm-EoLPgbz1DBzQT0dZR+AlfA@public.gmane.org
>>        Regression: No
>>
>>
>> The problem turns out to be in the recent(ish) changes in lockd.
>>
>> Specifically this struct definition
>>
>> struct nsm_handle {
>>        struct list_head        sm_link;
>>        atomic_t                sm_count;
>>        char                    *sm_mon_name;
>>        char                    *sm_name;
>>        struct sockaddr_storage sm_addr;
>>        size_t                  sm_addrlen;
>>        unsigned int            sm_monitored : 1,
>>                                sm_sticky : 1;  /* don't unmonitor */
>>        struct nsm_private      sm_priv;
>>        char                    sm_addrbuf[NSM_ADDRBUF];
>> };
>>
>> results in my avr32 compiler (and my ia64 compiler) in aligning the  
>> sm_priv
>> structure (which is a char array) on an odd boundary. The  
>> subsequent use
>> of this field typecast to a u64 (nsm_init_private) as part of an  
>> nfs mount
>> causes a crash with unaligned access.
>>
>> The compiler only allocates *one byte* to the two bit bitfield.
>> Moving the bitfield to the end of the structure fixes the problem  
>> in my case.
>> It seems to me that one should be very careful with typecasting  
>> this sm_priv
>> data to anything with larger alignment but especially to a 64 bit  
>> type since
>> (at least on a 64 bit system) this may demand 64 bit alignment.
>>
>> In any case it looks like (with newer gcc at least) that bitfields  
>> are
>> extremely dangerous.
>>
>> Perhaps the solution is to malloc the nsm_private data and sm_priv  
>> is then a
>> pointer to this data. This would guarantee the correct alignment.
>>
>
> nsm_private is:
>
> struct nsm_private {
> 	unsigned char		data[SM_PRIV_SIZE];
> };
>
> so the compiler is permitted to byte-align this.
>
> I assume that some code somewhere is accessing this with a
> larger-than-one-byte typecast?

nsm_init_private().

A patch just went upstream for 2.6.30 that addresses that, but did not  
mention that it fixed an oops.

> (Your bug report isn't complete - if it had included the trace then  
> I'd
> know where the crash is occurring!)
>
> If so then something like this:
>
> --- a/include/linux/lockd/xdr.h~a
> +++ a/include/linux/lockd/xdr.h
> @@ -9,6 +9,7 @@
> #ifndef LOCKD_XDR_H
> #define LOCKD_XDR_H
>
> +#include <linux/compiler.h>
> #include <linux/fs.h>
> #include <linux/nfs.h>
> #include <linux/sunrpc/xdr.h>
> @@ -16,9 +17,10 @@
> #define SM_MAXSTRLEN		1024
> #define SM_PRIV_SIZE		16
>
> +/* suitable comment about the __aligned goes here */
> struct nsm_private {
> 	unsigned char		data[SM_PRIV_SIZE];
> -};
> +} __aligned(sizeof(unsigned long));

>  struct svc_rqst;
>
> would be an appropriate fix, as it actually expresses what's going on.
>
> If you agree then please cook up and test a patch?
>
> Please send the patch via email - we very much try to avoid merging
> patches out of bugzilla.
>
> Thanks.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
