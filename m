From: Chuck Lever <cel@citi.umich.edu>
Subject: Re: [NFS] Re: [PATCH][RFC] NFS: Improving the access cache
Date: Sun, 07 May 2006 23:23:16 -0400
Message-ID: <445EB9A4.2080705@citi.umich.edu>
References: <444EC96B.80400@RedHat.com>	<17486.64825.942642.594218@cse.unsw.edu.au>	<444F88EF.5090105@RedHat.com>	<17487.62730.16297.979429@cse.unsw.edu.au>	<44572B33.4070100@RedHat.com>	<445834CB.4050408@citi.umich.edu> <17502.45182.130630.119304@cse.unsw.edu.au>
Reply-To: cel@citi.umich.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Steve Dickson <SteveD@redhat.com>, nfs@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17502.45182.130630.119304@cse.unsw.edu.au>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Neil Brown wrote:
> On Wednesday May 3, cel@citi.umich.edu wrote:
>> For the sake of discussion, let me propose some design alternatives.
>>
>> 1.  We already have cache shrinkage built in: when an inode is purged 
>> due to cache shrinkage, the access cache for that inode is purged as 
>> well.  In other words, there is already a mechanism for external memory 
>> pressure to shrink this cache.  I don't see a strong need to complicate 
>> matters by adding more cache shrinkage than already exists with normal 
>> inode and dentry cache shrinkage.
> 
> If you have one particular file that is used regularly - and so never
> falls out of cache - and is used occasionally by every single user in
> your system, then that one inode could contribute to thousands of
> access cache items that will never be purged.

I speculate that this would not be a problem.

First, each entry in the cache is not going to be very large.  For the 
sake of easy math, let's say each one is 32 bytes.  One hundred thousand 
of these is a little more than 3MB.  Or, say we have ten thousand files 
with 10 different access cache entries: again, that's just about 3MB. 
(Naturally I'm ignoring the slab accounting overhead).

Even a single-user system these days is going to have a gigabyte or more 
of RAM, so we're talking less than a percent of memory tied up in this 
case.  Three megabytes is probably less memory than a single Gnome 
application uses for its working set.

I'm always told to start with a design that is as simple as possible 
(and no simpler) and build on it only when I find a problem; this avoids 
overdesign.  I don't see a compelling reason to start with a complicated 
design here, and there are good reasons to keep it simple.

If allowing the access cache to grow potentially without bounds still 
makes you nervous, I maintain that we still want to avoid a global LRU. 
  Having an LRU _per-inode_ might be a simple way to limit the amount of 
memory that is consumed without the locking and management overhead of a 
global LRU.  If entries haven't been accessed in more than actimeo 
seconds, then purge them; we'll have to go back to the server to 
revalidate such entries anyway, so there's no reason to keep them around.

It is pretty cheap to release, say, the two oldest entries every time 
you try an access, provided they have not been touched in actimeo seconds.

-- 
corporate:	<cel at netapp dot com>
personal:	<chucklever at bigfoot dot com>
