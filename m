From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/3] client-side lockd doesn't start UDP listener
Date: Mon, 13 Oct 2008 11:42:47 -0400
Message-ID: <CCAC2CA2-FEAE-4383-9F7D-F63BBF0E701E@oracle.com>
References: <20081003211305.9870.6835.stgit@ingres.1015granger.net> <20081004213625.GA3709@fieldses.org> <18674.34066.316972.695627@notabene.brown>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:43739 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754727AbYJMPnG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Oct 2008 11:43:06 -0400
In-Reply-To: <18674.34066.316972.695627-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil-

On Oct 12, 2008, at Oct 12, 2008, 7:15 PM, Neil Brown wrote:
> On Saturday October 4, bfields@fieldses.org wrote:
>> On Fri, Oct 03, 2008 at 05:15:14PM -0400, Chuck Lever wrote:
>>> Hi Bruce, Neil-
>>>
>>> Here's my initial proposal to address the NFSv2/v3 lock recovery  
>>> issue
>>> that results from having no UDP lockd listener.
>>>
>>> Comments?  Did I miss anything?
>>
>> Looks fine; I can't see any problem.  So I've applied to for-2.6.28.
>> (An ack from Neil would be reassuring, though, if he gets a chance.)
>
> Sorry for my tardiness.  September was a very hectic month for me.
>
> One consequence of this change is that lockd always listens on TCP
> even if NFSD and NFS are only using UDP.
> Do we care?  I suspect not.

The server side usually has to start both anyway, so I thought making  
both sides work the same way was slightly nicer than keeping the  
"proto" argument to lockd_up(), and the run-time cost on the client is  
fairly minimal.  Plus, the overall trend is away from NFS over UDP,  
and towards NFS over TCP.  UDP is legacy, and TCP is the common case,  
going forward, so it's likely the TCP listener will nearly always be  
running anyway.

However, do we care about the -T and -U options on rpc.nfsd affecting  
how server-side lockd works?  Maybe that is a valid reason to keep the  
"proto" argument to lockd_up().

> An alternative fix to the problem would be to always listen on UDP and
> only listen on TCP if it was requested.  This would probably be a
> smaller code change, and might in some sense be more flexible.
>
> Will we ever want to talk NLM over any other protocol? RDMA?
> Is UDP6 a different protocol in this context?  I suspect not.
>
> I guess I have a small leaning towards just always listening on UDP
> and leaving everything else the same, but it is small, not strong.  So
> unless either of you lean the same way I'm happy to give my
>
> Acked-By: NeilBrown <neilb@suse.de>
>
> to the current patches.

Thanks for the review.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
