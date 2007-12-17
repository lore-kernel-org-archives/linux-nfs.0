From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 11/38] svc: Add xpo_accept transport function
Date: Mon, 17 Dec 2007 04:49:06 -0600
Message-ID: <C38BB042.233EF%tom@opengridcomputing.com>
References: <20071214195544.GE23121@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: NeilBrown <neilb@suse.de>, <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.es335.com ([67.65.19.105]:28240 "EHLO mail.es335.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762619AbXLQKt2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Dec 2007 05:49:28 -0500
In-Reply-To: <20071214195544.GE23121@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>




On 12/14/07 1:55 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Dec 11, 2007 at 05:32:17PM -0600, Tom Tucker wrote:
>> @@ -1053,11 +1060,10 @@ svc_tcp_accept(struct svc_sock *svsk)
>> else if (err != -EAGAIN && net_ratelimit())
>> printk(KERN_WARNING "%s: accept failed (err %d)!\n",
>>   serv->sv_name, -err);
>> -  return;
>> +  return NULL;
>> }
>>  
>> set_bit(SK_CONN, &svsk->sk_flags);
>> - svc_sock_enqueue(svsk);
>>  
>> err = kernel_getpeername(newsock, sin, &slen);
>> if (err < 0) {
> 
> Why did we need that svc_sock_enqueue here, and why don't we any more?
> (And if we don't, but we still need the set_bit, then we need to fix the
> comment at the top of the file claiming the svc_sock_enqueue() is always
> required after setting SK_CONN.)

I moved this to it's own patch with a description of why it was removed.

> 
> --b.
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


