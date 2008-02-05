From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 4/5] NFSD: Remove NFSD_TCP kernel build option
Date: Mon, 4 Feb 2008 20:55:59 -0500
Message-ID: <4BE5A1AE-DB3B-4796-B6BD-5691930258C8@oracle.com>
References: <20080205000442.18602.29035.stgit@manray.1015granger.net>	 <47A7AB89.7020709@melbourne.sgi.com> <1202170754.28484.57.camel@heimdal.trondhjem.org> <47A7AE03.10401@melbourne.sgi.com>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	bfields@citi.umich.edu, linux-nfs@vger.kernel.org
To: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:57124 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754205AbYBEB4l (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2008 20:56:41 -0500
In-Reply-To: <47A7AE03.10401-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Feb 4, 2008, at 7:29 PM, Greg Banks wrote:
> Trond Myklebust wrote:
>> On Tue, 2008-02-05 at 11:19 +1100, Greg Banks wrote:
>>
>>> Chuck Lever wrote:
>>>
>>>> TCP support in the Linux NFS server is stable enough that we can  
>>>> leave it
>>>> on always.  CONFIG_NFSD_TCP adds about 10 lines of code, and  
>>>> defaults to
>>>> "Y" anyway.
>>>>
>>>> A run-time switch might be more appropriate if people feel they  
>>>> would like
>>>> to disable NFSD's TCP support.
>>>>
>>>>
>>>>
>>> Looks good.
>>>
>>> Actually, I'd be inclined to go one step further and set UDP support
>>> off by default.
>>>
>>
>> That will break older clients.
>>
>>
> Hence the default, rather than removing the code entirely.


What might make sense is to remove NFSD_TCP, but add NFSD_UDP,  
defaulting to Y.

Then in a year or two we can change the default to N.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
