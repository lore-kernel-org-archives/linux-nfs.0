Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36644 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752902AbcLSTGf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Dec 2016 14:06:35 -0500
Received: by mail-it0-f68.google.com with SMTP id n68so11372651itn.3
        for <linux-nfs@vger.kernel.org>; Mon, 19 Dec 2016 11:06:34 -0800 (PST)
Subject: Re: [PATCH 1/9] NFSv4: Don't invalidate the directory twice
To: Trond Myklebust <trondmy@primarydata.com>
References: <20161217182711.10643-1-trond.myklebust@primarydata.com>
 <20161217182711.10643-2-trond.myklebust@primarydata.com>
 <2099263b-3d8e-f237-3dd8-50dc0f63fb3e@gmail.com>
 <DBC3F2C7-BF49-4209-B403-AAEB68D0A96A@primarydata.com>
 <bc1eca55-4193-0774-054a-9047a2fdb64e@gmail.com>
 <3F416215-12B3-4C05-B595-752A80C32477@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <4b60d447-e476-dea3-a96e-401e6dfdc63e@gmail.com>
Date: Mon, 19 Dec 2016 14:05:52 -0500
MIME-Version: 1.0
In-Reply-To: <3F416215-12B3-4C05-B595-752A80C32477@primarydata.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/19/2016 12:30 PM, Trond Myklebust wrote:
> 
>> On Dec 19, 2016, at 12:07, Anna Schumaker <schumaker.anna@gmail.com> wrote:
>>
>>
>>
>> On 12/19/2016 11:56 AM, Trond Myklebust wrote:
>>> What’s the filesystem you’re testing on?
>>
>> I see this on xfs and ext4 but btrfs seems to work.  What do you mean by timestamp resolution?  I can't find the file in question in `ls`, but for another file `stat` tells me:
>>
>>  File: file.10
>>  Size: 0               Blocks: 0          IO Block: 4096   regular empty file
>> Device: fe31h/65073d    Inode: 1319795     Links: 1
>> Access: (0666/-rw-rw-rw-)  Uid: ( 1000/    anna)   Gid: (  100/   users)
>> Access: 2016-12-19 12:04:47.680033877 -0500
>> Modify: 2016-12-19 12:04:47.680033877 -0500
>> Change: 2016-12-19 12:04:47.680033877 -0500
> 
> I mean that the timestamps appear to be unable to keep up with the volume of changes on the filesystem. If the cthon test is failing here, then it’s probably because the before/after change attributes are the same… Does wireshark show that the before/after change attributes on this directory are different?

Ah, that's what you mean.  Yes, Wireshark does show the same values for before and after changeids.

Anna

> 
>>
>> I hope this helps!
>> Anna
>>>
>>>> On Dec 19, 2016, at 11:54, Anna Schumaker <schumaker.anna@gmail.com> wrote:
>>>>
>>>> Hi Trond,
>>>>
>>>> On 12/17/2016 01:27 PM, Trond Myklebust wrote:
>>>>> If an operation that modified the directory raced with a GETATTR, then we
>>>>> don't need to invalidate the directory cache more than once.
>>>>
>>>> This patch causes cthon basic tests to fail with:
>>>>
>>>> ./test6: readdir
>>>>       ./test6: (/nfs/all) unlinked 'file.0' dir entry read pass 1
>>>>       ./test6: (/nfs/all) Test failed with 1 errors
>>>> basic tests failed
>>>>
>>>> Thanks,
>>>> Anna
>>>>>
>>>>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>>>>> ---
>>>>> fs/nfs/nfs4proc.c | 3 +++
>>>>> 1 file changed, 3 insertions(+)
>>>>>
>>>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>>>> index d33242c8d95d..713932440e07 100644
>>>>> --- a/fs/nfs/nfs4proc.c
>>>>> +++ b/fs/nfs/nfs4proc.c
>>>>> @@ -1088,12 +1088,15 @@ static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo)
>>>>> 	struct nfs_inode *nfsi = NFS_I(dir);
>>>>>
>>>>> 	spin_lock(&dir->i_lock);
>>>>> +	if (dir->i_version == cinfo->after)
>>>>> +		goto out;
>>>>> 	nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
>>>>> 	if (!cinfo->atomic || cinfo->before != dir->i_version)
>>>>> 		nfs_force_lookup_revalidate(dir);
>>>>> 	dir->i_version = cinfo->after;
>>>>> 	nfsi->attr_gencount = nfs_inc_attr_generation_counter();
>>>>> 	nfs_fscache_invalidate(dir);
>>>>> +out:
>>>>> 	spin_unlock(&dir->i_lock);
>>>>> }
>>>>>
>>>>>
>>>>
>>>
>>
> 
