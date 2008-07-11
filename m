From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH V2] make "noac" and "actimeo=0" work correctly
Date: Fri, 11 Jul 2008 16:14:49 -0400
Message-ID: <4877BF39.20102@redhat.com>
References: <484EE994.5030907@redhat.com> <487390EC.7080403@redhat.com>	 <76bd70e30807100858g58fbf454uc9331035a2bbf264@mail.gmail.com>	 <487649AE.1090909@redhat.com> <1215718184.7126.44.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070701090601060004080306"
Cc: chucklever@gmail.com, NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41620 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758712AbYGKUPK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jul 2008 16:15:10 -0400
In-Reply-To: <1215718184.7126.44.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070701090601060004080306
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> On Thu, 2008-07-10 at 13:41 -0400, Peter Staubach wrote:
>   
>>> include/linux/jiffies.h claims it handles jiffy wrapping correctly.
>>> Why isn't time_in_range() sufficient if 'c' has wrapped?  If it isn't,
>>> should you fix time_in_range() too?
>>>
>>>   
>>>       
>> Clearly, time_in_range() is not sufficient if the 'c' has
>> wrapped.  It only tests to see if a >=b and a <= c.  If 'c'
>> is less than 'b', then time_in_range() will return false.
>>     
>
> Hmm... The actual test in the current time_in_range() should be
>
>     ((long)b - (long)a) <= 0) && ((long)a - (long)c) <= 0
>
> Which is _not_ the same as testing for a>=b && a<=c in the case of a
> sign wrap. Can you show me a case where we might have a problem?
>
> The only case I can think of is if
>
>     ((long) c - (long) b) < 0
>
> (IOW: if the range itself is too large to fit into a signed long). I
> can't imagine that we will ever find ourselves in that situation.
>
>
>   
>> The change, which makes attrtimeo=0 work for free, is to figure out
>> that if the attrtimeo is N, then the attribute cache is valid from
>> time, T, to T + N - 1, not T + N.  Thus, the current attribute
>> cache implementation is off by one because the attribute cache
>> should expire at time, T + N.  The time_in_range() macro was handy
>> and looked right, but wasn't quite right for the desired semantics.
>>
>> Adding tests to check to see if b and c are equal is tuning for
>> the wrong case, I think.  I believe that the majority of file
>> systems are not mounted with "noac" or "actimeo=0", so the extra
>> test would just be overhead for the common case.
>>     
>
> I agree with this.
>
>   

I think that the case that I was looking at is the case that you
described as the difference between b and c being too large to
fit into a signed long as a positive value.

I would agree, that it is probably not worth addressing.  I
suppose that the real solution would be to convert the time
basis to be something which is not subject to wrapping, but the
obvious candidate, the current time, seems a little expensive
to be constantly retrieving.

Given that we seem to "own" time_in_range(), how about the
attached patch which just modifies time_in_range() to calculate
[b,c) instead of [b,c], removes the special case for attrtimeo==0
in nfs_attribute_timeout() and adds a comment that Chuck requested
concerning the need to ensure that zero timeout values continue
to work?

    Thanx...

       ps

--------------070701090601060004080306
Content-Type: text/plain;
 name="attrtimeo.devel.2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="attrtimeo.devel.2"

--- linux-2.6.25.i686/fs/nfs/inode.c.org
+++ linux-2.6.25.i686/fs/nfs/inode.c
@@ -706,13 +706,6 @@ int nfs_attribute_timeout(struct inode *
 
 	if (nfs_have_delegation(inode, FMODE_READ))
 		return 0;
-	/*
-	 * Special case: if the attribute timeout is set to 0, then always
-	 * 		 treat the cache as having expired (unless holding
-	 * 		 a delegation).
-	 */
-	if (nfsi->attrtimeo == 0)
-		return 1;
 	return !time_in_range(jiffies, nfsi->read_cache_jiffies, nfsi->read_cache_jiffies + nfsi->attrtimeo);
 }
 
--- linux-2.6.25.i686/include/linux/nfs_fs.h.org
+++ linux-2.6.25.i686/include/linux/nfs_fs.h
@@ -121,7 +121,10 @@ struct nfs_inode {
 	 *
 	 * We need to revalidate the cached attrs for this inode if
 	 *
-	 *	jiffies - read_cache_jiffies > attrtimeo
+	 *	jiffies - read_cache_jiffies >= attrtimeo
+	 *
+	 * Please note the comparison is greater than or equal
+	 * so that zero timeout values can be specified.
 	 */
 	unsigned long		read_cache_jiffies;
 	unsigned long		attrtimeo;
--- linux-2.6.25.i686/include/linux/jiffies.h.org
+++ linux-2.6.25.i686/include/linux/jiffies.h
@@ -115,9 +115,12 @@ static inline u64 get_jiffies_64(void)
 	 ((long)(a) - (long)(b) >= 0))
 #define time_before_eq(a,b)	time_after_eq(b,a)
 
+/*
+ * Calculate whether a in the range of [b, c).
+ */
 #define time_in_range(a,b,c) \
 	(time_after_eq(a,b) && \
-	 time_before_eq(a,c))
+	 time_before(a,c))
 
 /* Same as above, but does so with platform independent 64bit types.
  * These must be used when utilizing jiffies_64 (i.e. return value of

--------------070701090601060004080306--
