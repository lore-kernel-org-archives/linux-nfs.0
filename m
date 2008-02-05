From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: [PATCH 4/5] NFSD: Remove NFSD_TCP kernel build option
Date: Tue, 05 Feb 2008 11:29:55 +1100
Message-ID: <47A7AE03.10401@melbourne.sgi.com>
References: <20080205000442.18602.29035.stgit@manray.1015granger.net>	 <47A7AB89.7020709@melbourne.sgi.com> <1202170754.28484.57.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chuck Lever <chuck.lever@oracle.com>, bfields@citi.umich.edu,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.171.29]:41160 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754006AbYBEAX0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Feb 2008 19:23:26 -0500
In-Reply-To: <1202170754.28484.57.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Tue, 2008-02-05 at 11:19 +1100, Greg Banks wrote:
>   
>> Chuck Lever wrote:
>>     
>>> TCP support in the Linux NFS server is stable enough that we can leave it
>>> on always.  CONFIG_NFSD_TCP adds about 10 lines of code, and defaults to
>>> "Y" anyway.
>>>
>>> A run-time switch might be more appropriate if people feel they would like
>>> to disable NFSD's TCP support.
>>>
>>>   
>>>       
>> Looks good.
>>
>> Actually, I'd be inclined to go one step further and set UDP support
>> off by default.
>>     
>
> That will break older clients.
>
>   
Hence the default, rather than removing the code entirely.

-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.

