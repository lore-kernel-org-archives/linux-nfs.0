Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:19659 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758465Ab2HUV33 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Aug 2012 17:29:29 -0400
Subject: Re: [PATCH 08/14] svcrpc: ignore unknown address type in udp receive
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20120821212431.GC18637@fieldses.org>
Date: Tue, 21 Aug 2012 17:29:16 -0400
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Message-Id: <822DBA73-7B4C-43CC-B096-9D8B4A219390@oracle.com>
References: <1345582652-18476-1-git-send-email-bfields@redhat.com> <1345582652-18476-9-git-send-email-bfields@redhat.com> <05C6926C-B688-4A71-AA1C-26F251BBD635@oracle.com> <20120821212431.GC18637@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 21, 2012, at 5:24 PM, J. Bruce Fields wrote:

> On Tue, Aug 21, 2012 at 05:02:14PM -0400, Chuck Lever wrote:
>> 
>> On Aug 21, 2012, at 4:57 PM, J. Bruce Fields wrote:
>> 
>>> From: "J. Bruce Fields" <bfields@redhat.com>
>>> 
>>> How would this happen?
>> 
>> If an unsupported address family is used in the rqstp.
> 
> Right, but that's impossible, isn't it?

The point is to catch this case when someone adds support for new address families.  It won't happen in current code.

>>> In any case, it appears this would be returned all the way up to the
>>> caller of svc_recv(), and it's obvious that none of them are equipped to
>>> handle it, and not clear what they would want to do with it anyway.
>>> Let's just drop this and return -EAGAIN.
>> 
>> EAGAIN is incorrect; the correct error code is EAFNOSUPPORT.  If callers are not prepared for this error return, perhaps BUG_ON() would be more appropriate here.
> 
> Yeah.  Actually on a quick check this is the only caller that even
> checks for this case.  So probably the check should go in svc_addr_len.
> Maybe we should be nice and make it a warning.

I normally find BUG pretty harsh, but in this case it's true a software error, and as you say, should be "impossible": thus it should be a BUG.  The code should stop before the zero length is used.

I agree, though, we should raise the red flag near the code that should be fixed.

> 
> --b.
> 
> commit 4814e806a44f3dee8f7cae00a7d0240487d62583
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Tue Aug 21 17:22:11 2012 -0400
> 
>    svcrpc: don't bother checking bad svc_addr_len result
> 
>    None of the callers should see an unsupported address family (only one
>    of them even bothers to check for that case), so just check for the
>    buggy case in svc_addr_len and don't bother elsewhere.
> 
>    Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
> index b3f64b1..9324008 100644
> --- a/include/linux/sunrpc/svc_xprt.h
> +++ b/include/linux/sunrpc/svc_xprt.h
> @@ -166,7 +166,7 @@ static inline size_t svc_addr_len(const struct sockaddr *sa)
> 	case AF_INET6:
> 		return sizeof(struct sockaddr_in6);
> 	}
> -
> +	WARN_ONCE(true, "unknown address family %d\n", sa->sa_family);
> 	return 0;
> }
> 
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 998aa8c..13b005c 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -601,8 +601,6 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
> 		return -EAGAIN;
> 	}
> 	len = svc_addr_len(svc_addr(rqstp));
> -	if (len == 0)
> -		return -EAFNOSUPPORT;
> 	rqstp->rq_addrlen = len;
> 	if (skb->tstamp.tv64 == 0) {
> 		skb->tstamp = ktime_get_real();
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




