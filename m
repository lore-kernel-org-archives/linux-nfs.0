From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 02/38] svc: Make svc_sock the tcp/udp transport
Date: Mon, 17 Dec 2007 03:46:15 -0600
Message-ID: <C38BA187.233C6%tom@opengridcomputing.com>
References: <20071213190113.GC29496@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: NeilBrown <neilb@suse.de>, <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.es335.com ([67.65.19.105]:15595 "EHLO mail.es335.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760807AbXLQJqg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Dec 2007 04:46:36 -0500
In-Reply-To: <20071213190113.GC29496@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>




On 12/13/07 1:01 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Dec 11, 2007 at 05:31:56PM -0600, Tom Tucker wrote:
>> @@ -1965,3 +1995,4 @@ static struct svc_deferred_req
>> *svc_deferred_dequeue(struct svc_sock *svsk)
>> spin_unlock(&svsk->sk_lock);
>> return dr;
>>  }
>> +
> 
> ??

Oops. Fixed.

> 
> --b.


