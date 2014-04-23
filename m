Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([209.166.131.148]:37102 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752386AbaDWOAA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Apr 2014 10:00:00 -0400
Message-ID: <5357C74C.2050106@panasas.com>
Date: Wed, 23 Apr 2014 16:59:40 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
Reply-To: <bharrosh@panasas.com>
MIME-Version: 1.0
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Weston Andros Adamson <dros@primarydata.com>
CC: Trond Myklebust <Trond.Myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 00/17] NFS: Create a common path used by reads and writes
References: <1397768981-12856-1-git-send-email-Anna.Schumaker@Netapp.com> <5357B827.8040506@panasas.com> <5357BCD9.2@panasas.com> <21CDA162-DF2B-4C9F-A310-CCA7936817FA@primarydata.com> <5357C554.8070500@netapp.com>
In-Reply-To: <5357C554.8070500@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks guys. once you have some combined tree I'll run some tests to help
you out on the pnfs end. I'd test each one separately but if you are going
to do this soon I can lazily just wait ;-)

Thanks
Boaz

On 04/23/2014 04:51 PM, Anna Schumaker wrote:
> We'll make sure it works!  I'm about to look through Dros' patches, so I'll know more soon!
> 
> Anna
> 
> On 04/23/2014 09:42 AM, Weston Andros Adamson wrote:
>> Yeah there are bound to be some conflicts between these two patchsets, but
>> I don’t think it should be too nasty.
>>
>> Anna and I can work together to get both sets into a branch once we get things 
>> reviewed.
>>
>> The good news is that we can combine testing efforts - both of these patchsets
>> change the read and write path for all versions of NFS, so we really need to
>> make sure we didn’t break anything. Not that pnfs isn’t important ;)
>>
>> -dros
>>
>> On Apr 23, 2014, at 9:15 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>>
>>> On 04/23/2014 03:55 PM, Boaz Harrosh wrote:
>>>> On 04/18/2014 12:09 AM, Anna Schumaker wrote:
>>> <>
>>>> yes please keep
>>>> it on a public tree for quick testing. Perhaps ask Trond to keep
>>>> it on his tree in a branch. (So to get some coverage under the linux-next
>>>> tree mongers from Intel)
>>>>
>>>
>>> BTW: anyone tested how much this conflicts with dros's 17 patches?
>>>     (Noticed how it is always 17 patches)
>>>     If a brave sole can have both these merged on the same tree it
>>>     would be easier for the testing.
>>>
>>> Thanks
>>> Boaz
>>>
>>
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

