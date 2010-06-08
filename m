Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:37435 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754456Ab0FHJP5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jun 2010 05:15:57 -0400
Received: by bwz11 with SMTP id 11so1115872bwz.19
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jun 2010 02:15:56 -0700 (PDT)
Message-ID: <4C0E0A49.2040308@panasas.com>
Date: Tue, 08 Jun 2010 12:15:53 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Alexandros Batsakis <alexandros@jhu.edu>
CC: Alexandros Batsakis <batsakis@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 7/8] pnfs-submit: forgetful client (layouts)
References: <1275945113-3436-1-git-send-email-batsakis@netapp.com>	<1275945113-3436-2-git-send-email-batsakis@netapp.com>	<1275945113-3436-3-git-send-email-batsakis@netapp.com>	<1275945113-3436-4-git-send-email-batsakis@netapp.com>	<1275945113-3436-5-git-send-email-batsakis@netapp.com>	<1275945113-3436-6-git-send-email-batsakis@netapp.com>	<1275945113-3436-7-git-send-email-batsakis@netapp.com>	<1275945113-3436-8-git-send-email-batsakis@netapp.com>	<4C0DF003.4010509@panasas.com> <AANLkTim0-Gb7a-YPTgtLHY3r4OVP2x-nasug6sd_zjt9@mail.gmail.com>
In-Reply-To: <AANLkTim0-Gb7a-YPTgtLHY3r4OVP2x-nasug6sd_zjt9@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-06-08 10:51, Alexandros Batsakis wrote:
> On Tue, Jun 8, 2010 at 12:23 AM, Benny Halevy <bhalevy@panasas.com> wrote:
>> On Jun. 08, 2010, 0:11 +0300, Alexandros Batsakis <batsakis@netapp.com> wrote:
>>> +                             status = pnfs_async_return_layout(clp, inode,
>>> +                                                               args);
>>> +                             if (status == -EAGAIN)
>>> +                                     res = cpu_to_be32(NFS4ERR_DELAY);
>>
>> what about other errors?
>>
> 
> pnfs_async_return_layout does not send any RPCs, so it's either EAGAIN
> or an "out of memory" error in which case I guess it's better to
> return NFS4ERR_RESOURCE than NFS4ERR_NO_MATCHING_LAYOUT. So you are
> right, I ll send a fix.
> 

Note that NFS4ERR_RESOURCE is no longer a valid status
in nfsv4.1 NFS4ERR_DELAY might be a better choice for -ENOMEM.
NFS4ERR_NO_MATCHING_LAYOUT should never be returned unless
you're sure you have no layout to return or you had one
and forgot everything about it.

For any other error I'd BUG() and return NFS4ERR_DELAY.

>>> +                             iput(inode);
>>>                       }
>>> +             } else { /* _ALL or _FSID */
>>> +                     /* we need the inode to get the nfs_server struct */
>>> +                     inode = nfs_layoutrecall_find_inode(clp, args);
>>> +                     if (!inode)
>>> +                             goto loop;
>>> +                     status = pnfs_async_return_layout(clp, inode, args);
>>> +                     if (status == -EAGAIN)
>>> +                             res = cpu_to_be32(NFS4ERR_DELAY);
>>
>> ditto
>>

<snip>

>>> @@ -1044,7 +1055,7 @@ pnfs_update_layout(struct inode *ino,
>>>       struct nfs4_pnfs_layout_segment arg = {
>>>               .iomode = iomode,
>>>               .offset = 0,
>>> -             .length = ~0
>>> +             .length = NFS4_MAX_UINT64,

sorry, this is just cosmetic (my bad)

Benny
