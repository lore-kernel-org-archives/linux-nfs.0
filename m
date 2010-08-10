From: Yuehai Xu <yuehaixu@gmail.com>
Subject: Re: is nfsd sync or async?
Date: Mon, 9 Aug 2010 22:44:35 -0400
Message-ID: <AANLkTimaOiC4eo3Zqn-wO62sV9hVMsNeF-vqkMGi6kVR@mail.gmail.com>
References: <AANLkTimU8OCKCaj0b5Ueg__c5DKSKGJWxoZUNK5xeyHk@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, green.trace@gmail.com,
	yuehai.xu@gmail.com, yhxu-jgEIgUtgKzeHXe+LvDLADg@public.gmane.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52777 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752866Ab0HJCog (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Aug 2010 22:44:36 -0400
In-Reply-To: <AANLkTimU8OCKCaj0b5Ueg__c5DKSKGJWxoZUNK5xeyHk-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 9, 2010 at 8:00 AM, Yuehai Xu <yuehaixu@gmail.com> wrote:
> Hi all,
>
> Suppose there is only one nfsd and two clients are sending random read
> requests to this daemon. In this way, read ahead of the client should
> not work since the requests are random. The requests between these two
> clients should be async, while the requests from any one client of the
> two should be sync. My question is about how will the nfsd handle
> these requests, using sync or async mode in the kernel? Say, will nfsd
> never handle the next request unless the previous request has been
> served, without considering which clients the request belongs to? Or
> nfsd just dispatch async requests to the lower level as soon as it
> receives a request?
>
> Any answer will be appreciate!
>
> Yuehai
>

I review the code of NFS and notice that the read operation of NFS
will invoke generic_file_aio_read(), which means the requests(from the
case I mentioned above) dispatched by a nfsd should be sync to each
other, is that correct?

Thanks,
Yuehai
