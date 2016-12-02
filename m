Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34858 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754091AbcLBRsB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Dec 2016 12:48:01 -0500
Received: by mail-io0-f194.google.com with SMTP id h133so1136689ioe.2
        for <linux-nfs@vger.kernel.org>; Fri, 02 Dec 2016 09:48:01 -0800 (PST)
Subject: Re: [PATCH 2/5] NFSv4: Don't ask for the change attribute when
 reclaiming state
To: Trond Myklebust <trondmy@primarydata.com>
References: <20161201220632.12754-1-trond.myklebust@primarydata.com>
 <20161201220632.12754-2-trond.myklebust@primarydata.com>
 <20161201220632.12754-3-trond.myklebust@primarydata.com>
 <f8904106-2bb4-2fdb-1fdd-fb60ff352531@gmail.com>
 <B06178AC-10FF-42D4-8309-93D9882721DC@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <eef836eb-3c5a-0e4c-ed59-4285609f2823@gmail.com>
Date: Fri, 2 Dec 2016 12:47:58 -0500
MIME-Version: 1.0
In-Reply-To: <B06178AC-10FF-42D4-8309-93D9882721DC@primarydata.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/02/2016 12:28 PM, Trond Myklebust wrote:
> 
>> On Dec 2, 2016, at 12:05, Anna Schumaker <schumaker.anna@gmail.com> wrote:
>>
>> Hi Trond,
>>
>> On 12/01/2016 05:06 PM, Trond Myklebust wrote:
>>> We don't need to ask for the change attribute when returning a delegation
>>> or recovering from a server reboot, and it could actually cause us to
>>> obtain an incorrect value if we're using a pNFS flavour that requires
>>> LAYOUTCOMMIT.
>>>
>>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>>> ---
>>> fs/nfs/nfs4proc.c | 1 -
>>> 1 file changed, 1 deletion(-)
>>>
>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>> index b582df89c083..c0628f78ed98 100644
>>> --- a/fs/nfs/nfs4proc.c
>>> +++ b/fs/nfs/nfs4proc.c
>>> @@ -226,7 +226,6 @@ static const u32 nfs4_pnfs_open_bitmap[3] = {
>>>
>>> static const u32 nfs4_open_noattr_bitmap[3] = {
>>> 	FATTR4_WORD0_TYPE
>>> -	| FATTR4_WORD0_CHANGE
>>
>> Do these patches depend on another patch series?  I'm having trouble applying this patch since my tree doesn't have FATTR4_WORD0_CHANGE yet.  I'm having trouble with patch 4, too.
>>
> 
> I’ve pushed out the linux-next branch http://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=shortlog;h=refs/heads/linux-next

I'll look there, then!  Thanks!

> 
>> Thanks,
>> Anna
>>
>>> 	| FATTR4_WORD0_FILEID,
>>> };
> 
