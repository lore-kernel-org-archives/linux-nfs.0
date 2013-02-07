Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:58627 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754325Ab3BGQAO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Feb 2013 11:00:14 -0500
MIME-Version: 1.0
In-Reply-To: <20130207144156.GB3222@fieldses.org>
References: <1358441584-8783-1-git-send-email-piastry@etersoft.ru>
	<1358441584-8783-3-git-send-email-piastry@etersoft.ru>
	<20130130221602.GC15584@fieldses.org>
	<CAKywueRh++TBazK8_kRN7AUb=EFhGv=Sv2CV0BESkfLFy+g5wA@mail.gmail.com>
	<20130205143514.GA9886@fieldses.org>
	<CAKywueS6oGNu9r_bypu32A89pOoiGb47kjXqw2ZcZQhZK+JV3g@mail.gmail.com>
	<20130207141832.GA3222@fieldses.org>
	<CAKywueTmU_L5cwwJSoUY6753eHf_38VtHadZGt9tcLS59sqmOA@mail.gmail.com>
	<20130207144156.GB3222@fieldses.org>
Date: Thu, 7 Feb 2013 20:00:13 +0400
Message-ID: <CAKywueShbPd9b+WmJwnfwPR_vzk_atBVRBZNTf-HpS7N2CK+AA@mail.gmail.com>
Subject: Re: [PATCH v2 3/8] vfs: Add O_DENYREAD/WRITE flags support for open syscall
From: Pavel Shilovsky <piastry@etersoft.ru>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        wine-devel@winehq.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2013/2/7 J. Bruce Fields <bfields@fieldses.org>:
> On Thu, Feb 07, 2013 at 06:32:38PM +0400, Pavel Shilovsky wrote:
>> 2013/2/7 J. Bruce Fields <bfields@fieldses.org>:
>> > On Thu, Feb 07, 2013 at 01:53:46PM +0400, Pavel Shilovsky wrote:
>> >> Nothing prevents it. If somebody grabbed a share mode lock on a file
>> >> before we call deny_lock_file, we simply close this file and return
>> >> -ETXTBSY.
>> >
>> > But leave the newly-created file there--ugh.
>> >
>> >> We can't grab it before atomic_open because we don't have an
>> >> inode there.
>> >
>> > If you can get the lock while still holding the directory i_mutex can't
>> > you prevent anyone else from looking up the new file until you've gotten
>> > the lock?
>> >
>>
>> Hm..., seems you are right, I missed this part:
>> mutex_lock
>> lookup_open -> atomic_open -> deny_lock_file
>> mutex_unlock
>>
>> that means that nobody can open and of course set flock on the newly
>> created file (because flock is done through file descriptor). So, it
>> should be fine to call flock after f_ops->atomic_open in atomic_open
>> function. Thanks.
>
> Whether that works may also depend on how the new dentry is set up?  If
> it's hashed before you call flock then I suppose it's already visible to
> others.

It seems it should be hashed in f_ops->atomic_open() (at least cifs
and nfs do it this way). In do_last when we do an ordinary open, we
don't hit parent i_mutex if lookup is succeeded through lookup_fast.
lookup_fast can catch newly created dentry and set it's share mode
before atomic_open codepath hits deny_lock_file.

Also, I noted that: atomic open does f_ops->atomic_open and then it
processes may_open check; if may_open fails, the file is closed and
open returns with a error code (but file is created anyway) . I think
there is no difference between this case and the situation with
deny_lock_file there.

-- 
Best regards,
Pavel Shilovsky.
