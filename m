From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/2] Enable v4 mounts when either "nfsvers=4" or "vers=4"
	option are set (vers-02)
Date: Wed, 26 Aug 2009 13:22:30 -0400
Message-ID: <F805BE4F-BA72-4B13-A60A-B298C69611C8@oracle.com>
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
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset="us-ascii"; Format="flowed"; DelSp="yes"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4A956BF2.6000902@RedHat.com>
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


On Aug 26, 2009, at 1:08 PM, Steve Dickson wrote:

> On 08/26/2009 12:35 PM, Chuck Lever wrote:
>> On Aug 26, 2009, at 11:07 AM, Steve Dickson wrote:
>>>> I think that would be a much better approach.  If nfs4 goes away
>>>> someday, for example, it will be completely transparent to the  
>>>> mount
>>>> command if we've already pushed "-t nfs, vers=4" conversion into  
>>>> the
>>>> kernel.
>>> Well when/if that day comes, we can easily pull the patches from the
>>> mount
>>> command.
>>
>> You know it's never that easy.  The mount command has to keep legacy
>> logic for older kernels.  I'm just saying that the less the mount
>> command has to worry about what kernel version is running, the  
>> cleaner
>> the mount command will be.
> Well with this patch, since we are only concentrating on text mounts,
> we are already breaking with the tradition of keeping legacy logic...
> And again as long as the nfs4 file system exists this approach will  
> work...
>
>>
>>>> We are pushing all of the details of NFS mounting into the kernel
>>>> anyway, over time.
>>> Which I've never been a fan of... Again it's much easier change user
>>> level code (and more people can do it) than kernel code...  
>>> especially
>>> with things of this nature...
>>
>> People can continue to change the mount command all they want.  In  
>> fact
>> the user space text-based option parsing code is pretty darn  
>> flexible as
>> it is now.
> Yes... the user space parsing code is very well written...
>
>>
>> I don't think we're denying that your proposal is expedient.  The
>> question I think is where we want to be in the long run,
> NFS v4 as the default protocol version followed by NFS V4.1 becoming  
> the
> default protocol version.
>
>> and if your proposed method to handle -t nfs -o vers=4 will make
>> it more complicated to get there.
> No. I'm proposing a simple shorthand patch that will make mounting  
> nfs4
> file systems easier in hope of moving the technology forward by making
> it more accessible... What I believe you are proposing is architecture
> change to hide the fact nfs and nfs4 are separate file systems...

Nope, we're proposing doing the simple method in the kernel instead of  
in the mount command.

> But in the end, if we do the simple shorthand patch (making the  
> technology
> available today) or the major architecture change (making the  
> technology
> available the distant future) with both approaches 'mount -o v4'
> will do the exact same thing...
>
> I for moving the technology today...
>
> steved.
>
>
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
