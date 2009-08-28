From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 2/2] Enable v4 mounts when either "nfsvers=4" or "vers=4"
	option are set (vers-02)
Date: Thu, 27 Aug 2009 22:55:16 -0400
Message-ID: <4A974714.4080509@RedHat.com>
References: <4A9424DB.2040303@RedHat.com> <4A942593.8030101@RedHat.com>	
	<CF5F0448-E859-4EA2-805B-909B8C907533@oracle.com>	
	<4A943914.9020104@RedHat.com>	
	<7AB7BC01-F9E5-4611-BB4B-2B6E27069631@oracle.com>	
	<4A944645.1020003@RedHat.com>	
	<1251233345.25372.67.camel@heimdal.trondhjem.org>	
	<B62E906B-F215-4400-B48D-DDE2C8428F9E@oracle.com>	
	<4A954FBF.3030606@RedHat.com>	
	<23199F1A-EA23-4DE1-AAB8-92D4B508C865@oracle.com>	
	<4A956BF2.6000902@RedHat.com>	
	<F805BE4F-BA72-4B13-A60A-B298C69611C8@oracle.com>	
	<4A95760C.9000604@RedHat.com>	
	<B26EBCDF-5836-440E-81D5-5E089158BFE1@oracle.com>
	<1251316764.5226.21.camel@heimdal.trondhjem.org>
	<4A9694D2.2030205@RedHat.com>
	<4A4EE1FA-209C-44D3-B418-96ABC18F9E3D@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4A4EE1FA-209C-44D3-B418-96ABC18F9E3D@oracle.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/27/2009 01:32 PM, Chuck Lever wrote:
>>> Just look at what we're already doing for NFSv4. Inside nfs4_get_sb, we
>>> basically do a kernel mount in order to get the real super block. We
>>> then simply have to attach it to the vfsmount that the sys_mount() call
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
IMHO... adding a simple short cut to the mounting code is inherently simpler 
and less risky than changing kernel code...

> 
> I hear your point that you want this done for RHEL 6.  
Wrong! What I'm trying to do is move the Linux NFS implementation 
forward for ALL distros and more importantly for the community as a whole... 


> But I'm concerned that going with the mount command solution will make our 
> lives more challenging after RHEL 6 is come and gone.
Please.. Lets keep this in perspective.. My little short cut patch will
have absolutely no effect on our technology 2 to 3 years when RHEL 6
be comes active... I can speak from experience...   

>  It seems to me that upstream is less concerned with expediency and 
> more concerned with good long term solutions.
Expediency?? NFS v4 was first introduced in Fedora 2 which was released
in the middle of 2004... that's over five years ago... So I have to respectfully
disagree with the term expediency... 

> 
> I'm going to ask around about this.  If it really does look offensive to
> people, or technically infeasible, or will take a ridiculously long time
> to implement correctly, I'm OK with the mount command solution.  I think
> we can afford to investigate a little more if we can find a solution
> that gets us farther down the road.  All I'm asking for is a little time
> to study the problem.
To study what? All the patch does is make easier to mount a file system
that has been in the mainstream kernel since 2.6.5... Remember, people
do not have to use the "-o v4' option... the '-t nfs4' option will 
continue to work... 
 
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
Which is a bit ironic... It appears to me that the rest of the 
Linux kernel community is actually moving things out of the kernel which
actually makes sense IMHO... Just because we adopted the Solaris way of 
moving the parsing of mount options into the kernel does not mean its
the right thing to do... And in the end... goals do change... 

> 
>> will not cause problems down the road as long as nfs4 remains
>> a standalone file system and its done!
> 
> We know for _sure_ that at some point nfs4 will likely no longer be
> visible to user space (or gone completely)...  so that last point is
> rather moot.  Doing it in the mount command _will_ increase mount
> command complexity down the road.
I can't disagree with this more... All this patch does make it easier to
mount an *existing* file system... Now if that file system goes away,
so be it.. changes will have to make... and the least of our problems
will removing this simple short cut to mount that file system.

At the end of the day..  'mount -o v4' will *always* work, whether 
the nfs4 file system is or is not visible from user space... 

If or when the kernel no longer support a nfs4 file system, we will *have* to
change the mount version since mount.nfs4 will no longer be valid and
we will have to put in some safeguards to be backwards compatible...
We have done it in the past and will have to do it again... The proposed
patch does not change that fact whatsoever... 

So I see absolutely no reason not to make it easier for our community 
to use the technology we have worked so hard on, for so long, now.
And that's exactly what this patch does... 

steved.
