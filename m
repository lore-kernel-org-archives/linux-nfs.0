Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-fx0-f46.google.com ([209.85.161.46]:35461 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277Ab1KJHGs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2011 02:06:48 -0500
Received: by fagn18 with SMTP id n18so192856fag.19
        for <linux-nfs@vger.kernel.org>; Wed, 09 Nov 2011 23:06:46 -0800 (PST)
Message-ID: <4EBB7803.1050004@tonian.com>
Date: Thu, 10 Nov 2011 09:06:43 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: tao.peng@emc.com
CC: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/8] pnfsblock cleanup and fixes
References: <1320851766-1834-1-git-send-email-bergwolf@gmail.com> <F19688880B763E40B28B2B462677FBF805DD054B4F@MX09A.corp.emc.com>
In-Reply-To: <F19688880B763E40B28B2B462677FBF805DD054B4F@MX09A.corp.emc.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-11-10 04:09, tao.peng@emc.com wrote:
> Benny, hi,
> 
> These patches fail to apply to pnfs-latest branch because of conflicts with pnfs private workqueue patches. Since Trond has decided not to take pnfs private workqueue patches, would you please drop them so that new patches can apply? I can send you revert patches if you want.

No problem.  I'll take them out.

Benny

> 
> Thanks,
> Tao
> 
>> -----Original Message-----
>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org]
>> On Behalf Of Peng Tao
>> Sent: Wednesday, November 09, 2011 11:16 PM
>> To: linux-nfs@vger.kernel.org
>> Cc: Trond.Myklebust@netapp.com; bhalevy@tonian.com
>> Subject: [PATCH 0/8] pnfsblock cleanup and fixes
>>
>> Hi, Trond and Benny,
>>
>> Bellow are some pnfsblock patches that I have tested for days. Most of them
>> are cleanup and small improvements. Only
>> [PATCH 2/8] pnfsblock: acquire im_lock in _preload_range
>> needs to go into stable.
>>
>> Thanks,
>> Tao
>>
>> Peng Tao (8):
>>   pnfsblock: cleanup bl_mark_sectors_init
>>   pnfsblock: acquire im_lock in _preload_range
>>   pnfsblock: move find lock page logic out of bl_write_pagelist
>>   pnfsblock: set read/write tk_status to pnfs_error
>>   pnfsblock: remove rpc_call_ops from struct parallel_io
>>   pnfsblock: clean up _add_entry
>>   pnfsblock: add im_extents to pnfs_inval_markings
>>   pnfsblock: alloc short extent before submit bio
>>
>>  fs/nfs/blocklayout/blocklayout.c |  176 +++++++++++++++++++++++++-------------
>>  fs/nfs/blocklayout/blocklayout.h |   11 ++-
>>  fs/nfs/blocklayout/extents.c     |  146 ++++++++++++--------------------
>>  3 files changed, 180 insertions(+), 153 deletions(-)
>>
