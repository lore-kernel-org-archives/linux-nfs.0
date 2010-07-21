From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [PATCH 0/5] pnfs-submit fix kfree under spin lock
Date: Wed, 21 Jul 2010 10:46:15 -0400
Message-ID: <AANLkTimYOLwLskHupGwk0HJpGA9gES_Ooe=stFt5LJpr@mail.gmail.com>
References: <1279645283-9862-1-git-send-email-andros@netapp.com>
	<AANLkTikzt-A69kM863U=YuGZ1-HGWr51KsJEts3uKFx6@mail.gmail.com>
	<4C46A08D.1000604@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:49465 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900Ab0GUOqR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Jul 2010 10:46:17 -0400
Received: by iwn7 with SMTP id 7so6893089iwn.19
        for <linux-nfs@vger.kernel.org>; Wed, 21 Jul 2010 07:46:16 -0700 (PDT)
In-Reply-To: <4C46A08D.1000604@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 21, 2010 at 3:23 AM, Benny Halevy <bhalevy@panasas.com> wro=
te:
> On Jul. 20, 2010, 20:30 +0300, "William A. (Andy) Adamson" <androsada=
mson@gmail.com> wrote:
>> Trond and Fred informed me that kfree under a spin lock is actually
>> OK. So, maybe these patches aren't needed.
>>
>> On the other hand, with these patches we don't hold the spin lock ov=
er
>> function calls which to my mind is easier to read. Also, the
>> free_layout/free_lseg layoutdriver calls may do more than call kfree=
=2E
>
> I'm all for that.
> Just document they must not block.
> If we ever see that as a requirement we can then change the caller
> to drop the spin lock before calling the free method.

You might consider the first patch which combines looking up an lseg
and allocating the pnfs_layout_type. They are really the same job, and
I think it's more clear what is going on.

-->Andy

>
> Beny
>
>>
>> At least, we should document what we expect from the
>> free_layout/free_lseg - e.g. no side affects that conflict with bein=
g
>> called under a spinlock..
>>
>> -->Andy
>>
>> On Tue, Jul 20, 2010 at 1:01 PM, =A0<andros@netapp.com> wrote:
>>>
>>> Fix kfree under spin lock
>>>
>>> Both put_lseg and put_layout are called under the inode i_lock wher=
e the
>>> last reference will end up freeing structures.
>>>
>>> I know there has been a lot of churn in this code, but free'ing und=
er the
>>> spin lock is a no-no.
>>> In this patch I refactor the layout allocation, combining it with t=
he
>>> layout segment lookup code. The new function, pnfs_get_layout_segme=
nt takes
>>> inode spin lock, and looks to see if the requested range is service=
d by an
>>> existing layout segment. If the layout has not been allocated, allo=
cate it.
>>> If a layout segement is found, reference it and give up the lock. I=
f no
>>> layout segment is found, reference the layout for the layoutget cal=
l and
>>> give up the lock.
>>>
>>> 0001-SQUASHME-pnfs-submit-alloc-layout-don-t-call-put_lay.patch
>>> 0002-SQUASHME-pnfs-submit-use-atomic_dec_and_lock-for-lay.patch
>>>
>>> Fix the put_lseg under spin lock.
>>> 0003-SQUASHME-pnfs-submit-don-t-call-put_lseg-under-spin-.patch
>>>
>>> Cleanup.
>>> 0004-SQUASHME-pnfs-submit-pnfs_release_layout-just-use-in.patch
>>> 0005-SQUASHME-pnfs-submit-fix-has_layout-compile-error.patch
>>>
>>> Tests:
>>> CONFIG_NFS_V4_1 set:
>>> Connectathon tests pass against GFS2 and pyNFS file layout servers.
>>>
>>> CONFIG_NFS_V4_1 not set:
>>> Connectathon tests pass.
>>>
>>> -->Andy
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs=
" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.htm=
l
>>>
>
