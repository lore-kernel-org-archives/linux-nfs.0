From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/2] Enable v4 mounts when either "nfsvers=4" or "vers=4"
	option are set (vers-02)
Date: Wed, 26 Aug 2009 12:35:17 -0400
Message-ID: <23199F1A-EA23-4DE1-AAB8-92D4B508C865@oracle.com>
References: <4A9424DB.2040303@RedHat.com> <4A942593.8030101@RedHat.com>
	<CF5F0448-E859-4EA2-805B-909B8C907533@oracle.com>
	<4A943914.9020104@RedHat.com>
	<7AB7BC01-F9E5-4611-BB4B-2B6E27069631@oracle.com>
	<4A944645.1020003@RedHat.com>
	<1251233345.25372.67.camel@heimdal.trondhjem.org>
	<B62E906B-F215-4400-B48D-DDE2C8428F9E@oracle.com>
	<4A954FBF.3030606@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset="us-ascii"; Format="flowed"; DelSp="yes"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4A954FBF.3030606@RedHat.com>
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


On Aug 26, 2009, at 11:07 AM, Steve Dickson wrote:

> On 08/26/2009 10:20 AM, Chuck Lever wrote:
>> On Aug 25, 2009, at 4:49 PM, Trond Myklebust wrote:
>>> On Tue, 2009-08-25 at 16:15 -0400, Steve Dickson wrote:
>>>>
>>>> On 08/25/2009 03:32 PM, Chuck Lever wrote:
>>>>> On Aug 25, 2009, at 3:18 PM, Steve Dickson wrote:
>>>>>> On 08/25/2009 02:59 PM, Chuck Lever wrote:
>>>>>>> On Aug 25, 2009, at 1:55 PM, Steve Dickson wrote:
>>>>>>>> commit 1471d23d692efc7388794a8a3c3b9e548d1c5be8
>>>>>>>> Author: Steve Dickson <steved@redhat.com>
>>>>>>>> Date:   Tue Aug 25 12:15:18 2009 -0400
>>>>>>>>
>>>>>>>> Make sure umount use correct fs type.
>>>>>>>>
>>>>>>>> umounts use the fs type in /etc/mtab to determine
>>>>>>>> which file system is being unmounted. The mtab
>>>>>>>> entry is create during the mount. To ensure the
>>>>>>>> correct entry is create when the fs type changes
>>>>>>>> due to the mount options, the address of the fs_type
>>>>>>>> variable has to be passed so it can be updated.
>>>>>>>
>>>>>>> In general, my policy is to record the user requested mount
>>>>>>> options in
>>>>>>> /etc/mtab, and let umount.nfs handle renegotiating as needed.   
>>>>>>> For
>>>>>>> version/transport this means that the server's configuration can
>>>>>>> change
>>>>>>> between the mount and the umount, and the umount will still  
>>>>>>> work.
>>>>>>>
>>>>>>> Perhaps this is not a consideration for NFSv4, but leaving the  
>>>>>>> mount
>>>>>>> options as specified by the user would save the need to update  
>>>>>>> the fs
>>>>>>> type, and would be a consistent policy for v2, v3, and v4.  I
>>>>>>> think it
>>>>>>> would be cleaner to teach umount.nfs to do the right thing with
>>>>>>> "-t nfs
>>>>>>> -o v4" rather than rewriting the options in /etc/mtab.
>>>>>> Since nfs4 is truly a separate/different file system from nfs  
>>>>>> in the
>>>>>> kernel, I think we should continue making that distinction in  
>>>>>> system
>>>>>> files like mtab and /proc/mounts....
>>>>>
>>>>> We are teaching mount.nfs not to care about nfs/nfs4 (at least
>>>>> externally).  Why should umount.nfs?
>>>> That's not quite accurate... IMHO.. I see it as we are teach
>>>> mount.nfs to
>>>> accept new command line arguments that will cause a nfs4 file  
>>>> system
>>>> to be mounted... and that is done by caring which fs type mount is
>>>> dealing with...
>>>
>>> So, why couldn't we just do this in the kernel? It should be easily
>>> doable to set nfs -overs=4 to mount an NFSv4 filesystem. We only  
>>> have to
>>> do this for text mounts...
>>
>> I think that would be a much better approach.  If nfs4 goes away
>> someday, for example, it will be completely transparent to the mount
>> command if we've already pushed "-t nfs, vers=4" conversion into the
>> kernel.
> Well when/if that day comes, we can easily pull the patches from the  
> mount
> command.

You know it's never that easy.  The mount command has to keep legacy  
logic for older kernels.  I'm just saying that the less the mount  
command has to worry about what kernel version is running, the cleaner  
the mount command will be.

>> We are pushing all of the details of NFS mounting into the kernel
>> anyway, over time.
> Which I've never been a fan of... Again it's much easier change user
> level code (and more people can do it) than kernel code... especially
> with things of this nature...

People can continue to change the mount command all they want.  In  
fact the user space text-based option parsing code is pretty darn  
flexible as it is now.

I don't think we're denying that your proposal is expedient.  The  
question I think is where we want to be in the long run, and if your  
proposed method to handle -t nfs -o vers=4 will make it more  
complicated to get there.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
