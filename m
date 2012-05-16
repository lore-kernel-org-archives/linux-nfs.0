Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:59151 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753152Ab2EPIHM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 May 2012 04:07:12 -0400
Received: by pbbrp8 with SMTP id rp8so767694pbb.19
        for <linux-nfs@vger.kernel.org>; Wed, 16 May 2012 01:07:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FB29074.6010606@panasas.com>
References: <20120515090332.182970@gmx.net>
	<4FB22658.9010909@panasas.com>
	<20120515121931.192500@gmx.net>
	<CABpMAy+bV7-UZU0gGOFWk+ZfHLGi+D=ntNLjRHFYZzTtwXG_RA@mail.gmail.com>
	<4FB25D2F.1070403@panasas.com>
	<CABpMAyJ9F5c52ntMCL1+gwDCcbMYMEkxVEHW7bfpjm6H5boSCg@mail.gmail.com>
	<4FB270E9.5000904@panasas.com>
	<CABpMAy+OWcp7VAOGK4nYWfcY4iZ9a1WQHPUbh5pxotYL9yy+KA@mail.gmail.com>
	<4FB29074.6010606@panasas.com>
Date: Wed, 16 May 2012 11:07:10 +0300
Message-ID: <CABpMAyL=VKeZHT_8RV5mOFRN7kMWM47bgvwER+Q8MY0gMvroFg@mail.gmail.com>
Subject: Re: Questions about Exofs
From: Idan Kedar <idank@tonian.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Johannes Schild <JSchild@gmx.de>, osd-dev@open-osd.org,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 15, 2012 at 8:20 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 05/15/2012 07:21 PM, Idan Kedar wrote:
> <snip>
>
>>> 8 OSDs with a mirror ? what was the mkfs.exofs command line you used?
>> Something along the lines of
>> # LD_LIBRARY_PATH=lib ./usr/mkfs.exofs --pid=0x10000 --format
>> --mirrors=1 --group_width=2 --group_depth=2 --dev=/dev/osd0
>> --osdname=$(uuid) --dev=/dev/osd1 --osdname=$(uuid) --dev=/dev/osd2
>> --osdname=$(uuid) ...
>>
>> I don't remember exactly at the moment, but I will bump this thread
>> when I'll start using RAID again.
>
>
> Certainly missing the --format thing.  --osdname= without an --format
> is ignored.
>
> Again if you never set an OSD_NAME on the devices in the past this will
> not work.
>
> But perhaps you did --format and forgot
>
>>>
>>> And did you use one otgtd with 8 targets, or 8 targets (8 IP addresses)
>>> with one target each, or a combination?
>> one target with 8 LUNs
>>>
>>> What is the otgtd platform? what file system? what HW and HD environment?
>> osc-osd over ext4, 64 bit VirtualBox VM over x86_64.
>
>
> OK that's a fishy setup.
>
> The otgtd is sensitive to timeouts which I never investigated properly.
> It looks like the OSD_VM-to-host, probably a single link, is very slow
> and imagine 8 initiators actually banging on the same single slow link.
> One of the commands times out, probably just a guess
>
> The best for a VM setup, that I have is:
>
> VM1     - exofs+MDS
> VM2     - pnfs client.
>   (On my dev machine I have VM2+VM1 combined, and mount on localhost)
>
> HOST    - Run otgtd naively on host for best results.
>          Best is to spread all targets on as many physical HD devices.
>          Note that multiple targets from the same OSD-host only makes
>          "preformance" sense if they each serve a different spindle.
>          Unless in a simulated test environment as yourself
>
> Which reminds me that upstream tgtd as a few fixes in this area I should
> integrate.
>
>>>
>>> And yes otgtd has some instabilities.
>>>
>>> There are two I can think off:
>>> * Over xfs the --format command crashes the otgtd (aborted exit no
>>>  crash dump) Debugging welcome.
>>>
>>> * When lots of pnfs clients do heavy writing to the same otgtd, it
>>>  times-out and disconnects.
>> it was a single client performing git-clone of the kernel tree.
>>>  At Panasas we have a watch-dog that reloads it in a loop.
>>>  I have only seen this on FreeBSD, in Linux it never happened
>>>  to me.
>>>
>>> Please give me more details on what you did before it exited
>>> like that.
>> Nothing special, just git-clone. at some point it hanged (at a
>> different place every time), and when investigated a bit I saw that
>> otgtd is dead.
>>>
>>>
>>> In anyway I pushed a tree I tested with at:
>>>        git://git.open-osd.org/linux-open-osd.git
>>>
>>> checkout the *merge_and_compile-3.3* branch. But in principal they are the
>>> same:
>>>        fs/exofs                - Added autologin support
>>>        fs/nfs/objlayout        - Added autologin support
>>>        fs/nfsd                 - Same
>>>        fs/nfs                  - Few fixes that are in benny's tree are not in linux-open-osd
>> Thanks, I will try it soon.
>>>
>>> So it should all be the same. For a proper cluster setup you will probably
>>> need my do-ect scripts which take a cluster descriptor file and does
>>> generic loops on everything.
>> Please note that I didn't try a cluster setup, just a single DS with 8
>> LUNs, single MDS, and single pNFS client, all 3 different VMs on the
>> same host.
>
>
> Just semantics so we speak the same language. Yes you do have a cluster.
>
> In pnfs-objects world there are no such thing as DSs there is MDS and
> there are OSDs. (objects). The OSDs are the equivalent of DSs in "files"
> and LUNs in "blocks"
>
> A none cluster is when you have a single OSD. (No striping, no multiple
> devices, what I call the trivial layout)
>
>>>
>>> Thanks
>>> Boaz
>>
>
>
> If you want there is a new tree at:
>        git://git.open-osd.org/tests.git
>
> There is one script that does everything. ./do-ect (exofs cluster test)
>
> You edit the ect.conf file (or run ./do-ect -f alternate.conf file)
>
> In turn inside ect.conf you edit your topology and setup. It also points
> to a device-table file (osds_list=XXX.olst) see lots of *.olst example
> files.
>
> list of operations.
> * Read the scripts and study what they do. They are just a convenience
>  not a black-box application.
> * Edit a new XXX.olst file
> * Edit ect.conf with your setup.
> [On MDS]
> * ./do-ect login2       - login to all devices specified by osds_list=
> * ./do-ect format2      - Set up an FS as specified by ect.conf
> * ./do-ect mount2       - mount the exofs file system
> * ./do-ect seturi       - If you have the autologin version and want an autologin support.
>
> [On pnfs client]
> * ./do-ect login2       - Only if autologin is not enabled. You will need the
>                          /sbin/osd_login script, which is part of the newest nfs-utils
>                          (Tell me if you can't find it)
>
> * ./do-ect pnfs_start  - mount the pnfs server on pnfs_dir as specified in ect.conf
>
> And there are other facilities as well. In principal the commands that end with "2"
> are those that preform an action on the XXX.olst file and receive an optional parameter
> as the OSDs list. For example:
>
> ./do-ect login2
>        - login to default list specified in ect.conf
>
> ./do-ect -f clusterXYZ.conf format2 device_table7.olst
>        - Format according to setup in clusterXYZ.conf file but override the OSDs list
>          instead use device_table7.olst.
>
> Again please read the scripts before using. the .conf and .olst files are yours, I
> just have them in git as an history of the tests I conducted.
>
> But if you have any changes to the do-ect and fn-osd.sh please send me a patch.
>
> There are other interesting scripts in there for example the target/ dir as a
> way of controlling lots of OSD hosts in a single command using the closh script (CLuster Output SHell)
> which also operate on the .olst and .clst files. Have fun
>
> Cheers
> Boaz
Thank you for the instructions, I will get to that soon.

Cheers,
idank
