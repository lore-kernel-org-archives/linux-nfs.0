From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 00/11] Replacement patches for NSM IPv6 support
Date: Fri, 12 Dec 2008 15:17:51 -0500
Message-ID: <84878F1B-B090-4D8C-8E49-AC9E406A8AD4@oracle.com>
References: <20081211224543.21468.8939.stgit@ingres.1015granger.net> <20081212185951.GB16309@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:40359 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752242AbYLLUSH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Dec 2008 15:18:07 -0500
In-Reply-To: <20081212185951.GB16309@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec 12, 2008, at Dec 12, 2008, 1:59 PM, J. Bruce Fields wrote:
> On Thu, Dec 11, 2008 at 05:55:36PM -0500, Chuck Lever wrote:
>> Hi Bruce-
>>
>> Here is a set of replacement patches for NSM IPv6 support.  This  
>> series
>> replaces the last 11 patches of the 27 I sent previously.  I've  
>> starred
>> the ones that have have changed since last Friday.
>>
>> The others are included in case they may not fit over the changed
>> patches, but I don't expect them to be a problem.
>
> Thanks, all applied to for-2.6.29:
>
> 	git://linux-nfs.org/~bfields/linux.git for-2.6.29
>
> Could you confirm that that branch has everything you've sent me so  
> far?

You have all the patches I've sent so far, and I don't see any  
differences between your include/linux/lockd/lockd.h, fs/lockd/host.c,  
fs/lockd/mon.c, and my copies of these files.

So I think we're good.

> Any testing of that branch also greatly appreciated....
>
> Looking forward to nfsd patches.  (And then are we done with ipv6?)

I'll send the NFSD patches this afternoon.  I don't have any more  
server-side kernel patches for IPv6 at this time.  The only piece I  
have left to update is rpc.statd.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
