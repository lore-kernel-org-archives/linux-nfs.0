From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [Bugme-new] [Bug 12995] New: NFS mount from avr32 platform crashes on 2.6.29
Date: Wed, 1 Apr 2009 16:34:53 -0400
Message-ID: <EB32620C-ECA2-490E-A07D-72F0900EBC35@oracle.com>
References: <bug-12995-10286@http.bugzilla.kernel.org/> <20090401124113.9026ea09.akpm@linux-foundation.org> <AD89F6AE-DD50-4D8E-9C94-A403E9AFFC8C@oracle.com> <20090401130726.8a305e43.akpm@linux-foundation.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: brm-EoLPgbz1DBzQT0dZR+AlfA@public.gmane.org, bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, okir@suse.de,
	linux-nfs@vger.kernel.org, stable@kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:43280 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbZDAUhD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2009 16:37:03 -0400
In-Reply-To: <20090401130726.8a305e43.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 1, 2009, at 4:07 PM, Andrew Morton wrote:
> (cc stable)
>
> On Wed, 1 Apr 2009 15:50:51 -0400
> Chuck Lever <chuck.lever@oracle.com> wrote:
>
>>>>
>>>> Perhaps the solution is to malloc the nsm_private data and sm_priv
>>>> is then a
>>>> pointer to this data. This would guarantee the correct alignment.
>>>>
>>>
>>> nsm_private is:
>>>
>>> struct nsm_private {
>>> 	unsigned char		data[SM_PRIV_SIZE];
>>> };
>>>
>>> so the compiler is permitted to byte-align this.
>>>
>>> I assume that some code somewhere is accessing this with a
>>> larger-than-one-byte typecast?
>>
>> nsm_init_private().
>>
>> A patch just went upstream for 2.6.30 that addresses that
>
> commit ad5b365c1266b0c9e8e254a3c1cc4ef66bf33cba
> Author:     Mans Rullgard <mans-2StjZFpD7GcAvxtiuMwx3w@public.gmane.org>
> AuthorDate: Sat Mar 28 19:55:20 2009 +0000
> Commit:     Trond Myklebust <Trond.Myklebust@netapp.com>
> CommitDate: Wed Apr 1 13:24:14 2009 -0400
>
>    NSM: Fix unaligned accesses in nsm_init_private()
>
>    This fixes unaligned accesses in nsm_init_private() when
>    creating nlm_reboot keys.
>
>    Signed-off-by: Mans Rullgard <mans-2StjZFpD7GcAvxtiuMwx3w@public.gmane.org>
>    Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
>    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>
> diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
> index 5e2c4d5..6d5d4a4 100644
> --- a/fs/lockd/mon.c
> +++ b/fs/lockd/mon.c
> @@ -16,6 +16,8 @@
> #include <linux/sunrpc/svc.h>
> #include <linux/lockd/lockd.h>
>
> +#include <asm/unaligned.h>
> +
> #define NLMDBG_FACILITY		NLMDBG_MONITOR
> #define NSM_PROGRAM		100024
> #define NSM_VERSION		1
> @@ -274,10 +276,12 @@ static void nsm_init_private(struct nsm_handle  
> *nsm)
> {
> 	u64 *p = (u64 *)&nsm->sm_priv.data;
> 	struct timespec ts;
> +	s64 ns;
>
> 	ktime_get_ts(&ts);
> -	*p++ = timespec_to_ns(&ts);
> -	*p = (unsigned long)nsm;
> +	ns = timespec_to_ns(&ts);
> +	put_unaligned(ns, p);
> +	put_unaligned((unsigned long)nsm, p + 1);
> }
>
> static struct nsm_handle *nsm_create_handle(const struct sockaddr  
> *sap,
>
> Is this the best way of fixing it?  We'll crash again if some other
> code starts to access .data with non-byte-sized accesses.  What makes
> this especially risky is that the code will pass testing on x86.
>
> __aligned would be one way.  But it would be far far cleaner to just  
> do
>
>
> --- a/include/linux/lockd/xdr.h~a
> +++ a/include/linux/lockd/xdr.h
> @@ -17,7 +17,7 @@
> #define SM_PRIV_SIZE		16
>
> struct nsm_private {
> -	unsigned char		data[SM_PRIV_SIZE];
> +	u64 data[SM_PRIV_SIZE/sizeof(u64)];
> };
>
> struct svc_rqst;
>
> all the typecasting and the put_unaligned()s just go away then.

True enough.  It should be noted, however, that opaque data types are  
defined as character arrays in most RPC implementations, and by  
automated code generators like rpcgen.  The size of an RPC opaque type  
is usually expressed by a number of octets.

In general it may be best to keep that tradition (due to a large body  
of legacy code) and always use __aligned, simply because that clearly  
documents the problem that is being fixed.

>> but did not mention that it fixed an oops.
>
> That was a fairly significant failing.  Guys, please please do  
> remember
> that we're also maintaining the stable kernels.  When merging a patch
> please always think whether it needs to be backported.


--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
