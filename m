Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:43626 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754138Ab0DURKj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Apr 2010 13:10:39 -0400
Subject: Re: strange performance issues with OS X 10.6 client
Content-Type: text/plain; charset=iso-8859-1
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20100420224408.GB161@gmx.de>
Date: Wed, 21 Apr 2010 13:09:45 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <E44BE585-6051-470A-900A-7B4520782A0D@oracle.com>
References: <20100415214900.GA4143@web.de> <20100419122120.GA3716@gmx.de> <4BCC8C06.1080106@oracle.com> <20100420212116.GA161@gmx.de> <4BCE1F6A.6000902@oracle.com> <20100420224408.GB161@gmx.de>
To: =?iso-8859-1?Q?Stefan_Kr=FCger?= <stadtkind2@gmx.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Apr 20, 2010, at 6:44 PM, Stefan Krüger wrote:
> On Tue, 20 Apr 2010, Chuck Lever wrote:
> 
>> On 04/20/2010 05:21 PM, Stefan Krüger wrote:
>>> On Mon, 19 Apr 2010, Chuck Lever wrote:
>>> 
>>>> On 04/19/2010 08:21 AM, Stefan Krüger wrote:
>>>>> On Thu, 15 Apr 2010, Stefan Krüger wrote:
>>>>> 
>>>>>> Hello list,
>>>>>> 
>>>>>> I have some really strange nfs performance issues
>>>>>> 
>>>>>> NFS server is Fedora 12, running
>>>>>> * kernel-2.6.32.11-99.fc12.x86_64 and
>>>>>> * nfs-utils-1.2.1-4.fc12.x86_64
>>>>>> * nfs shared /home is ext4 with default mount options
>>>>>> 
>>>>>> /etc/exports:
>>>>>> /home   192.168.1.0/255.255.255.0(rw,sync)
>>>>>> 
>>>>>> nfs and nfslock are up and running
>>>>>> 
>>>>>> Nothing else touched on the server nfs-wise.
>>>>>> 
>>>>>> NFS client is Mac OS X, version 10.6.3
>>>>>> 
>>>>>> My /home dir is automounted on the Mac with the following mount options:
>>>>>> * nosuid,nodev,resvport,rdirplus,rwsize=1048576
>>>>>> (nfsv3 and tcp are default, I have also tried udp, and with and without
>>>>>> rdirplus, with different read/write sizes (started with 32k, less for udp,
>>>>>> and then cranked it up to 1m to make the beachball appear less often),
>>>>>> but I still have issues no matter which options I chose)
>>>>>> 
>>>>>> Anyway, I'm stuck now, surfing the web with Safari is a very unpleasant
>>>>>> experience on nfs, beachball every now and then together with a huge
>>>>>> amount of network traffic (RX with 20MB/s+ peaks), not unusual to see
>>>>>> several gigabytes received after some minutes browsing, XCode shows a
>>>>>> ''The document "SomeFile.m" could not be saved.''-error after some
>>>>>> edits, Opera hangs for minutes when closing, etc etc.
>>>>>> 
>>>>>> It's horrible :(
>>>>>> 
>>>>>> Another example, extracting
>>>>>> http://www.bignerdranch.com/solutions/Cocoa-3rd.tgz took over 3min!
>>>>>> 
>>>>>> $ time tar xzf Cocoa-3rd.tgz
>>>>>> 0.169u 3.198s 5:51.10 0.9%	0+0k 1+6972io 0pf+0w
>>>>>> $ time rm -rf Solutions-Cocoa-3rd/
>>>>>> 0.014u 0.477s 0:45.59 1.0%	0+0k 1+1io 0pf+0w
>>>>>> 
>>>>>> So any help or hints really appreciated
>>>>> 
>>>>> So, no answers yet, but I did some more tests, i.e. I tried extracting
>>>>> the Cocoa-3rd.tgz (2.2MB, 12MB untar'ed) on FreeBSD 8.0-REL (running
>>>>> inside VMWare though), and still it was much faster (5:51.10 vs
>>>>> 0:09.35) than extracting on bare metal fedora12:
>>>>> 
>>>>> $ time tar xfz Cocoa-3rd.tgz
>>>>> 0.104u 1.474s 0:09.35 16.7%	0+0k 0+4896io 0pf+0w
>>>>> $ time rm -rf Solutions-Cocoa-3rd
>>>>> 0.006u 0.160s 0:01.24 12.9%	0+0k 0+0io 0pf+0w
>>>>> 
>>>>> I captured the nfs traffic with tcpdump (tcpdump -i eth1 -s 0 -w
>>>>> nfs.out host nfssrv and port 2049) on both freebsd8 (interface for
>>>>> freebsd is a bit different ofc) and fedora12 while running
>>>>> 
>>>>> tar xfz Cocoa-3rd.tgz Solutions-Cocoa-3rd/02_GetStarted
>>>>> 
>>>>> (which extracts just a couple of files) , you can find them here:
>>>>> 
>>>>> Fedora 12 tcpdump ->   http://www.dpaste.org/5cvp/
>>>>> FreeBSD 8 tcpdump ->   http://www.dpaste.org/uCGX/
>>>> 
>>>> The number of packets is around 1800 for the FreeBSD server and around
>>>> 1940 for the Linux server.  The RPC counts you posted in a later email
>>>> show that Linux does more LOOKUP and ACCESS requests.  But generally, it
>>>> looks like your client is doing roughly the same amount of work in both
>>>> cases.
>>>> 
>>>> But what catches my eye in the F12 tcpdump is that there are pauses
>>>> where the server reply is delayed by a few milliseconds after a SETATTR
>>>> or COMMIT.  This looks normal, since disk writes can take a few
>>>> milliseconds.
>>>> 
>>>> FreeBSD doesn't appear to have these pauses, so I suspect FreeBSD is
>>>> doing something illegal.  No NFS server can turn a SETATTR around in
>>>> just a few microseconds and claim that it is on permanent storage,
>>>> unless it has some kind of NVRAM.
>>> 
>>> First of all, thanks for your answer Chuck :)
>>> 
>>> there are some additional packets because the .tgz was on the same
>>> (nfs-mounted) dir and on a local dir during the freebsd test (so some
>>> extra reads etc. sneaked in the linux tcpdump/nfsstat -s)
>>> 
>>> Just for the record, Solaris 10u8 (UFS) extraction time is almost the
>>> same as FreeBSDs:
>>> 
>>> $ time tar xfz Cocoa-3rd.tgz
>>> 0.111u 1.621s 0:09.03 19.1%	0+0k 8+4966io 0pf+0w
>>> 
>>> So I guess they're both cheating ;-)
>> 
>> Is Solaris running in a guest too?
> 
> Yes, this test was also done using VMWare
> I also installed Fedora12/ext4 in VMWare and got ->
> 
> $ time tar xfz Cocoa-3rd.tgz
> 0.135u 2.151s 0:36.50 6.2%      0+0k 3+4770io 0pf+0w
> 
> Well, 36 seconds, still 3x longer than Solaris/FreeBSD but way better than
> 5min on bare metal
> 
> Anyway, to get some real data I splitted my raid1 mirror on the nfs server
> yesterday and installed FreeBSD 8 on the (now) free disk
> I don't know why but NFS performance is stunning, extracting the tgz only
> takes seconds, Opera doesn't hang for minutes when closing, no strange rx
> spikes and a lot less total bytes received on the same hardware with the same
> files (no special tweaks done, only change on freebsd was to start 8 nfsd
> servers [default is 4], fs is UFS with softdeps)
> 
> I can't explain it...
> 
>> What physical file system are you using on the Linux NFS server?
> 
> See my first mail ("nfs shared /home is ext4 with default mount options"),
> so it's ext4 (I did some tests with xfs/ext3 using fedora12/VMWare, too, same
> bad results though)


So, VMware is probably not waiting for disk writes to complete, since NFS servers in VMware guests run faster than native.  Note to self: never put mission critical data on NFS servers running as VMware guests.

Still, the Linux NFS server has some kind of problem here when comparing apples to apples.  Does increasing the number of nfsd threads on the server help?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



