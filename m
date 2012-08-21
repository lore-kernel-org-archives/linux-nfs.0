Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:47682 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755044Ab2HUVCU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Aug 2012 17:02:20 -0400
Subject: Re: [PATCH 08/14] svcrpc: ignore unknown address type in udp receive
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1345582652-18476-9-git-send-email-bfields@redhat.com>
Date: Tue, 21 Aug 2012 17:02:14 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <05C6926C-B688-4A71-AA1C-26F251BBD635@oracle.com>
References: <1345582652-18476-1-git-send-email-bfields@redhat.com> <1345582652-18476-9-git-send-email-bfields@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 21, 2012, at 4:57 PM, J. Bruce Fields wrote:

> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> How would this happen?

If an unsupported address family is used in the rqstp.

> In any case, it appears this would be returned all the way up to the
> caller of svc_recv(), and it's obvious that none of them are equipped to
> handle it, and not clear what they would want to do with it anyway.
> Let's just drop this and return -EAGAIN.

EAGAIN is incorrect; the correct error code is EAFNOSUPPORT.  If callers are not prepared for this error return, perhaps BUG_ON() would be more appropriate here.

> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
> net/sunrpc/svcsock.c |    2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 06ae8a7..97ce23f 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -602,7 +602,7 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
> 	}
> 	len = svc_addr_len(svc_addr(rqstp));
> 	if (len == 0)
> -		return -EAFNOSUPPORT;
> +		return -EAGAIN;
> 	rqstp->rq_addrlen = len;
> 	if (skb->tstamp.tv64 == 0) {
> 		skb->tstamp = ktime_get_real();
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




