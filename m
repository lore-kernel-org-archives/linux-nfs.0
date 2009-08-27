From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 2/2] Enable v4 mounts when either "nfsvers=4" or "vers=4"
	option are set (vers-02)
Date: Thu, 27 Aug 2009 10:14:42 -0400
Message-ID: <4A9694D2.2030205@RedHat.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1251316764.5226.21.camel@heimdal.trondhjem.org>
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

On 08/26/2009 03:59 PM, Trond Myklebust wrote:
> On Wed, 2009-08-26 at 15:50 -0400, Chuck Lever wrote:
>> Yeah, switching file system types in the mount(2) system call is the  
>> fly in the ointment.  I'm just wondering if Trond had some thoughts  
>> about making that more feasible.
> 
> Just look at what we're already doing for NFSv4. Inside nfs4_get_sb, we
> basically do a kernel mount in order to get the real super block. We
> then simply have to attach it to the vfsmount that the sys_mount() call
> passed down to us.
Well its not nfs4_get_sb() that would have to change its nfs_get_sb()
that would have to do an nfs4 mount after it discovered the -o vers=4.
It would get very messy very quickly for absolutely no reason since 
the propose mount patch is straightforward, it works and better yet
its done! ;-)  

> 
> This really isn't anything new or difficult...
Granted, mounting from the kernel is not new, but giving sys_mount()
on file system type which ends up mounting a complete different 
file system is new... Plus architecturally that just seems wrong...
A abit incestual... would you say! ;-)

I say we go with the proposed patch since its simple, architecturally
sound, will not cause problems down the road as long as nfs4 remains
a standalone file system and its done! Plus I have a patch waiting 
in the wings that actually does make v4 the first mount that is
tried... making v4 the default version... 

steved.
