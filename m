Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:56534 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751551AbcBOHof (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Feb 2016 02:44:35 -0500
Subject: Re: [PATCH nfs-utils] statd: Don't unregister statd service on
 failing to execute callout
References: <1455259282-7237-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
 <989760D9-029D-43E2-ABA3-8DC9F579BE68@oracle.com>
From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Message-ID: <56C1819C.7040908@lab.ntt.co.jp>
Date: Mon, 15 Feb 2016 16:43:24 +0900
MIME-Version: 1.0
In-Reply-To: <989760D9-029D-43E2-ABA3-8DC9F579BE68@oracle.com>
Content-Type: text/plain; charset=windows-1252
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2016/02/13 0:40, Chuck Lever wrote:
> Hi-

Hi,

>> On Feb 12, 2016, at 1:41 AM, Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp> wrote:
>>
>> statd calls atexit(statd_unregister) to unregister statd service on exit,
>> which actually has a side-effect that ha_callout() unregisters statd
>> service even when the child callout process exits on execl() failure.
>>
>> Certain clustering software's deployment script adds -H option with its
>> specified file non-existent, when it is configured not to use callout.
>> In other words, -H seems to be used no matter if callout is needed or not,
>> but when callout is unnecessary, the specified callout program is not
>> deployed.
>> This causes statd not to work once a lock is requested by its NFS client,
>> as execl() in ha_callout() results in ENOENT and exit() of the child
>> process calls exit-handler statd_unregister(). Eventually, the NFS client
>> gets stuck with messages "lockd: cannot monitor xxx" on the NFS server.
>>
>> Although this may not be an expected way of using -H option, it would be
>> better if statd could continue to work even in that situation. Also,
>> execl() could fail for other reasons like ENFILE and EIO, where statd
>> service should not be unregistered as well.
>> Call _exit(), which does not call any exit-handlers, instead of exit() to
>> take care of those situations and make statd more reliable.
> 
> OK, but I think the explanation could be simpler? It doesn't
> seem like a matter of "it would be better if" but more like
> "a forked child must not unregister the statd RPC server."
> In other words, this seems like a real bug to me, not an
> enhancement.

Thank you for your feedback.

Here is a simpler one.
If it looks fine to you, I'll send v2 with your Reviewed-by.

---

-Although this may not be an expected way of using -H option, it would be
-better if statd could continue to work even in that situation. Also,
-execl() could fail for other reasons like ENFILE and EIO, where statd
-service should not be unregistered as well.
-Call _exit(), which does not call any exit-handlers, instead of exit() to
-take care of those situations and make statd more reliable.

+Also, execl() could fail for other reasons like ENFILE or EIO as well.
+
+A forked child must not unregister the statd RPC server, so use
+_exit(), which does not call any exit-handlers, instead of exit().

---
Regards,
Toshiaki Makita


