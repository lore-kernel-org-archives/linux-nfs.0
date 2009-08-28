From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/2] Enable v4 mounts when either "nfsvers=4" or
	"vers=4" option are set (vers-02)
Date: Fri, 28 Aug 2009 12:12:56 -0400
Message-ID: <20090828161256.GA2859@infradead.org>
References: <B62E906B-F215-4400-B48D-DDE2C8428F9E@oracle.com> <4A954FBF.3030606@RedHat.com> <23199F1A-EA23-4DE1-AAB8-92D4B508C865@oracle.com> <4A956BF2.6000902@RedHat.com> <F805BE4F-BA72-4B13-A60A-B298C69611C8@oracle.com> <4A95760C.9000604@RedHat.com> <B26EBCDF-5836-440E-81D5-5E089158BFE1@oracle.com> <1251316764.5226.21.camel@heimdal.trondhjem.org> <4A9694D2.2030205@RedHat.com> <4A4EE1FA-209C-44D3-B418-96ABC18F9E3D@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:45494 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751090AbZH1QM5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Aug 2009 12:12:57 -0400
In-Reply-To: <4A4EE1FA-209C-44D3-B418-96ABC18F9E3D@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 27, 2009 at 01:32:09PM -0400, Chuck Lever wrote:
>>>> about making that more feasible.
>>>
>>> Just look at what we're already doing for NFSv4. Inside nfs4_get_sb, 
>>> we
>>> basically do a kernel mount in order to get the real super block. We
>>> then simply have to attach it to the vfsmount that the sys_mount()  
>>> call
>>> passed down to us.
>> Well its not nfs4_get_sb() that would have to change its nfs_get_sb()
>> that would have to do an nfs4 mount after it discovered the -o vers=4.
>> It would get very messy very quickly for absolutely no reason since
>> the propose mount patch is straightforward, it works and better yet
>> its done! ;-)
>
> Right now we are only speculating that doing this in the kernel will not 
> be straightforward.  You say it will be unbearably ugly, and Trond says 
> it should be simple.  He said - he said.  Why not try it and find out?

It's actually trivial.  The file_system_type does not have much meaning
at all, it contains very little information:

 - the implementation module - this is obviously the same for nfs and
   nfs4
 - the name - we actually want nfs for v4 here, that's the point.
 - the get_sb method - we want to call the v4 method after initial
   option parsing.  This is totally trivial if done as a quick hack,
   but some refactoring to share code might be a better idea
 - the kill_sb method - we just need a flag to chose which one.
   Again a bit of refactoring there might not be a bad idea here either:
   e.g. why does nfs_kill_super do a bdi_unregister but nfs4_kill_super
   not.
 - the flags in fs_flags - fortunately the same for nfs and nfs4.
 - a list entry for the list of register filesystems.  That list is not
   used much:

     - for printing the list of filesystems in /proc/filesystems
     - for finding the filesystem by name using get_fs_type, mostly
       for mounting
     - for the whacko sysfs system call needing an index into this
       list.

So doing this really is easy.  And if done properly it might actually
clean the code up, too.

>
> I hear your point that you want this done for RHEL 6.  I want IPv6 done 
> for RHEL 6, but that's looking less and less likely.  If this were a 
> RHEL-only proposal, I'd be all over it.  But I'm concerned that going 
> with the mount command solution will make our lives more challenging 
> after RHEL 6 is come and gone.  It seems to me that upstream is less 
> concerned with expediency and more concerned with good long term 
> solutions.
>
> I'm going to ask around about this.  If it really does look offensive to 
> people, or technically infeasible, or will take a ridiculously long time 
> to implement correctly, I'm OK with the mount command solution.  I think 
> we can afford to investigate a little more if we can find a solution that 
> gets us farther down the road.  All I'm asking for is a little time to 
> study the problem.
>
>>> This really isn't anything new or difficult...
>> Granted, mounting from the kernel is not new, but giving sys_mount()
>> on file system type which ends up mounting a complete different
>> file system is new... Plus architecturally that just seems wrong...
>> A abit incestual... would you say! ;-)
>>
>> I say we go with the proposed patch since its simple, architecturally
>> sound,
>
> The whole point of text-based mounts is that we are supposed to be  
> building up the NFS mount stuff in the kernel, closer to where all the  
> client features are actually implemented, instead of in user space.  It 
> doesn't make sense to add logic in the mount command while our long term 
> goal is to move it to the kernel, especially if we can find a viable 
> alternative kernel implementation.
>
>> will not cause problems down the road as long as nfs4 remains
>> a standalone file system and its done!
>
> We know for _sure_ that at some point nfs4 will likely no longer be  
> visible to user space (or gone completely)...  so that last point is  
> rather moot.  Doing it in the mount command _will_ increase mount  
> command complexity down the road.
>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>
> _______________________________________________
> NFSv4 mailing list
> NFSv4@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
---end quoted text---
