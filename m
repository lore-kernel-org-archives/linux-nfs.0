Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:16678 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753299AbcBOOqt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Feb 2016 09:46:49 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Subject: Re: [PATCH nfs-utils] statd: Don't unregister statd service on failing to execute callout
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <56C1819C.7040908@lab.ntt.co.jp>
Date: Mon, 15 Feb 2016 09:46:38 -0500
Cc: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <C6EECBAE-5C00-4E72-B708-7668372682B6@oracle.com>
References: <1455259282-7237-1-git-send-email-makita.toshiaki@lab.ntt.co.jp> <989760D9-029D-43E2-ABA3-8DC9F579BE68@oracle.com> <56C1819C.7040908@lab.ntt.co.jp>
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Feb 15, 2016, at 2:43 AM, Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp> wrote:
> 
> On 2016/02/13 0:40, Chuck Lever wrote:
>> Hi-
> 
> Hi,
> 
>>> On Feb 12, 2016, at 1:41 AM, Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp> wrote:
>>> 
>>> statd calls atexit(statd_unregister) to unregister statd service on exit,
>>> which actually has a side-effect that ha_callout() unregisters statd
>>> service even when the child callout process exits on execl() failure.
>>> 
>>> Certain clustering software's deployment script adds -H option with its
>>> specified file non-existent, when it is configured not to use callout.
>>> In other words, -H seems to be used no matter if callout is needed or not,
>>> but when callout is unnecessary, the specified callout program is not
>>> deployed.
>>> This causes statd not to work once a lock is requested by its NFS client,
>>> as execl() in ha_callout() results in ENOENT and exit() of the child
>>> process calls exit-handler statd_unregister(). Eventually, the NFS client
>>> gets stuck with messages "lockd: cannot monitor xxx" on the NFS server.
>>> 
>>> Although this may not be an expected way of using -H option, it would be
>>> better if statd could continue to work even in that situation. Also,
>>> execl() could fail for other reasons like ENFILE and EIO, where statd
>>> service should not be unregistered as well.
>>> Call _exit(), which does not call any exit-handlers, instead of exit() to
>>> take care of those situations and make statd more reliable.
>> 
>> OK, but I think the explanation could be simpler? It doesn't
>> seem like a matter of "it would be better if" but more like
>> "a forked child must not unregister the statd RPC server."
>> In other words, this seems like a real bug to me, not an
>> enhancement.
> 
> Thank you for your feedback.
> 
> Here is a simpler one.
> If it looks fine to you, I'll send v2 with your Reviewed-by.

Looks good, thanks for the update.


> ---
> 
> -Although this may not be an expected way of using -H option, it would be
> -better if statd could continue to work even in that situation. Also,
> -execl() could fail for other reasons like ENFILE and EIO, where statd
> -service should not be unregistered as well.
> -Call _exit(), which does not call any exit-handlers, instead of exit() to
> -take care of those situations and make statd more reliable.
> 
> +Also, execl() could fail for other reasons like ENFILE or EIO as well.
> +
> +A forked child must not unregister the statd RPC server, so use
> +_exit(), which does not call any exit-handlers, instead of exit().
> 
> ---
> Regards,
> Toshiaki Makita

--
Chuck Lever




