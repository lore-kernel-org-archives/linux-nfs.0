From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 11/38] svc: Add xpo_accept transport function
Date: Fri, 14 Dec 2007 23:22:26 -0600
Message-ID: <C388C0B2.5C5%tom@opengridcomputing.com>
References: <20071214195544.GE23121@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: <neilb@suse.de>, <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:39659 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750859AbXLOF0H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 15 Dec 2007 00:26:07 -0500
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

Calling svc_sock_enqueue while holding the BUSY bit is a no-op. We can
certainly break this out and update the comment.

> (And if we don't, but we still need the set_bit, then we need to fix the
> comment at the top of the file claiming the svc_sock_enqueue() is always
> required after setting SK_CONN.)

We need to call svc_sock_enqueue, but it is done indirectly through
svc_sock_received -- that calls svc_sock_enqueue after clearing the BUSY
bit. 

> 
> --b.


