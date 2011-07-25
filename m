Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:40638 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750958Ab1GYOuY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jul 2011 10:50:24 -0400
Received: by pzk37 with SMTP id 37so8624238pzk.1
        for <linux-nfs@vger.kernel.org>; Mon, 25 Jul 2011 07:50:24 -0700 (PDT)
Message-ID: <4E2D82AB.6060502@tonian.com>
Date: Mon, 25 Jul 2011 10:50:19 -0400
From: Benny Halevy <bhalevy@tonian.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH v2 07/25] pnfsblock: add blocklayout Kconfig option, Makefile,
 and stubs
References: <1311276865-29484-1-git-send-email-rees@umich.edu> <1311276865-29484-8-git-send-email-rees@umich.edu> <4E2D7E0D.60808@tonian.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A517B56@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A517B56@SACMVEXC2-PRD.hq.netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-07-25 10:38, Myklebust, Trond wrote:
>> -----Original Message-----
>> From: Benny Halevy [mailto:bhalevy@tonian.com]
>> Sent: Monday, July 25, 2011 10:31 AM
>> To: Jim Rees
>> Cc: Myklebust, Trond; linux-nfs@vger.kernel.org; peter honeyman
>> Subject: Re: [PATCH v2 07/25] pnfsblock: add blocklayout Kconfig
>> option, Makefile, and stubs
>>
>> On 2011-07-21 15:34, Jim Rees wrote:
>>> From: Fred Isaman <iisaman@citi.umich.edu>
>>>
>>> Define a configuration variable to enable/disable compilation of the
>>> block driver code.
>>>
>>> Add the minimal structure for a pnfs block layout driver, and empty
>>> list-heads that will hold the extent data
>>>
>>> [pnfsblock: make NFS_V4_1 select PNFS_BLOCK]
>>> Signed-off-by: Peng Tao <peng_tao@emc.com>
>>> Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>> [pnfs-block: fix CONFIG_PNFS_BLOCK dependencies]
>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>> Signed-off-by: Benny Halevy <benny@tonian.com>
>>> [pnfsblock: SQUASHME: port block layout code]
>>> Signed-off-by: Peng Tao <peng_tao@emc.com>
>>> [pnfsblock: SQUASHME: adjust to API change]
>>> Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>>> [pnfs: move pnfs_layout_type inline in nfs_inode]
>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>> [blocklayout: encode_layoutcommit implementation]
>>> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>> Signed-off-by: Benny Halevy <benny@tonian.com>
>>> [pnfsblock: layout alloc and free]
>>> Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>>> [pnfs: move pnfs_layout_type inline in nfs_inode]
>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>> Signed-off-by: Benny Halevy <benny@tonian.com>
>>> [pnfsblock: define module alias]
>>> Signed-off-by: Peng Tao <peng_tao@emc.com>
>>> ---
>>>  fs/nfs/Kconfig                   |    8 ++-
>>>  fs/nfs/Makefile                  |    1 +
>>>  fs/nfs/blocklayout/Makefile      |    5 +
>>>  fs/nfs/blocklayout/blocklayout.c |  175
>> ++++++++++++++++++++++++++++++++++++++
>>>  fs/nfs/blocklayout/blocklayout.h |   91 ++++++++++++++++++++
>>>  5 files changed, 279 insertions(+), 1 deletions(-)
>>>  create mode 100644 fs/nfs/blocklayout/Makefile
>>>  create mode 100644 fs/nfs/blocklayout/blocklayout.c
>>>  create mode 100644 fs/nfs/blocklayout/blocklayout.h
>>>
>>> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
>>> index 2cde5d9..be02077 100644
>>> --- a/fs/nfs/Kconfig
>>> +++ b/fs/nfs/Kconfig
>>> @@ -79,15 +79,21 @@ config NFS_V4_1
>>>  	depends on NFS_FS && NFS_V4 && EXPERIMENTAL
>>>  	select SUNRPC_BACKCHANNEL
>>>  	select PNFS_FILE_LAYOUT
>>> +	select PNFS_BLOCK
>>> +	select MD
>>> +	select BLK_DEV_DM
>>
>> Why is PNFS_BLOCK enabled automatically in all cases?
>> That renders the use of modules for layout drivers totally useless.
>> I sort of understand that for PNFS_FILE_LAYOUT (when my
>> arm is twisted really hard behind my back :) since it
>> is an integral part of RFC5661 but what's the justification
>> for PNFS_BLOCK? and why blocks and not objects?
> 
> The question is rather why did objects add a selectable compile option?

Just good citizenship :)

> What is the point of not compiling a given layout driver if all the
> dependencies are met?

Reducing build times...
Building a smaller kernel when modules are disabled...

We're fine in terms of memory consumption when CONFIG_MODULES=y since the
layout driver is loaded on demand but shouldn't be worried about
the other case?

> 
> IOW: The only thing I'd change above is the select MD and select
> BLK_DEV_DM: I'd prefer something like
> 
> config PNFS_BLOCK
> 	depends on NFS_V4_1 && MD && BLK_DEV_DM
> 	default y

This is closer to the original version.
However, selecting MD and BLK_DEV_DM was proven useful to automatically take
care of the module dependencies without having to dive into details.

Benny

> 
> Trond
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
