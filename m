From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH V2] make "noac" and "actimeo=0" work correctly
Date: Thu, 10 Jul 2008 15:29:44 -0400
Message-ID: <1215718184.7126.44.camel@localhost>
References: <484EE994.5030907@redhat.com> <487390EC.7080403@redhat.com>
	 <76bd70e30807100858g58fbf454uc9331035a2bbf264@mail.gmail.com>
	 <487649AE.1090909@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: chucklever@gmail.com, NFS list <linux-nfs@vger.kernel.org>
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:16144 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753794AbYGJTab (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jul 2008 15:30:31 -0400
In-Reply-To: <487649AE.1090909@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-07-10 at 13:41 -0400, Peter Staubach wrote:
> > include/linux/jiffies.h claims it handles jiffy wrapping correctly.
> > Why isn't time_in_range() sufficient if 'c' has wrapped?  If it isn't,
> > should you fix time_in_range() too?
> >
> >   
> 
> Clearly, time_in_range() is not sufficient if the 'c' has
> wrapped.  It only tests to see if a >=b and a <= c.  If 'c'
> is less than 'b', then time_in_range() will return false.

Hmm... The actual test in the current time_in_range() should be

    ((long)b - (long)a) <= 0) && ((long)a - (long)c) <= 0

Which is _not_ the same as testing for a>=b && a<=c in the case of a
sign wrap. Can you show me a case where we might have a problem?

The only case I can think of is if

    ((long) c - (long) b) < 0

(IOW: if the range itself is too large to fit into a signed long). I
can't imagine that we will ever find ourselves in that situation.


> The change, which makes attrtimeo=0 work for free, is to figure out
> that if the attrtimeo is N, then the attribute cache is valid from
> time, T, to T + N - 1, not T + N.  Thus, the current attribute
> cache implementation is off by one because the attribute cache
> should expire at time, T + N.  The time_in_range() macro was handy
> and looked right, but wasn't quite right for the desired semantics.
> 
> Adding tests to check to see if b and c are equal is tuning for
> the wrong case, I think.  I believe that the majority of file
> systems are not mounted with "noac" or "actimeo=0", so the extra
> test would just be overhead for the common case.

I agree with this.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
