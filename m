From: Xiaotian Feng <dfeng@redhat.com>
Subject: Re: [PATCH] sunrpc: fix peername failed on closed listener
Date: Wed, 06 Jan 2010 17:07:32 +0800
Message-ID: <4B4452D4.6090708@redhat.com>
References: <1262227956-21470-1-git-send-email-dfeng@redhat.com> <20100105230131.GA22850@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Neil Brown <neilb@suse.de>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"David S. Miller" <davem@davemloft.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23167 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752987Ab0AFJHk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jan 2010 04:07:40 -0500
In-Reply-To: <20100105230131.GA22850@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/06/2010 07:01 AM, J. Bruce Fields wrote:
> On Thu, Dec 31, 2009 at 10:52:36AM +0800, Xiaotian Feng wrote:
>> There're some warnings of "nfsd: peername failed (err 107)!"
>> socket error -107 means Transport endpoint is not connected.
>> This warning message was outputed by svc_tcp_accept() [net/sunrpc/svcsock.c],
>> when kernel_getpeername returns -107. This means socket might be CLOSED.
>>
>> And svc_tcp_accept was called by svc_recv() [net/sunrpc/svc_xprt.c]
>>
>>          if (test_bit(XPT_LISTENER,&xprt->xpt_flags)) {
>>          <snip>
>>                  newxpt = xprt->xpt_ops->xpo_accept(xprt);
>>          <snip>
>>
>> So this might happen when xprt->xpt_flags has both XPT_LISTENER and XPT_CLOSE.
>>
>> Let's take a look at commit b0401d72, this commit has moved the close
>> processing after do recvfrom method, but this commit also introduces this
>> warnings, if the xpt_flags has both XPT_LISTENER and XPT_CLOSED, we should
>> close it, not accpet then close.
>
> The logic here seems unnecessarily complicated now, but as a minimal
> fix, this seems fine.
>
> Is the *only* justification for this to silence this warning, or is
> there some more serious problem I'm missing?

If a xprt->xpt_flags has XPT_CLOSE & XPT_LISTENER, kernel will accept it 
first,
and svc_xprt_received(xptr) no mater xpo_accept is suceed or failed, 
then svc_delete_xprt(xprt).

I'm not sure what will happened between the svc_xprt_received and 
svc_delete_xprt, there isn't any
lock to protect it.

>
> --b.
>
>>
>> Signed-off-by: Xiaotian Feng<dfeng@redhat.com>
>> Cc: J. Bruce Fields<bfields@fieldses.org>
>> Cc: Neil Brown<neilb@suse.de>
>> Cc: Trond Myklebust<Trond.Myklebust@netapp.com>
>> Cc: David S. Miller<davem@davemloft.net>
>> ---
>> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
>> index 1c924ee..187f0f4 100644
>> --- a/net/sunrpc/svc_xprt.c
>> +++ b/net/sunrpc/svc_xprt.c
>> @@ -699,7 +699,8 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
>>   	spin_unlock_bh(&pool->sp_lock);
>>
>>   	len = 0;
>> -	if (test_bit(XPT_LISTENER,&xprt->xpt_flags)) {
>> +	if (test_bit(XPT_LISTENER,&xprt->xpt_flags)&&
>> +	    !test_bit(XPT_CLOSE,&xprt->xpt_flags)) {
>>   		struct svc_xprt *newxpt;
>>   		newxpt = xprt->xpt_ops->xpo_accept(xprt);
>>   		if (newxpt) {
>

