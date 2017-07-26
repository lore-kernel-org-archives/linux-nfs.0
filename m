Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:37979 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751857AbdGZNhe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Jul 2017 09:37:34 -0400
Subject: Re: [REGRESSION 4.13-rc] NFS returns -EACCESS at the first read
To: Takashi Iwai <tiwai@suse.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
References: <s5h4ltzl5oq.wl-tiwai@suse.de>
 <acfb6b19-b183-16ef-a6c5-2fc97cf8eb6b@gmail.com>
 <s5hzibrjpge.wl-tiwai@suse.de>
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <0b39602f-b92f-bc65-1116-fcf446232849@gmail.com>
Date: Wed, 26 Jul 2017 09:37:31 -0400
MIME-Version: 1.0
In-Reply-To: <s5hzibrjpge.wl-tiwai@suse.de>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/26/2017 09:30 AM, Takashi Iwai wrote:
> On Wed, 26 Jul 2017 14:57:07 +0200,
> Anna Schumaker wrote:
>>
>> Hi Takashi,
>>
>> On 07/26/2017 08:54 AM, Takashi Iwai wrote:
>>> Hi,
>>>
>>> I seem hitting a regression of NFS client on the today's Linus git
>>> tree.  The symptom is that the file read over NFS returns occasionally
>>> -EACCESS at the first read.  When I try to read the same file again
>>> (or do some other thing), I can read it successfully.
>>>
>>> The git bisection leaded to the commit
>>> bd8b2441742b49c76bec707757bd9c028ea9838e
>>>     NFS: Store the raw NFS access mask in the inode's access cache
>>>
>>>
>>> Any further hint for debugging?
>>
>> Does the patch in this email thread help? http://www.spinics.net/lists/linux-nfs/msg64930.html
> 
> Thanks, I gave it a shot and the result looks good.  Feel free to my
> tested-by tag:
>   Tested-by: Takashi Iwai <tiwai@suse.de>
> 
> 
> Though, when I look around the code, I feel somehow uneasy by that
> still MAY_XXX is used for nfs_access_entry.mask, e.g. in
> nfs3_proc_access() or nfs4_proc_access().  Are these function OK
> without the similar conversion?

I just started looking at that at the end of the day yesterday.  I think they work by accident, since all the bits in the mask are set by nfs_do_access().  They should probably be converted, but I don't think it's urgent.

Anna

> 
> 
> thanks,
> 
> Takashi
> 
