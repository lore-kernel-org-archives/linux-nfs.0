From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: [patch 10/14] sunrpc: Reorganise the queuing of cache upcalls.
Date: Sat, 10 Jan 2009 10:40:45 +1100
Message-ID: <4967E07D.7010606@melbourne.sgi.com>
References: <20090108082510.050854000@sgi.com> <20090108082604.517918000@sgi.com> <20090108195747.GB19312@fieldses.org> <4966B92F.8060008@melbourne.sgi.com> <20090109212921.GC5466@fieldses.org> <20090109214146.GE5466@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:55218 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753260AbZAIXsm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Jan 2009 18:48:42 -0500
In-Reply-To: <20090109214146.GE5466@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Fri, Jan 09, 2009 at 04:29:21PM -0500, bfields wrote:
>   
>> On Fri, Jan 09, 2009 at 01:40:47PM +1100, Greg Banks wrote:
>>     
>>> A smaller issue is that you keep a single list and use the value of the
>>> CACHE_PENDING bit to tell the difference between states.  I think this
>>> could be made to work; however my technique of using two lists makes
>>> most of the code even simpler at the small cost of having to do two list
>>> searches in queue_loose().
>>>       
>> OK.  When exactly do they get moved between lists?  I'll take a look at
>> the code.
>>     
>
> The one thing I'd be curious about here would be robustness in the face
> of a userland daemon that was restarted:
Fair enough.
>  would requests marked as read
> but not responded to be stuck there indefinitely at the time the daemon
> went down? 
I don't think so.  Requests on the to_write list have the CACHE_PENDING
bit set, and that will trigger a call to cache_remove_queued() in either
of cache_fresh_unlocked() or cache_clean().  The latter will happen when
the cache_head expires or when the .../flush file is written, e.g. the
next exportfs change.  One of those should happen if the daemons are
started normally.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

