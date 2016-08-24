Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60886 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754699AbcHXNPC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 24 Aug 2016 09:15:02 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@primarydata.com>
Cc: "List Linux NFS Mailing" <linux-nfs@vger.kernel.org>
Subject: Re: I can't get no readdir satisfaction
Date: Wed, 24 Aug 2016 09:15:00 -0400
Message-ID: <DAD7F8C9-4C16-495F-B7CE-CE7AC34EDF92@redhat.com>
In-Reply-To: <81D2E080-0697-4B26-BE38-5E8AC35C2EA4@primarydata.com>
References: <778246F3-8F24-48FD-AEA9-0BCC0DCD93B3@redhat.com>
 <F9D0E173-9E64-4BC4-87FB-0F6F4EEBF4C7@primarydata.com>
 <98E39192-4203-4EB8-BDE0-2A4ABFCAA92B@redhat.com>
 <81D2E080-0697-4B26-BE38-5E8AC35C2EA4@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Apologies for the overlapping messages.. I had a mailer issue that 
caused me
to miss this message.

On 24 Aug 2016, at 8:18, Trond Myklebust wrote:
>> On Aug 23, 2016, at 17:21, Benjamin Coddington <bcodding@redhat.com> 
>> wrote:
>> So, for directories with a large number of entries that updates 
>> often, it can
>> be very slow to list the directory.
>>
>> Why did 311324ad1713 change nfs_readdir from
>>
>> if (nfs_attribute_cache_expired(inode))
>>    nfs_revalidate_mapping(inode, file->f_mapping);
>> to
>>
>> if (nfs_attribute_cache_expired(inode) || nfsi->cache_validity & 
>> NFS_INO_INVALID_DATA)
>>    nfs_revalidate_mapping(inode, file->f_mapping);
>
> As the commit message says, the whole purpose was to use READDIRPLUS 
> as a substitute for multiple GETATTR calls when the heuristic tells us 
> that the user is performing an ‘ls -l’ style of workload.
>
>>
>> .. and can we go back to the way it was before?
>
> Not without slowing down ‘ls -l’ on large directories.

Ah, so my musing is not about reverting the READDIRPLUS optimization, 
just
the bit where we revalidate the mapping if NFS_INO_INVALID_DATA.

I'll send a patch for that, let's see what happens to it!

>> OK.. I understand why -- it is more correct since if we know the 
>> directory has
>> changed, we might as well fetch the change.  Otherwise, we might be 
>> creating
>> files and then wondering why they aren't listed.
>>
>> It might be nicer to not invalidate the mapping we're currently using 
>> for
>> readdir, though.  Maybe there's a way to keep the mapping for the 
>> currently
>> opened directory and invalidate it once it's closed.
>
>  POSIX requires that you revalidate on opendir() and rewinddir(), and
>  leaves behaviour w.r.t. file addition and removal after the call to
>  opendir()/rewinddir() undefined
>  
> (http://pubs.opengroup.org/onlinepubs/9699919799/functions/readdir.html).
>  I believe most filesystems under Linux will ensure that if a file is
>  removed, it is no longer seen in the readdir stream, and a file that 
> is
>  added will be seen unless the readdir cursor has already passed it, 
> so
>  there is that to consider.

In the NFS case it would be up to the server to decide if it wants to 
throw
out the in-use cookiverf with BADCOOKIE, or just include the new file at
some later entry cookie.  I think if the server wanted to insert the 
entry,
it must invalidate all currently in-use cookieverf values.

> However correctness was not the main issue here.

I think by "here" you mean the READDIRPLUS optimization, and not the 
POSIX
undefined behavior, in which case I take you to mean that the main issue 
was
performance.  That's the issue at hand for the case I described as well.
Dropping the mid-directory revalidation should keep the optimization for
your case and restore the optimization for this case.

Again, apologies for the messy mail thread.  :/

Ben
