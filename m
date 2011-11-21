Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-fx0-f46.google.com ([209.85.161.46]:51423 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752572Ab1KUL6j convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Nov 2011 06:58:39 -0500
Received: by fagn18 with SMTP id n18so5834031fag.19
        for <linux-nfs@vger.kernel.org>; Mon, 21 Nov 2011 03:58:38 -0800 (PST)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
In-Reply-To: <CAGue13qFrbAzdctJsTyHUzRNGxbp+mjRoM_j7qiZdGip=H_Dcw@mail.gmail.com>
References: <CAGue13qcDxW9wFfuVuRnbZBcxuTWaXzW8CK1VFWj9483ardp0g@mail.gmail.com>
	<1320699485.7987.9.camel@lade.trondhjem.org>
	<CAGue13pZvA-fBfudje_UccAosLpy0VVUzgr2YHM_57nPamyWTQ@mail.gmail.com>
	<CAGue13qFrbAzdctJsTyHUzRNGxbp+mjRoM_j7qiZdGip=H_Dcw@mail.gmail.com>
Date: Mon, 21 Nov 2011 12:58:38 +0100
Message-ID: <CAGue13qTjinRwAi4mmeyo66SxaFMD=mK10sWVba9A79EYpShkQ@mail.gmail.com>
Subject: Re: regression in referrals resolution
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

are you considering to push this fix upstream?

Tigran.

On Wed, Nov 9, 2011 at 11:25 AM, Tigran Mkrtchyan
<tigran.mkrtchyan@desy.de> wrote:
> Hi Trond,
>
> your fix is still not in bugfixes branch yet....
>
>
> Regards,
>   Tigran.
>
> On Mon, Nov 7, 2011 at 10:18 PM, Tigran Mkrtchyan
> <tigran.mkrtchyan@desy.de> wrote:
>> On Mon, Nov 7, 2011 at 9:58 PM, Trond Myklebust
>> <Trond.Myklebust@netapp.com> wrote:
>>> On Mon, 2011-11-07 at 21:29 +0100, Tigran Mkrtchyan wrote:
>>>> Hi,
>>>>
>>>>
>>>> today we was running test with referrals and notice that 'current'
>>>> 3.1+ has a regression.
>>>> The referrals are resolved, but client returns IO error :
>>>
>>> Doh! I expect that the following should fix it...
>>
>> In did!
>>
>> Thanks,
>>   Tigran.
>>>
>>> Thanks
>>>  Trond
>>> 8<--------------------------------------------------------------------------
>>> From 91207dc6fd4fbe5f758dd2558e927bcd0c411581 Mon Sep 17 00:00:00 2001
>>> From: Trond Myklebust <Trond.Myklebust@netapp.com>
>>> Date: Mon, 7 Nov 2011 15:50:32 -0500
>>> Subject: [PATCH] NFS: Fix a regression in the referral code
>>>
>>> Fix a regression that was introduced by commit
>>> 0c2e53f11a6dae9e3af5f50f5ad0382e7c3e0cfa (NFS: Remove the unused
>>> "lookupfh()" version of nfs4_proc_lookup()).
>>>
>>> In the case where the lookup gets an NFS4ERR_MOVED, we want to return
>>> the result of nfs4_get_referral(). Instead, that value is getting
>>> clobbered by the call to nfs4_handle_exception()...
>>>
>>> Reported-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
>>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>>> ---
>>>  fs/nfs/nfs4proc.c |    3 +--
>>>  1 files changed, 1 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>> index 069cb80..be2bbac 100644
>>> --- a/fs/nfs/nfs4proc.c
>>> +++ b/fs/nfs/nfs4proc.c
>>> @@ -2464,8 +2464,7 @@ static int nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir, struct qst
>>>                case -NFS4ERR_BADNAME:
>>>                        return -ENOENT;
>>>                case -NFS4ERR_MOVED:
>>> -                       err = nfs4_get_referral(dir, name, fattr, fhandle);
>>> -                       break;
>>> +                       return nfs4_get_referral(dir, name, fattr, fhandle);
>>>                case -NFS4ERR_WRONGSEC:
>>>                        nfs_fixup_secinfo_attributes(fattr, fhandle);
>>>                }
>>> --
>>> 1.7.7
>>>
>>>
>>> --
>>> Trond Myklebust
>>> Linux NFS client maintainer
>>>
>>> NetApp
>>> Trond.Myklebust@netapp.com
>>> www.netapp.com
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
>
