From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 06/24] SUNRPC: Sanity check incoming UDP datagram
	lengths properly
Date: Mon, 14 Apr 2008 16:54:11 -0400
Message-ID: <20080414205411.GQ15950@fieldses.org>
References: <20080414162108.12741.73233.stgit@manray.1015granger.net> <20080414162723.12741.35500.stgit@manray.1015granger.net> <20080414183804.GI15950@fieldses.org> <57F5E6FE-975E-4936-AD04-13956747A18E@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:38947 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753479AbYDNUy3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Apr 2008 16:54:29 -0400
In-Reply-To: <57F5E6FE-975E-4936-AD04-13956747A18E@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 14, 2008 at 03:55:16PM -0400, Chuck Lever wrote:
> On Apr 14, 2008, at 2:38 PM, J. Bruce Fields wrote:
>> On Mon, Apr 14, 2008 at 12:27:23PM -0400, Chuck Lever wrote:
>>> Clean up: ensure svc_udp_recvfrom() is getting at least a full UDP  
>>> header
>>> to avoid potential negative intermediate values.
>>
>> Is it legal in this case for skb_recv_datagram() to return an skb
>> without at least that minimum length? (And if not, should this be a
>> BUG()?)
>>
>>
>>> A similar sanity check is already used in the RPC client.
>>
>> This one?:
>>
>> 	repsize = skb->len - sizeof(struct udphdr);
>> 	if (repsize < 4) {
>> 		dprintk("RPC:       impossible RPC reply size %d!\n", repsize);
>> 		goto dropit;
>> 	}
>>
>> I assumed it was needed because of the rpc-level check (for the 4  
>> bytes worth
>> of xid), not because it needed udp-level checking.
>
> The server side check programmatically guarantees we get a non-negative 
> number when we compute "bytes."

Would a BUG() accomplish the same thing?

--b.

> Thus we can use an unsigned variable and 
> eliminate a mixed sign comparison later on.
>
> We can add a "+ sizeof(u32)" to the check if you like.
>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>>
>>> net/sunrpc/svcsock.c |   20 +++++++++++++-------
>>> 1 files changed, 13 insertions(+), 7 deletions(-)
>>>
>>> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
>>> index d077071..de29e7f 100644
>>> --- a/net/sunrpc/svcsock.c
>>> +++ b/net/sunrpc/svcsock.c
>>> @@ -431,6 +431,7 @@ static int svc_udp_recvfrom(struct svc_rqst  
>>> *rqstp)
>>> 	} buffer;
>>> 	struct cmsghdr *cmh = &buffer.hdr;
>>> 	int		err, len;
>>> +	unsigned int	bytes;
>>> 	struct msghdr msg = {
>>> 		.msg_name = svc_addr(rqstp),
>>> 		.msg_control = cmh,
>>> @@ -484,8 +485,13 @@ static int svc_udp_recvfrom(struct svc_rqst  
>>> *rqstp)
>>> 	 */
>>> 	svc_xprt_received(&svsk->sk_xprt);
>>>
>>> -	len  = skb->len - sizeof(struct udphdr);
>>> -	rqstp->rq_arg.len = len;
>>> +	if (skb->len < sizeof(struct udphdr)) {
>>> +		dprintk("svc: bad UDP datagram length: %u\n", skb->len);
>>> +		skb_free_datagram(svsk->sk_sk, skb);
>>> +		return 0;
>>> +	}
>>> +	bytes = skb->len - sizeof(struct udphdr);
>>> +	rqstp->rq_arg.len = bytes;
>>>
>>> 	rqstp->rq_prot = IPPROTO_UDP;
>>>
>>> @@ -515,7 +521,7 @@ static int svc_udp_recvfrom(struct svc_rqst  
>>> *rqstp)
>>> 		/* we can use it in-place */
>>> 		rqstp->rq_arg.head[0].iov_base = skb->data +
>>> 			sizeof(struct udphdr);
>>> -		rqstp->rq_arg.head[0].iov_len = len;
>>> +		rqstp->rq_arg.head[0].iov_len = bytes;
>>> 		if (skb_checksum_complete(skb)) {
>>> 			skb_free_datagram(svsk->sk_sk, skb);
>>> 			return 0;
>>> @@ -524,12 +530,12 @@ static int svc_udp_recvfrom(struct svc_rqst  
>>> *rqstp)
>>> 	}
>>>
>>> 	rqstp->rq_arg.page_base = 0;
>>> -	if (len <= rqstp->rq_arg.head[0].iov_len) {
>>> -		rqstp->rq_arg.head[0].iov_len = len;
>>> +	if (bytes <= rqstp->rq_arg.head[0].iov_len) {
>>> +		rqstp->rq_arg.head[0].iov_len = bytes;
>>> 		rqstp->rq_arg.page_len = 0;
>>> 		rqstp->rq_respages = rqstp->rq_pages+1;
>>> 	} else {
>>> -		rqstp->rq_arg.page_len = len - rqstp->rq_arg.head[0].iov_len;
>>> +		rqstp->rq_arg.page_len = bytes - rqstp->rq_arg.head[0].iov_len;
>>> 		rqstp->rq_respages = rqstp->rq_pages + 1 +
>>> 			DIV_ROUND_UP(rqstp->rq_arg.page_len, PAGE_SIZE);
>>> 	}
>>> @@ -537,7 +543,7 @@ static int svc_udp_recvfrom(struct svc_rqst  
>>> *rqstp)
>>> 	if (serv->sv_stats)
>>> 		serv->sv_stats->netudpcnt++;
>>>
>>> -	return len;
>>> +	return bytes;
>>> }
>>>
>>> static int
>>>
>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>
