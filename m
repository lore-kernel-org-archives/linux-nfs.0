From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NFS: Enable NFSv4 callback server to listen on
	AF_INET6 sockets
Date: Fri, 17 Oct 2008 14:40:40 -0400
Message-ID: <20081017184040.GA13791@fieldses.org>
References: <20081016212513.21561.55647.stgit@manray.1015granger.net> <1224251205.7722.22.camel@localhost> <8161A6EE-614D-4571-BCAC-2693FD9E3AE6@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:46470 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751478AbYJQSkm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Oct 2008 14:40:42 -0400
In-Reply-To: <8161A6EE-614D-4571-BCAC-2693FD9E3AE6@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 17, 2008 at 11:03:42AM -0400, Chuck Lever wrote:
> On Oct 17, 2008, at Oct 17, 2008, 9:46 AM, Trond Myklebust wrote:
>> On Thu, 2008-10-16 at 17:41 -0400, Chuck Lever wrote:
>>> Allow the NFS callback server to listen for requests via an AF_INET6 
>>> or
>>> AF_INET socket when IPv6 support is present in the kernel.
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>>
>>> I just pulled from your origin/master branch, and this patch appears 
>>> to
>>> be missing from the 2.6.28 merge.  The patch was posted originally in
>>> late August to linux-nfs.
>>>
>>>  http://marc.info/?l=linux-nfs&m=121987073015249&w=2
>>>
>>> Bruce took the others in that series, but I think he may have left  
>>> this
>>> one for you since it hits only the client.
>>
>> I didn't take it at the time because it wouldn't even apply, let alone
>> compile, without commit e851db5b05408b89b9a9429a66814b79fabee2a1.
>
> Yeah, that's been a common problem with these latest patch sets.   
> Hopefully we are through that now.

If you see it happening again, mention it and let's try to work out
something better.  We should be able to pull any common prerequisites
into both of our trees somehow.

--b.

>
>> I'll push it to Linus later today.
>
> Thanks!
>
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
