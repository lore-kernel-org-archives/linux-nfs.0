From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/3] client-side lockd doesn't start UDP listener
Date: Mon, 13 Oct 2008 16:45:47 -0400
Message-ID: <668D398B-7814-4831-ABC2-8F8CF1FBE4D0@oracle.com>
References: <20081003211305.9870.6835.stgit@ingres.1015granger.net> <20081004213625.GA3709@fieldses.org> <18674.34066.316972.695627@notabene.brown> <CCAC2CA2-FEAE-4383-9F7D-F63BBF0E701E@oracle.com> <20081013174613.GH28864@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:44622 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755713AbYJMUqO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Oct 2008 16:46:14 -0400
In-Reply-To: <20081013174613.GH28864@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct 13, 2008, at Oct 13, 2008, 1:46 PM, J. Bruce Fields wrote:
> On Mon, Oct 13, 2008 at 11:42:47AM -0400, Chuck Lever wrote:
>> Hi Neil-
>>
>> On Oct 12, 2008, at Oct 12, 2008, 7:15 PM, Neil Brown wrote:
>>> On Saturday October 4, bfields@fieldses.org wrote:
>>>> On Fri, Oct 03, 2008 at 05:15:14PM -0400, Chuck Lever wrote:
>>>>> Hi Bruce, Neil-
>>>>>
>>>>> Here's my initial proposal to address the NFSv2/v3 lock recovery
>>>>> issue
>>>>> that results from having no UDP lockd listener.
>>>>>
>>>>> Comments?  Did I miss anything?
>>>>
>>>> Looks fine; I can't see any problem.  So I've applied to  
>>>> for-2.6.28.
>>>> (An ack from Neil would be reassuring, though, if he gets a  
>>>> chance.)
>>>
>>> Sorry for my tardiness.  September was a very hectic month for me.
>>>
>>> One consequence of this change is that lockd always listens on TCP
>>> even if NFSD and NFS are only using UDP.
>>> Do we care?  I suspect not.
>>
>> The server side usually has to start both anyway, so I thought making
>> both sides work the same way was slightly nicer than keeping the  
>> "proto"
>> argument to lockd_up(), and the run-time cost on the client is fairly
>> minimal.  Plus, the overall trend is away from NFS over UDP, and  
>> towards
>> NFS over TCP.  UDP is legacy, and TCP is the common case, going  
>> forward,
>> so it's likely the TCP listener will nearly always be running anyway.
>>
>> However, do we care about the -T and -U options on rpc.nfsd affecting
>> how server-side lockd works?  Maybe that is a valid reason to keep  
>> the
>> "proto" argument to lockd_up().
>
> We might at least want to fix the man page.
>
> I suppose worst case scenarios would be:
>
> 	- a bug is found that affects lockd/tcp and not lockd/udp, and
> 	  people that used -T are affected when they needn't have been,
> 	  or
> 	- someone uses -T and only bothers to firewall the udp port?
>
> Is there any evidence that anyone uses -U or -T?

NFSD start-up code makes two separate and unconditional calls to  
lockd_up(): one for UDP and one for TCP.  So whether or not NFSD  
actually honors the "-T" and "-U" flags, lockd certainly does not  
honor them in current (unpatched) code.

In other words, the patches you've already reviewed shouldn't change  
the server's behavior around -T/-U.  Only the client side should be  
affected.

It looks like, prior to commit 24e36663, the client side started both  
lockd listeners no matter what type of mount was requested.

Additional review is welcome, but let's just move forward with what  
you've already got.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
