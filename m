From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: NFSERR_NOSPC nfs-client bug
Date: Tue, 18 Mar 2008 15:03:13 +1100
Message-ID: <47DF3F01.9050504@melbourne.sgi.com>
References: <200803172021.08327.nfs@share-foo.com>	 <47DF1E5C.9090607@melbourne.sgi.com> <200803172050.22223.nfs@share-foo.com>	 <47DF2415.6070802@melbourne.sgi.com> <1205809775.22258.9.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs-Uh4cUGhLB8SgSpxsJD1C4w@public.gmane.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.171.30]:44618 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752162AbYCRD7b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Mar 2008 23:59:31 -0400
In-Reply-To: <1205809775.22258.9.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Tue, 2008-03-18 at 13:08 +1100, Greg Banks wrote:
>   
>> Ray Ferguson wrote:
>>     
>>> On Monday 17 March 2008 20:43, Greg Banks wrote:
>>>   
>>>       
>>>> It doesn't ignore ENOSPC, it reports it on close().  Of course this is
>>>> often several gigabytes of lost data too late.
>>>>     
>>>>         
>>> In our case, the thrashing it gave our Linux NFS cluster was severe enough to  
>>> take it out of commission.  The lost data from the file transfer that 
>>> triggered the event was the least of our worries.
>>>
>>>   
>>>       
>> Agreed, it sucks.
>>     
>
> Try a more recent kernel: 2.6.24 and more recent will report these
> errors more promptly.
>   
So that would be
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=7b159fc18d417980f57aef64cab3417ee6af70f8

?
Is my reading right, that a solitary transient ENOSPC is still reported
at close(), but a sequence of two or more ENOSPC is reported in the next
write() call?

-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.

