From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 04/24] SUNRPC: Address potential buffer length overflow in svc_sendto
Date: Mon, 14 Apr 2008 15:43:12 -0400
Message-ID: <BF32CC2B-804B-430D-852E-75CB789C27FF@oracle.com>
References: <20080414162108.12741.73233.stgit@manray.1015granger.net> <20080414162708.12741.71691.stgit@manray.1015granger.net> <20080414174859.GH15950@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:24614 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752734AbYDNTnl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2008 15:43:41 -0400
In-Reply-To: <20080414174859.GH15950@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 14, 2008, at 1:48 PM, J. Bruce Fields wrote:
> On Mon, Apr 14, 2008 at 12:27:08PM -0400, Chuck Lever wrote:
>> Paranoia: Ensure a negative error value return from kernel_sendpage  
>> never
>> matches a large buffer length.
>
> That is a little paranoid.  Absent an argument for exactly what sort  
> of
> bug could allow us to reach this point with the head iov_len in at  
> least
> the gigabytes, I'm inclined to leave this alone for simplicity's
> sake....

I would like to document that we have noticed the mixed sign  
comparison there, and that it has been made entirely safe.  In certain  
cases, the code as it stands does not do what it looks like it does.

I'm not recommending these changes to be pedantic, nor am I doing this  
for my own health.  When we leave checks like this out, what we have  
is "clever" nondeterministic code rather than safe code.  This is  
simply good software engineering, but every one of these I've proposed  
has been argued over and often rejected.

We know that humans write this code, and that humans make mistakes.   
We should be doing everything we can to make this code less vulnerable  
to coding mistakes.  This is not about _fixing_ bugs, it's about  
_preventing_ them.

>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> net/sunrpc/svcsock.c |    2 +-
>> 1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
>> index 6d4162b..a8ae279 100644
>> --- a/net/sunrpc/svcsock.c
>> +++ b/net/sunrpc/svcsock.c
>> @@ -200,7 +200,7 @@ static int svc_sendto(struct svc_rqst *rqstp,  
>> struct xdr_buf *xdr)
>> 		flags = 0;
>> 	len = kernel_sendpage(sock, rqstp->rq_respages[0], 0,
>> 				  xdr->head[0].iov_len, flags);
>> -	if (len != xdr->head[0].iov_len)
>> +	if (len < 0 || len != xdr->head[0].iov_len)
>> 		goto out;
>> 	slen -= xdr->head[0].iov_len;
>> 	if (slen == 0)
>>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



