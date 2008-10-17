From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFS: Enable NFSv4 callback server to listen on AF_INET6 sockets
Date: Fri, 17 Oct 2008 11:03:42 -0400
Message-ID: <8161A6EE-614D-4571-BCAC-2693FD9E3AE6@oracle.com>
References: <20081016212513.21561.55647.stgit@manray.1015granger.net> <1224251205.7722.22.camel@localhost>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:32503 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753440AbYJQPDw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Oct 2008 11:03:52 -0400
In-Reply-To: <1224251205.7722.22.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct 17, 2008, at Oct 17, 2008, 9:46 AM, Trond Myklebust wrote:
> On Thu, 2008-10-16 at 17:41 -0400, Chuck Lever wrote:
>> Allow the NFS callback server to listen for requests via an  
>> AF_INET6 or
>> AF_INET socket when IPv6 support is present in the kernel.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> I just pulled from your origin/master branch, and this patch  
>> appears to
>> be missing from the 2.6.28 merge.  The patch was posted originally in
>> late August to linux-nfs.
>>
>>  http://marc.info/?l=linux-nfs&m=121987073015249&w=2
>>
>> Bruce took the others in that series, but I think he may have left  
>> this
>> one for you since it hits only the client.
>
> I didn't take it at the time because it wouldn't even apply, let alone
> compile, without commit e851db5b05408b89b9a9429a66814b79fabee2a1.

Yeah, that's been a common problem with these latest patch sets.   
Hopefully we are through that now.

> I'll push it to Linus later today.

Thanks!

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
