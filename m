Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:56287 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753781AbbFBP2h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Jun 2015 11:28:37 -0400
Date: Tue, 2 Jun 2015 11:28:32 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 02/10] svcrdma: Add missing access_ok() call in
 svc_rdma.c
Message-ID: <20150602152832.GA32413@fieldses.org>
References: <20150526174401.7061.43137.stgit@klimt.1015granger.net>
 <20150526174847.7061.52013.stgit@klimt.1015granger.net>
 <20150601193101.GA26972@fieldses.org>
 <AC101B2E-76A2-4196-9D03-921BF6DE7D77@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <AC101B2E-76A2-4196-9D03-921BF6DE7D77@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 01, 2015 at 04:01:15PM -0400, Chuck Lever wrote:
> 
> On Jun 1, 2015, at 3:31 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> > On Tue, May 26, 2015 at 01:48:47PM -0400, Chuck Lever wrote:
> >> Ensure a proper memory access check is done by read_reset_stat(),
> >> then fix the following compiler warning.
> >> 
> >> In file included from linux-2.6/include/net/checksum.h:25,
> >>                 from linux-2.6/include/linux/skbuff.h:31,
> >>                 from linux-2.6/include/linux/icmpv6.h:4,
> >>                 from linux-2.6/include/linux/ipv6.h:64,
> >>                 from linux-2.6/include/net/ipv6.h:16,
> >>                 from linux-2.6/include/linux/sunrpc/clnt.h:27,
> >>                 from linux-2.6/net/sunrpc/xprtrdma/svc_rdma.c:47:
> >> In function ‘copy_to_user’,
> >>    inlined from ‘read_reset_stat’ at
> >> linux-2.6/net/sunrpc/xprtrdma/svc_rdma.c:113:
> >> linux-2.6/arch/x86/include/asm/uaccess.h:735: warning:
> >> call to ‘__copy_to_user_overflow’ declared with attribute warning:
> >> copy_to_user() buffer size is not provably correct
> > 
> > How do you get that warning?  I can't hit it even with
> > CONFIG_USER_STRICT_USER_COPY_CHECKS set.  Based on comments in arch/x86
> > I would have thought this would only trigger when len was a constant.
> 
> I only seem to see this warning when building and testing on EL6, gcc
> version 4.4.7 20120313 (Red Hat 4.4.7-11) (GCC).
> 
> include/linux/compiler-gcc4.h has this:
> 
>  16 #if GCC_VERSION >= 40100 && GCC_VERSION < 40600
>  17 # define __compiletime_object_size(obj) __builtin_object_size(obj, 0)
>  18 #endif
> 
> and include/linux/compiler.h has this:
> 
> 384 #ifndef __compiletime_object_size
> 385 # define __compiletime_object_size(obj) -1
> 386 #endif
> 
> Now, arch/x86/include/asm/uaccess.h spells copy_to_user() this way:
> 
> 722 static inline unsigned long __must_check
> 723 copy_to_user(void __user *to, const void *from, unsigned long n)
> 724 {
> 725         int sz = __compiletime_object_size(from);
> 726 
> 727         might_fault();
> 728 
> 729         /* See the comment in copy_from_user() above. */
> 730         if (likely(sz < 0 || sz >= n))
> 731                 n = _copy_to_user(to, from, n);
> 732         else if(__builtin_constant_p(n))
> 733                 copy_to_user_overflow();
> 734         else
> 735                 __copy_to_user_overflow(sz, n);
> 736 
> 737         return n;
> 738 }
> 
> If __compiletime_object_size isn’t defined for your compiler version, then
> int sz is set to -1, and _copy_to_user() is invoked directly. Otherwise
> if n is a variable, the warning pops.
> 
> This might be a false positive. The “from” parameter is always 32 bytes in
> read_reset_stat().

Huh.  OK, I don't really understand this logic.

> I think adding an access_ok() call here is reasonable, though?

Well, we're just moving the access_ok() out of copy_to_user (by
switching to __copy_to_user) and doing it by hand ourselves instead.

It looks to me like the false positive is the bug.  The comments in
uaccess.h at least suggest that they did intend to avoid such false
positives.

Dropping this for now.

--b.

> 
> > --b.
> > 
> >> 
> >> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >> ---
> >> 
> >> net/sunrpc/xprtrdma/svc_rdma.c |    8 ++++++--
> >> 1 files changed, 6 insertions(+), 2 deletions(-)
> >> 
> >> diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
> >> index c1b6270..8eedb60 100644
> >> --- a/net/sunrpc/xprtrdma/svc_rdma.c
> >> +++ b/net/sunrpc/xprtrdma/svc_rdma.c
> >> @@ -98,7 +98,11 @@ static int read_reset_stat(struct ctl_table *table, int write,
> >> 	else {
> >> 		char str_buf[32];
> >> 		char *data;
> >> -		int len = snprintf(str_buf, 32, "%d\n", atomic_read(stat));
> >> +		int len;
> >> +
> >> +		if (!access_ok(VERIFY_WRITE, buffer, *lenp))
> >> +			return -EFAULT;
> >> +		len = snprintf(str_buf, 32, "%d\n", atomic_read(stat));
> >> 		if (len >= 32)
> >> 			return -EFAULT;
> >> 		len = strlen(str_buf);
> >> @@ -110,7 +114,7 @@ static int read_reset_stat(struct ctl_table *table, int write,
> >> 		len -= *ppos;
> >> 		if (len > *lenp)
> >> 			len = *lenp;
> >> -		if (len && copy_to_user(buffer, str_buf, len))
> >> +		if (len && __copy_to_user(buffer, str_buf, len))
> >> 			return -EFAULT;
> >> 		*lenp = len;
> >> 		*ppos += len;
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
