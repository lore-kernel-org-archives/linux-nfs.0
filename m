Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:34517 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754347AbaDWNmN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Apr 2014 09:42:13 -0400
Received: by mail-ie0-f175.google.com with SMTP id to1so899072ieb.34
        for <linux-nfs@vger.kernel.org>; Wed, 23 Apr 2014 06:42:13 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH 00/17] NFS: Create a common path used by reads and writes
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <5357BCD9.2@panasas.com>
Date: Wed, 23 Apr 2014 09:42:14 -0400
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond Myklebust <Trond.Myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <21CDA162-DF2B-4C9F-A310-CCA7936817FA@primarydata.com>
References: <1397768981-12856-1-git-send-email-Anna.Schumaker@Netapp.com> <5357B827.8040506@panasas.com> <5357BCD9.2@panasas.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Yeah there are bound to be some conflicts between these two patchsets, but
I don’t think it should be too nasty.

Anna and I can work together to get both sets into a branch once we get things 
reviewed.

The good news is that we can combine testing efforts - both of these patchsets
change the read and write path for all versions of NFS, so we really need to
make sure we didn’t break anything. Not that pnfs isn’t important ;)

-dros

On Apr 23, 2014, at 9:15 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:

> On 04/23/2014 03:55 PM, Boaz Harrosh wrote:
>> On 04/18/2014 12:09 AM, Anna Schumaker wrote:
> <>
>> yes please keep
>> it on a public tree for quick testing. Perhaps ask Trond to keep
>> it on his tree in a branch. (So to get some coverage under the linux-next
>> tree mongers from Intel)
>> 
> 
> BTW: anyone tested how much this conflicts with dros's 17 patches?
>     (Noticed how it is always 17 patches)
>     If a brave sole can have both these merged on the same tree it
>     would be easier for the testing.
> 
> Thanks
> Boaz
> 

