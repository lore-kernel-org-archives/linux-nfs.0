From: Peter Staubach <staubach@redhat.com>
Subject: Re: [NFS] Re: [PATCH][RFC] NFS: Improving the access cache
Date: Mon, 08 May 2006 10:07:40 -0400
Message-ID: <445F50AC.1070306@redhat.com>
References: <444EC96B.80400@RedHat.com>	<17486.64825.942642.594218@cse.unsw.edu.au>	<444F88EF.5090105@RedHat.com> <17487.62730.16297.979429@cse.unsw.edu.au> <44572B33.4070100@RedHat.com> <445834CB.4050408@citi.umich.edu> <445B5C2D.5040404@RedHat.com> <445B66E6.7030700@redhat.com> <445CB41A.9040400@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <445CB41A.9040400@RedHat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Steve Dickson wrote:

> Peter Staubach wrote:
>
>>>>
>>>> 2.  Use a radix tree per inode.  
>>>
>>>
>>>
>>> Using radix trees actual makes things much simpler... Good idea, imo.
>>>
>>
>> It does seem like a good idea, although just using the uid is not 
>> sufficient
>> to identify the correct access cache entry.  The group and groups 
>> list must
>> also be used.  Can the radix tree implementation support this?
>
> We could use (nfsi + uid) as the index... but its not clear what that
> would buys us... And the group and group list were never part of the
> cache in the first place.... is this something you feel needs to be
> added or am I just not understanding.... 


Yes, I believe that the entire user identification, uid, gid, groups list,
needs to be used to identify the correct cache entry.  An easy example of
differing access rights, but with the same uid, is an application which is
setgid.

I believe that the "key" to the cache entry should be the entire user
identification that the NFS server sees and uses when calculating access
rights.  Using the uid as part of a hash key is okay and probably a good
idea, but I don't think that the uid is sufficient to completely identify
a specific cache entry.

Given this, then I suspect that the current access cache is broken...

    Thanx...

       ps
