Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:64338 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757803Ab1FJT3s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 15:29:48 -0400
Received: by iwn34 with SMTP id 34so2413482iwn.19
        for <linux-nfs@vger.kernel.org>; Fri, 10 Jun 2011 12:29:47 -0700 (PDT)
Message-ID: <4DF270A9.1030508@panasas.com>
Date: Fri, 10 Jun 2011 15:29:45 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Boaz Harrosh <bharrosh@panasas.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/5] NFSv4.1: Add an initialisation callback for pNFS
References: <1307669462-15764-1-git-send-email-Trond.Myklebust@netapp.com>		 <1307669462-15764-2-git-send-email-Trond.Myklebust@netapp.com>		 <1307669462-15764-3-git-send-email-Trond.Myklebust@netapp.com>		 <1307669462-15764-4-git-send-email-Trond.Myklebust@netapp.com>		 <4DF1871C.1070001@panasas.com> <4DF19841.5030904@panasas.com>		 <4DF19D7B.2060308@panasas.com> <4DF1A106.3070205@panasas.com>		 <4DF242D7.4030607@panasas.com>	 <1307723298.19554.8.camel@lade.trondhjem.org>	 <4DF24CF0.3030507@panasas.com> <1307727140.19554.19.camel@lade.trondhjem.org>
In-Reply-To: <1307727140.19554.19.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-06-10 13:32, Trond Myklebust wrote:
> On Fri, 2011-06-10 at 09:57 -0700, Boaz Harrosh wrote: 
>> On 06/10/2011 09:28 AM, Trond Myklebust wrote:
>>>>
>>>> That makes it even more complicated for a do nothing function. We dont do
>>>> a different function for each different parameter. We can just do a 
>>>> "bool write" and unify the dam thing
>>>
>>> Right now, the nfs_pageio_descriptor doesn't know about reads vs writes.
>>> It just knows about 'coalesce requests' and 'perform i/o'. I'd prefer to
>>> keep that abstraction, as it makes things cleaner, particularly when you
>>> get to patch 5 (NFSv4.1: Fall back to ordinary i/o through the mds if we
>>> have no layout segment). Why add more 'if' statements when you don't
>>> need to...
>>>
>>
>> OK It's fine. I'm convinced. Do you have this on a git tree? I want to test
>> it out. 
> 
> I've added it to the 'nfs-for-bakeathon' branch.
> 

I've also merged it into
git://git.linux-nfs.org/~bhalevy/linux-pnfs.git nfs-upstream

and rebased everything on top of it.

>> What was the disposition of desc->pg_bsize do I need to adjust it for the
>> pnfs_case in objlayout?
> 
> You might need to adjust it. Please check...
> 

As long the the MDS [rw]size are larger or equal to PAGE_SIZE
I believe you should be OK.

> I'm still working on the 'fallback to write through mds' case to ensure
> that we re-coalesce if the call to pnfs_try_to_read_data() and
> pnfs_try_to_write_data(). Once that is done, I think that the objects
> code will always do the right thing and I anticipate that the blocks
> code can reuse the same code...

Right.

Thanks for picking this up!

Benny

> 
> Cheers
>   Trond
> 
