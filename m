From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/2] Enable v4 mounts when either "nfsvers=4" or "vers=4"
	option are set (vers-02)
Date: Wed, 26 Aug 2009 15:50:21 -0400
Message-ID: <B26EBCDF-5836-440E-81D5-5E089158BFE1@oracle.com>
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
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset="us-ascii"; Format="flowed"; DelSp="yes"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4A95760C.9000604@RedHat.com>
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

On Aug 26, 2009, at 1:51 PM, Steve Dickson wrote:
> On 08/26/2009 01:22 PM, Chuck Lever wrote:
>>>> and if your proposed method to handle -t nfs -o vers=4 will make
>>>> it more complicated to get there.
>>> No. I'm proposing a simple shorthand patch that will make mounting  
>>> nfs4
>>> file systems easier in hope of moving the technology forward by  
>>> making
>>> it more accessible... What I believe you are proposing is  
>>> architecture
>>> change to hide the fact nfs and nfs4 are separate file systems...
>>
>> Nope, we're proposing doing the simple method in the kernel instead  
>> of
>> in the mount command.
>>
> My apologize then... I was misinterpreting what you guys were  
> suggesting..
> (email sometimes causes that... :-\ )
>
> I don't think the -o v4 translation will be as easy as a
> "simple method in the kernel" and it surely will not be as simple
> and unintrusive as the patch I'm proposing.... Here is why...
>
> From an Linux  architecture standpoint the mount command *always*
> know what file system its mounting. There not been a precedence set
> where mount, mounts one file system which turns into mounting a
> different file system. Meaning there is no kernel support for
> nfs_get_sb() to all of sudden decide to roll back the system call
> and jump into nfs4_get_sb() (or vice a versa depending on which is the
> default).

Yeah, switching file system types in the mount(2) system call is the  
fly in the ointment.  I'm just wondering if Trond had some thoughts  
about making that more feasible.

> Of course we could set that precedence and quit frank we would have
> to. I'm not totally against that, although other in the kernel  
> community
> might be...
>
> But there is no way that re-architecturing of kernel will as simple
> and straightforward as following the Linux standard architecture of
> having mount, mount the correct file system.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
