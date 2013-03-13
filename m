Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:29937 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932394Ab3CMAzZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Mar 2013 20:55:25 -0400
Message-ID: <513FCE92.7050105@cn.fujitsu.com>
Date: Wed, 13 Mar 2013 08:55:46 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
MIME-Version: 1.0
To: "Peng, Tao" <tao.peng@emc.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] pnfs-block: may be return NULL when find a extent
References: <513EC692.4090907@cn.fujitsu.com> <1882637210201641A747464075FFC649025986A4@MX101CL02.corp.emc.com>
In-Reply-To: <1882637210201641A747464075FFC649025986A4@MX101CL02.corp.emc.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Peng, Tao 写道:
>> -----Original Message-----
>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of
>> fanchaoting
>> Sent: Tuesday, March 12, 2013 2:09 PM
>> To: Myklebust, Trond
>> Cc: linux-nfs@vger.kernel.org
>> Subject: [PATCH] pnfs-block: may be return NULL when find a extent
>>
>> maybe return NULL when find a extent, if we use it later,
>> it will cause oops.
>>
> ah, I would say it is intentional because the lookup cannot fail here. If we are committing an extent but cannot find it in client's extent cache, it certainly is a bug somewhere else. I remember there are other places like this in block layout code as well and we used to put a BUG_ON() there. But since we are using the pointer right away and crash on NULL pointer dereference anyway, it was suggested to remove these BUG_ON()s during code review.
> 

Get it , thanks for telling me it.

> Are you fixing this because you saw a crash or because some static code analyzer complains?
> 
> Thanks,
> Tao
> 
>>  Signed-off-by: fanchaoting<fanchaoting@cn.fujitsu.com>
>> ---
>>  fs/nfs/blocklayout/extents.c |    5 +++++
>>  1 files changed, 5 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
>> index 9c3e117..131ea59 100644
>> --- a/fs/nfs/blocklayout/extents.c
>> +++ b/fs/nfs/blocklayout/extents.c
>> @@ -762,6 +762,11 @@ set_to_rw(struct pnfs_block_layout *bl, u64 offset, u64 length)
>>
>>         spin_lock(&bl->bl_ext_lock);
>>         be = bl_find_get_extent_locked(bl, offset);
>> +       if (!be) {
>> +               spin_unlock(&bl->bl_ext_lock);
>> +               goto out_nosplit;
>> +       }
>> +
>>         rv = be->be_f_offset + be->be_length;
>>         if (be->be_state != PNFS_BLOCK_INVALID_DATA) {
>>                 spin_unlock(&bl->bl_ext_lock);
>> --
>> 1.7.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 



