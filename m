Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from outbound-smtp02.blacknight.com ([81.17.249.8]:33100 "EHLO
	outbound-smtp02.blacknight.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932115AbbETSbU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 May 2015 14:31:20 -0400
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id CE11298DBF
	for <linux-nfs@vger.kernel.org>; Wed, 20 May 2015 18:31:12 +0000 (UTC)
Message-ID: <555CD2F0.6080408@mpstor.com>
Date: Wed, 20 May 2015 19:31:12 +0100
From: Benjamin ESTRABAUD <be@mpstor.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bc@mpstor.com" <bc@mpstor.com>, Christoph Hellwig <hch@infradead.org>
Subject: Re: Issue running buffered writes to a pNFS (NFS 4.1 backed by SAN)
 filesystem.
References: <41EB9782-8445-4FBB-A825-A484EFF7169C@mpstor.com> <20150515192037.GB29627@fieldses.org> <555CB5EE.2@mpstor.com>
In-Reply-To: <555CB5EE.2@mpstor.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 20/05/15 17:27, Benjamin ESTRABAUD wrote:
> On 15/05/15 20:20, J. Bruce Fields wrote:
>> On Fri, May 15, 2015 at 10:44:13AM -0700, Benjamin ESTRABAUD wrote:
>>> I've been using pNFS for a while since recently, and I am very pleased
>>> with its overall stability and performance.
>>>
>>> A pNFS MDS server was setup with SAN storage in the backend (a RAID0
>>> built ontop of multiple LUNs). Clients were given access to the same
>>> RAID0 using the same LUNs on the same SAN.
>>>
>>> However, I've been noticing a small issue with it that prevents me
>>> from using pNFS to its full potential: If I run non-direct IOs (for
>>> instance "dd" without the "oflag=direct" option), IOs run excessively
>>> slowly (3-4MB/sec) and the dd process hangs until forcefully
>>> terminated.
>>
Here is some additional information:

It turns out that everything works as expected until I write a specific 
"sweet spot" file size or IOs. I wrote a small bash script that writes 
files one by one starting by a 1GiB file up to a 1TiB one, incrementing 
the file size by 1GiB after each iteration:

for i in {1..1000}; do echo $i; dd if=/dev/zero 
of=/mnt/pnfs1/testfile."$i"G bs=1M count="$(($i * 1024))"; done

Note that in the above test we are not running "direct IOs", but use 
"dd"'s default mode, buffered.

The test runs without a hitch for a good while (yielding between 
900MiB/sec and 1.3GiB/sec), I can see the buffering happening since 
after a test starts, no IOs are detected on the iSCSI SAN LUN for a 
short period on time and then a burst of IOs is detected (about 
2-3GiB/sec, which the backend storage can actually handle).

"nfsstat" also confirms that no NFS writes are happening, "layoutcommit" 
operations are recorded when a new file is written instead.

After 25 iterations (after creating a 25GiB file, for a cumulative total 
of 325GiB if including the testfile.1G -> testfile.24G) the issue 
occured again. The IO rate to the SAN LUN dropped severely to a real 
3MiB/sec (measured at the SAN LUN block device level).

Also I've noticed that a kernel process is taking up 100% of one core at 
least:

516 root      20   0       0      0      0 R 100.0  0.0  11:09.72 
kworker/u49:4

I then canceled the test and removed the partial 26G file that seemed to 
have caused the issue, and re-generated the same 26G file using dd. 
After a few seconds, a kernel workqueue (this time kworker/u50:3) comes 
up at 100% CPU (from little before, couldn't really see it in top).
I then tried to delete the 25G file and write that 25G file, and the 
same workqueue issue occured (100% CPU).
I then deleted a much smaller file (5GiB) and re-wrote it without any 
issues.
I then tried a 20G file also without problem.
I overwrite the 24G file also without problem.
Went back to a 25G file and the issue happens again.

Somehow the issue happens only when reaching a sweet spot triggered by 
writing a file around 25G or larger in size.

Both SAN iSCSI targets (LIO based) are pretty idle (apart from the odd 
iscsi_tx that happens from time to time) and don't report anything 
suspicious on dmesg.

Would the 25GiB figure ring any bells to you? Would there be a way for 
me to identify this workqueue (figure out if it is pNFS related)?

Thanks a lot in advance for your help!

Regards,
Ben.

> Sorry for the late reply, I was unavailable for the past few days. I had
> time to look at the problem further.
>
>> And that's reproduceable every time?
>>
> It is, and here is what is happening more in details:
>
> on the client, "/mnt/pnfs1" is the "pNFS" mount point. We use NFS v 4.1.
>
> * Running dd with bs=512 and no "direct" set on the client:
>
> dd if=/dev/zero of=/mnt/pnfs1/testfile bs=512 count=100000000
>
> => Here we get variable performance, dd's average is 100MB/sec, and we
> can see all the IOs going to the SAN block device. nfsstat confirms that
> no IOs are going through the NFS server (no "writes" are recorded, only
> "layoutcommit". Performance is maybe low but at this block size we don't
> really care.
>
> * Running dd with bs=512 and "direct" setL
>
> dd if=/dev/zero of=/mnt/pnfs1/testfile bs=512 count=100000000 oflag=direct
>
> => Here, funnily enough, all the IOs are sent over NFS. The "nfsstat"
> command shows writes increasing, the SAN block device activity on the
> client is idle. The performance is about 13MB/sec, but again expected
> with such a small IO size. The only unexpected is that small 512bytes
> IOs are not going through the iSCSI SAN.
>
> * Running dd with bs=1M and no "direct" set on the client:
>
> dd if=/dev/zero of=/mnt/pnfs1/testfile bs=1M count=100000000
>
> => Here the IOs "work" and go through the SAN (no "write" counter
> increasing in "nfsstat" and I can see disk statistics on the block
> device on the client increasing). However the speed at which the IOs go
> through is really slow (the actual speed recorded on the SAN device
> fluctuates a lot, from 3MB/sec to a lot more). Overall dd is not really
> happy and "Ctrl-C"ing it takes a long time, and in the last try actually
> caused a kernel panic (see http://imgur.com/YpXjvQ3 sorry about the
> picture format, did not have the dmesg output capturing and had access
> to the VGA only).
> When "dd" finally comes around and terminates, the average speed is
> 200MB/sec.
> Again the SAN block device shows IOs being submitted and "nfsstat" shows
> no "writes" but a few "layoutcommits", showing that the writes are not
> going through the "regular" NFS server.
>
>
> * Running dd with bs=1M and no "direct" set on the client:
>
> dd if=/dev/zero of=/mnt/pnfs1/testfile bs=1M count=100000000 oflag=direct
>
> => Here the IOs work much faster (almost twice as fast as with "direct"
> set, or 350+MB/sec) and dd is much more responsive (can "Ctrl-C" it
> almost instantly). Again the SAN block device shows IOs being submitted
> and "nfsstat" shows no "writes" but a few "layoutcommits", showing that
> the writes are not going through the "regular" NFS server.
>
> This shows that somehow running with "oflag=direct" causes unstability
> and lower performance, at least on this version.
>
> Both clients are running Linux 4.1.0-rc2 on CentOS 7.0 and the server is
> running Linux 4.1.0-rc2 on CentOS 7.1.
>
>> Can you get network captures and figure out (for example), whether the
>> slow writes are going over iSCSI or NFS, and if they're returning errors
>> in either case?
>>
> I'm going to do that now (try and locate errors). However "nfsstat" does
> indicate that slower writes are going through iSCSI.
>
>>> The same behaviour can be observed laying out an IO file
>>> with FIO for instance, or using some applications which do not use the
>>> ODIRECT flag. When using direct IO I can observe lots of iSCSI
>>> traffic, at extremely good performance (same performance as the SAN
>>> gets on "raw" block devices).
>>>
>>> All the systems are running CentOS 7.0 with a custom kernel 4.1-rc2
>>> (pNFS enabled) apart from the storage nodes which are running a custom
>>> minimal Linux distro with Kernel 3.18.
>>>
>>> The SAN is all 40G Mellanox Ethernet, and we are not using the OFED
>>> driver anywhere (Everything is only "standard" upstream Linux).
>>
>> What's the non-SAN network (that the NFS traffic goes over)?
>>
> The NFS traffic also goes through the same SAN actually, both the iSCSI
> LUNs and the NFS server are accessible over the same 40G/sec Ethernet
> fabric.
>
> Regards,
> Ben.
>
>> --b.
>>
>>>
>>> Would anybody have any ideas where this issue could be coming from?
>>>
>>> Regards, Ben - MPSTOR.-- To unsubscribe from this list: send the line
>>> "unsubscribe linux-nfs" in the body of a message to
>>> majordomo@vger.kernel.org More majordomo info at
>>> http://vger.kernel.org/majordomo-info.html
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

