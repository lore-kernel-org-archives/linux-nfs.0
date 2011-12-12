Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:1044 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752997Ab1LLNIx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Dec 2011 08:08:53 -0500
Message-ID: <4EE5FCDB.6030001@RedHat.com>
Date: Mon, 12 Dec 2011 08:08:43 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Rick Macklem <rmacklem@uoguelph.ca>, Sorin Faibish <sfaibish@emc.com>,
        linux-nfs@vger.kernel.org, honey@citi.umich.edu, nfsv4@ietf.org,
        "Welch, Brent" <welch@panasas.com>
Subject: Re: [nfsv4] Slides from the pNFS BoF we delivered at LISA 11 - with
 attachment this time
References: <813790898.1157715.1323399200260.JavaMail.root@erie.cs.uoguelph.ca> <4EE1EC49.6010000@panasas.com>
In-Reply-To: <4EE1EC49.6010000@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/09/2011 06:08 AM, Boaz Harrosh wrote:
> On 12/09/2011 04:53 AM, Rick Macklem wrote:
>> Thanks for the slides, Sorin.
>>
>> Just fyi, it was correct to not mention a FreeBSD client, since the
>> 4.1 client code hasn't made it into any release yet. It is available
>> as a patch against the FreeBSD9.0 kernel, in case anyone is interested:
>>    http://people.freebsd.org/~rmacklem/nfsv4.1-client/nfsv41.patch
>>
>> I am just starting to work on the logistics of getting this into the
>> FreeBSD source tree, so it may be in a FreeBSD9.n release, where n > 0.
>>
>> Also, the above does not include any pNFS support. I am about ready to
>> start coding pNFS client stuff, which brings me to...
>> - It will be difficult for me to make much progress without any
>>   pNFS servers to test against. (The only NFSv4.1 server I have to
>>   test against is Fedora15 and I don't think it knows how to do pNFS?
>>   If there is a way to make Fedora15/16 (or any other freebie Linux
>>   distro) do pNFS, please let me know.
>>
>> If others have suggestions on how I might gain access to pNFS servers
>> for testing, I would appreciate hearing. (However, I am not funded to
>> do any of this, so the suggestions can't include my spending $$$. I can
>> make it to a Bakeathon when it happens to be close to where I am, so I
>> can show up "on the cheap", like I did last June in Ann Arbor.)
>>
> 
> One way to go is the Linux pnfs project at linux-nfs.org start here:
> http://wiki.linux-nfs.org/wiki/index.php/PNFS_Development_Git_tree
> 
> It is an NFSD linux Kernel server with pNFS extensions destined to
> be part of Linux at some future release.
> 
> You will need to compile your own Kernel, or alternatively this Kernel
> is available in rpm form  from Steve Dickson for some Fedoras:
> http://steved.fedorapeople.org/repos/pnfs/
These are a bit crusty... Since pNFS is enabled in F16 kernels and
beyond, I would suggest for a recent kernel, either download one
from the rawhide repo or just grab one from here
     http://koji.fedoraproject.org/koji/packageinfo?packageID=8

> 
> The easiest is to first use the what is called pnfs-exp which is an MDS
> plus a single DS exporting any local file system.
Yes, this is by far the easiest... I've done some "hello world" testing
with this code and it seems fairly stable.. The code is on the 
pnfsd-lexp branch in Benny's tree
    git://linux-nfs.org/~bhalevy/linux-pnfs.git

Its a fairly simple process to port that code into a Fedora kernel rpm.
If that would help... just let me know...

steved.

> 
> Then you can also export a GFS2 read-only and an EXOFS which is a full
> fixture pnfs-objects based cluster filesystem.
> 
> The Luster patch suggested to you is also based on above Benny's tree.
> 
> I have on my todo list a full osd (pnfs-objects) stack port to FreeBSD
> But that's in the far future. 
> Meanwhile I'd suggest the pnfs-client-core to layout-driver API be closely
> crafted to match that of the Linux LD API so it could be kept the same
> code base. For example the pnfs-objects LD is mostly pure C code relying
> on the ORE (Objects Raid Engine). The ORE is multy licensed library that
> has ports to Many platforms including Linux-Kernel 
> Linux/FreeBSD/windows User-Mode and more of which only the Linux variants
> actually run because of the need of the iscsi stack to support BiDi and
> large CDB commands, Only supported by Linux.
> 
> Cheers
> Boaz
> 
>> rick
>>
>> ----- Original Message -----
>>> On Thu, 08 Dec 2011 19:40:19 -0500, Sorin Faibish <sfaibish@emc.com>
>>> wrote:
>>>
>>>> Attached please find the slides that we presented yesterday at
>>>> USENIX
>>>> LISA 11
>>>> conference in Boston. We would like to get more detailed input on
>>>> other
>>>> OS
>>>> that will support pNFS server/client (this is for Rick as well) that
>>>> were
>>>> not mentioned in this slide set.
>>>>
>>>> /Sorin
>>>>
>>>
>>>
>>>
>>> --
>>> Best Regards
>>> Sorin Faibish
>>> Corporate Distinguished Engineer
>>> Unified Storage Division
>>>
>>> EMC²
>>> where information lives
>>>
>>> Phone: 508-435-1000 x 48545
>>> Cellphone: 617-510-0422
>>> Email : sfaibish@emc.com
>> _______________________________________________
>> nfsv4 mailing list
>> nfsv4@ietf.org
>> https://www.ietf.org/mailman/listinfo/nfsv4
> 
