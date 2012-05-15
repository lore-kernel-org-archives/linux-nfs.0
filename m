Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:37665 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933069Ab2EOPGa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 11:06:30 -0400
Message-ID: <4FB270E9.5000904@panasas.com>
Date: Tue, 15 May 2012 18:06:17 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Idan Kedar <idank@tonian.com>
CC: Johannes Schild <JSchild@gmx.de>, <osd-dev@open-osd.org>,
        <linux-nfs@vger.kernel.org>
Subject: Re: Questions about Exofs
References: <20120515090332.182970@gmx.net> <4FB22658.9010909@panasas.com> <20120515121931.192500@gmx.net> <CABpMAy+bV7-UZU0gGOFWk+ZfHLGi+D=ntNLjRHFYZzTtwXG_RA@mail.gmail.com> <4FB25D2F.1070403@panasas.com> <CABpMAyJ9F5c52ntMCL1+gwDCcbMYMEkxVEHW7bfpjm6H5boSCg@mail.gmail.com>
In-Reply-To: <CABpMAyJ9F5c52ntMCL1+gwDCcbMYMEkxVEHW7bfpjm6H5boSCg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/15/2012 05:22 PM, Idan Kedar wrote:

> On Tue, May 15, 2012 at 4:42 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
<snip>

>> This should not be needed exofs is dependent on ore, dependent on raid456
>

> True, but when setting up the environment my goal was to have a
> working environment. If a bug is introduced to this dependence system
> and the module wouldn't be loaded, I would have to reluctantly spend
> time finding the problem, when I can actually live with such a bug if
> the workaround is simply loading the module manually. so as a policy,
> I always explicitly load the modules I need when setting up a pNFS
> environment.


I'm sorry about that, that was my mess. My intention was to make all these
dependencies totally transparent. As an implementation de-jur detail, not
user visible.

The reason I had it in script for a while was because in UML raid456.ko
had a bug, which probing it manually gave a 20% better chance of success
(Tree below has a patch that fixes that, on UML)

Please note that some versions of exofs need it and some don't. I have
removed it from my scripts, now.

<snip>

>> Are you sure you have an exofs FS at /mnt/pnfs ? please do an

>> # df -h /mnt/pnfs I want to see ?

>

> # df -hT /mnt/pnfs/
> Filesystem    Type    Size  Used Avail Use% Mounted on
> /dev/osd0    exofs     55G   12G   44G  21% /mnt/pnfs
>


OK I understand that now, the weird single device case. I don't
promise it will continue to work in Future. As a rule all devices
most have a network-unique OSD_NAME.

 
>>
>> Does it actually work? OK you know maybe it does. I can see this now.
>> If you have a single device it might work, I didn't realize this. I thought
>> the mkfs.exofs would not let you.
>>
>> For sure if you have more then one device (pnfs right?) then it will not
>> let you, because the devices have strict order in the device table. Device
>> names are not reliable and may change from login to login. You need some
>> kind of device-id
> Indeed it is a pNFS setup. And indeed I've had trouble when using more
> than one OSD.


I use a better script system for the cluster case, now, that I never pushed
that makes all this easier.

For one not setting osdname= at --format would explain the above.

> 
> By the way, several weeks I have tried setting up a RAID 5 environment
> with 8 OSDs, 1 mirror and RAID nesting. I then tried cloning and
> compiling the kernel tree over this pNFS-OSD-RAID. The result was that
> otgtd died, and I don't know why. It didn't dump core anywhere I could
> find and the only "log" it has - stdout - didn't give any useful info.
> I was going to inquire about this in a couple of weeks when I need to
> get this environment working, but since this issue came up, maybe we
> can somehow resolve it sooner.


8 OSDs with a mirror ? what was the mkfs.exofs command line you used?

And did you use one otgtd with 8 targets, or 8 targets (8 IP addresses)
with one target each, or a combination?

What is the otgtd platform? what file system? what HW and HD environment?

And yes otgtd has some instabilities.

There are two I can think off:
* Over xfs the --format command crashes the otgtd (aborted exit no
  crash dump) Debugging welcome.

* When lots of pnfs clients do heavy writing to the same otgtd, it
  times-out and disconnects.
  At Panasas we have a watch-dog that reloads it in a loop.
  I have only seen this on FreeBSD, in Linux it never happened
  to me.

Please give me more details on what you did before it exited
like that.


In anyway I pushed a tree I tested with at:
	git://git.open-osd.org/linux-open-osd.git

checkout the *merge_and_compile-3.3* branch. But in principal they are the
same:
	fs/exofs 		- Added autologin support
	fs/nfs/objlayout 	- Added autologin support
	fs/nfsd			- Same
	fs/nfs			- Few fixes that are in benny's tree are not in linux-open-osd

So it should all be the same. For a proper cluster setup you will probably
need my do-ect scripts which take a cluster descriptor file and does
generic loops on everything.

Thanks
Boaz
