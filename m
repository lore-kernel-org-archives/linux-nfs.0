Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11080 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751084AbdCNOmg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 14 Mar 2017 10:42:36 -0400
Subject: Re: Manual page bug: two inaccuracies in nfsd(7)
To: NeilBrown <neilb@suse.com>,
        Chris Siebenmann <cks.nfs01@cs.toronto.edu>
References: <20170223164644.E40565A0066@apps1.cs.toronto.edu>
 <87efyfntrm.fsf@notabene.neil.brown.name>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <94bcced9-7e14-08bd-0590-2ad6d13dab85@RedHat.com>
Date: Tue, 14 Mar 2017 10:42:35 -0400
MIME-Version: 1.0
In-Reply-To: <87efyfntrm.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/02/2017 06:28 PM, NeilBrown wrote:
> On Thu, Feb 23 2017, Chris Siebenmann wrote:
> 
>>>>  I was recently reading this manual page as part of exploring running
>>>> an NFS server on Ubuntu 16.04 (with Ubuntu's kernel '4.4.0') and found
>>>> two inaccuracies with the current state of the kernel (or at least how
>>>> it looks to me based on both experimentation and code).
>>>>
>>>>  First, there is no /proc/net/rpc/auth.domain directory and cache any
>>>> more. This was removed from the kernel in 2006 (in commit efc36aa5608f),
>>>> so I think it should be safe to remove from current versions of the
>>>> manpage.
>>>
>>> I agree.
>>>
>>>>
>>>>  Second, the manpage says about the 'flush' files to be found in eg
>>>> /proc/net/rpc/auth.unix.ip:
>>>>
>>>> 	When a number of seconds since epoch (1 Jan 1970) is written to
>>>> 	this file, all entries in the cache that were last updated before
>>>> 	that file become invalidated and will be flushed out. Writing
>>>> 	1 will flush everything. [...]
>>>>
>>>> The bit about 'writing 1 will flush everything' does not appear to be
>>>> accurate.
>>>
>>> I was never accurate.  I vaguely remember writing it.  I must have been
>>> confused.
>>>
>>> Would you be able to create a patch which fixes these issues, and post
>>> it, with a signed-off-by ?
>>
>>  Here is a patch that deletes the mention of auth.domain and changes the
>> wording around 'flush' files. I'm not attached to the revised wording;
>> it's just the best I could manage in something that felt that it was
>> within the same style and space as the current wording.
>>
>> Signed-off-by: Chris Siebenmann <cks.nfs01@cs.toronto.edu>
> 
> Thanks.
> Acked-by: NeilBrown <neilb@suse.com>
> 
> hopefully Steve will pick this up in due course.  He tends to apply
> patches in batches every few weeks.
Sorry for the delay... I just saw this... inline patches like
this sometime simple through my patch filters... ;-)

Committed!

steved.

> 
> Thanks,
> NeilBrown
> 
>>
>> diff --git a/utils/exportfs/nfsd.man b/utils/exportfs/nfsd.man
>> index 0c516fa..9efa29f 100644
>> --- a/utils/exportfs/nfsd.man
>> +++ b/utils/exportfs/nfsd.man
>> @@ -105,11 +105,6 @@ clients have for different filesystems.
>>  The caches are:
>>  
>>  .TP
>> -.B auth.domain
>> -This cache maps the name of a client (or domain) to an internal data
>> -structure.  The only access that is possible is to flush the cache.
>> -
>> -.TP
>>  .B auth.unix.ip
>>  This cache contains a mapping from IP address to the name of the
>>  authentication domain that the ipaddress should be treated as part of.
>> @@ -133,7 +128,8 @@ are:
>>  .B flush
>>  When a number of seconds since epoch (1 Jan 1970) is written to this
>>  file, all entries in the cache that were last updated before that file
>> -become invalidated and will be flushed out.  Writing 1 will flush
>> +become invalidated and will be flushed out.  Writing a time in the
>> +future (in seconds since epoch) will flush
>>  everything.  This is the only file that will always be present.
>>  
>>  .TP
>>
>>
>> 	- cks
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
