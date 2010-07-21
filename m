From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 0/5] pnfs-submit fix kfree under spin lock
Date: Wed, 21 Jul 2010 10:23:57 +0300
Message-ID: <4C46A08D.1000604@panasas.com>
References: <1279645283-9862-1-git-send-email-andros@netapp.com> <AANLkTikzt-A69kM863U=YuGZ1-HGWr51KsJEts3uKFx6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38802 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1762708Ab0GUHYH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Jul 2010 03:24:07 -0400
In-Reply-To: <AANLkTikzt-A69kM863U=YuGZ1-HGWr51KsJEts3uKFx6-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jul. 20, 2010, 20:30 +0300, "William A. (Andy) Adamson" <androsadamson@gmail.com> wrote:
> Trond and Fred informed me that kfree under a spin lock is actually
> OK. So, maybe these patches aren't needed.
> 
> On the other hand, with these patches we don't hold the spin lock over
> function calls which to my mind is easier to read. Also, the
> free_layout/free_lseg layoutdriver calls may do more than call kfree.

I'm all for that.
Just document they must not block.
If we ever see that as a requirement we can then change the caller
to drop the spin lock before calling the free method.

Beny

> 
> At least, we should document what we expect from the
> free_layout/free_lseg - e.g. no side affects that conflict with being
> called under a spinlock..
> 
> -->Andy
> 
> On Tue, Jul 20, 2010 at 1:01 PM,  <andros@netapp.com> wrote:
>>
>> Fix kfree under spin lock
>>
>> Both put_lseg and put_layout are called under the inode i_lock where the
>> last reference will end up freeing structures.
>>
>> I know there has been a lot of churn in this code, but free'ing under the
>> spin lock is a no-no.
>> In this patch I refactor the layout allocation, combining it with the
>> layout segment lookup code. The new function, pnfs_get_layout_segment takes
>> inode spin lock, and looks to see if the requested range is serviced by an
>> existing layout segment. If the layout has not been allocated, allocate it.
>> If a layout segement is found, reference it and give up the lock. If no
>> layout segment is found, reference the layout for the layoutget call and
>> give up the lock.
>>
>> 0001-SQUASHME-pnfs-submit-alloc-layout-don-t-call-put_lay.patch
>> 0002-SQUASHME-pnfs-submit-use-atomic_dec_and_lock-for-lay.patch
>>
>> Fix the put_lseg under spin lock.
>> 0003-SQUASHME-pnfs-submit-don-t-call-put_lseg-under-spin-.patch
>>
>> Cleanup.
>> 0004-SQUASHME-pnfs-submit-pnfs_release_layout-just-use-in.patch
>> 0005-SQUASHME-pnfs-submit-fix-has_layout-compile-error.patch
>>
>> Tests:
>> CONFIG_NFS_V4_1 set:
>> Connectathon tests pass against GFS2 and pyNFS file layout servers.
>>
>> CONFIG_NFS_V4_1 not set:
>> Connectathon tests pass.
>>
>> -->Andy
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
