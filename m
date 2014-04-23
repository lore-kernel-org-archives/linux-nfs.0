Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:42094 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752503AbaDWNvT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Apr 2014 09:51:19 -0400
Message-ID: <5357C554.8070500@netapp.com>
Date: Wed, 23 Apr 2014 09:51:16 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Weston Andros Adamson <dros@primarydata.com>,
        Boaz Harrosh <bharrosh@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 00/17] NFS: Create a common path used by reads and writes
References: <1397768981-12856-1-git-send-email-Anna.Schumaker@Netapp.com> <5357B827.8040506@panasas.com> <5357BCD9.2@panasas.com> <21CDA162-DF2B-4C9F-A310-CCA7936817FA@primarydata.com>
In-Reply-To: <21CDA162-DF2B-4C9F-A310-CCA7936817FA@primarydata.com>
Content-Type: text/plain; charset="windows-1252"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We'll make sure it works!  I'm about to look through Dros' patches, so I'll know more soon!

Anna

On 04/23/2014 09:42 AM, Weston Andros Adamson wrote:
> Yeah there are bound to be some conflicts between these two patchsets, but
> I don’t think it should be too nasty.
> 
> Anna and I can work together to get both sets into a branch once we get things 
> reviewed.
> 
> The good news is that we can combine testing efforts - both of these patchsets
> change the read and write path for all versions of NFS, so we really need to
> make sure we didn’t break anything. Not that pnfs isn’t important ;)
> 
> -dros
> 
> On Apr 23, 2014, at 9:15 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> 
>> On 04/23/2014 03:55 PM, Boaz Harrosh wrote:
>>> On 04/18/2014 12:09 AM, Anna Schumaker wrote:
>> <>
>>> yes please keep
>>> it on a public tree for quick testing. Perhaps ask Trond to keep
>>> it on his tree in a branch. (So to get some coverage under the linux-next
>>> tree mongers from Intel)
>>>
>>
>> BTW: anyone tested how much this conflicts with dros's 17 patches?
>>     (Noticed how it is always 17 patches)
>>     If a brave sole can have both these merged on the same tree it
>>     would be easier for the testing.
>>
>> Thanks
>> Boaz
>>
> 

