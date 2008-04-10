From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS: unknown mount option: grpid
Date: Thu, 10 Apr 2008 11:17:48 -0400
Message-ID: <A5A48540-EC83-422F-A566-324A5F141339@oracle.com>
References: <47FE0C42.6030900@TechFak.Uni-Bielefeld.DE>
	<56D1CF7A-BB26-4D07-B47D-9D43D55A1B8F@oracle.com>
	<47FE2C2D.1070703@redhat.com>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset="us-ascii"
Cc: NFS list <linux-nfs@vger.kernel.org>,
	Jan Sanders <jsanders@TechFak.Uni-Bielefeld.DE>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <47FE2C2D.1070703@redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 10, 2008, at 11:03 AM, Peter Staubach wrote:
> Chuck Lever wrote:
>> Hi Jan-
>>
>> On Apr 10, 2008, at 8:46 AM, Jan Sanders wrote:
>>
>>> Hi all,
>>>
>>> I have come across a little NFS problem.
>>>
>>> My nfs client, a Ubuntu-Hardy machine with nfs-common-1.1.2 tries to
>>> mount a directory but fails complaining
>>>
>>> Apr 10 12:18:34 sorpe kernel: [  490.911951]NFS: unknown mount   
>>> option: grpid
>>>
>>> The mount options are rw,nosuid,grpid. The mount is done by  
>>> autofs but
>>> trying to mount the directory usdin the same options rw,nosuid,grpid
>>> results in the same error.
>>> I checked using strace that the mount call was indeed done using   
>>> grpid.
>>> The mount call returns with EINVAL invalis argument.
>>>
>>>  From strace:
>>> mount("nfs-server:/volumes/www", "/vol/www", "nfs", MS_NOSUID,
>>> "grpid,addr=192.168.0.123") = -1 EINVAL (Invalid argument)
>>>
>>
>> grpid isn't a valid NFS mount option; it's valid only for xfs and   
>> ext2/3, according to mount(8).
>>
>> I can't explain why the earlier version of mount.nfs didn't  
>> complain  about it.
>>
>>
>
> I thought that the NFS mount command was supposed to ignore
> mount options that it didn't understand.  It could perhaps
> give a warning message, but should mount anyway.
>
> I thought that this behavior was useful for automounter
> applications which have to be able to share maps in a
> heterogeneous environment.


Well, it does ignore legacy NFS mount options that are no longer  
supported.

However, I was not aware of a requirement for NFS mount to ignore all  
options it doesn't understand.

It's easy enough to add, I suppose.  Community opinion?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
