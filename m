From: Chris Dos <chris@chrisdos.com>
Subject: Re: Millions of files and directory caching.
Date: Tue, 22 Oct 2002 15:00:37 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3DB5BC75.1000509@chrisdos.com>
References: <6440EA1A6AA1D5118C6900902745938E07D54FA9@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 12-252-254-16.client.attbi.com ([12.252.254.16] helo=windwalker.chrisdos.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18468r-00023v-00
	for <nfs@lists.sourceforge.net>; Tue, 22 Oct 2002 14:00:45 -0700
Received: from localhost (localhost.localdomain [127.0.0.1])
	by windwalker.chrisdos.com (Postfix) with ESMTP id D851919C402
	for <nfs@lists.sourceforge.net>; Tue, 22 Oct 2002 15:00:42 -0600 (MDT)
Received: from chrisdos.com (gurney.hugehosting.com [66.179.37.145])
	by windwalker.chrisdos.com (Postfix) with ESMTP id D9F6E19C0AF
	for <nfs@lists.sourceforge.net>; Tue, 22 Oct 2002 15:00:37 -0600 (MDT)
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

I wasn't able to get the tranfer done last night.  Hopefully it'll 
finish by tonight and I can let everyone know the results tomorrow.

Does anyone know what is the maximum number of NFS threads I can run. 
It seems like 256 wasn't enough for my platform, so I've upped it to 
320.  What is the absolute limit I can go?

	Chris

Lever, Charles wrote:
> hi chris-
> 
> someone recently reported to me that oil companies like RAID 10
> because RAID 5 performance is terrible for NFS servers.  seems
> like you are on the right path.
> 
> 
> 
>>Man, you setup seems extreamly close to mine and it's even 
>>for the same 
>>type of business.  Let me give you a run down on what I have, 
>>and what 
>>I've been doing.
>>
>>We had a EMC Symetrix SAN/NAS that held 5.7 TB worth of disk. 
>> We were 
>>only using about 550 GB of it, so the decision was to move 
>>away from the 
>>   EMC because of ongoing support cost and complexity issues. 
>> The EMC 
>>was working in a NAS configuration serving files via NFS, and it was 
>>also sharing some of it's disk to a Sun 420R which was then serving 
>>files via NFS.
>>
>>The clients are a mix of Solaris 2.6/7.0/8.0 and Redhat 7.2 with the 
>>stock kernel.  There are three RedHat 7.2 servers (two are updated 
>>running the 2.4.18-17 kernel, the other run is running the 
>>2.4.7 kernel) 
>>that serve mail, Two Solaris servers that serve web, and one Oracle 
>>server that did have external disk to the EMC.  The clients are 
>>connected to the switch at 100BT FD.  The clients use the following 
>>mounting options:
>>udp,bg,intr,hard,rsize=8192,wsize=8192
>>
>>The server built to replace the EMC is built as follows:
>>Hardware:	Tyan 2462 motherboard with five 64 bit slots
>>		Dual AMD 2100+ MP Processors
>>		2 GB PC 2100 RAM
>>		Two 3Ware 64 bit 7850 8 port RAID cards
>>		16 Maxtor 160 GB Hard Drives
>>		3 Netgear 64 bit 621 Gigabit cards
>>Software:
>>		Redhat Linux 7.3 (All patches applied)
>>		Custom 2.4.19 Kernel (I also rolled one using the
>>		nfs-all patch and the tcp patch, but Oracle didn't
>>		like starting it's database when mounted to it.
>>		Don't know why)
>>Config and Stats:
>>This server was configured using each 3ware RAID card in a 
>>RAID 5, and 
>>then mirrored via software RAID to the other 3Ware RAID card. 
>> This gave 
>>us 1.2 TB of usable space.  I've moved the data off the EMC to this 
>>server, and I had to move the Oracle servers Oracle database to this 
>>server as well and export via NFS.  (The Oracle (Sun 420R) server can 
>>only hold two drives)  The server is connected to the network via 
>>Gigabit FD.
>>I'm running 256 NFS threads, and even then, that doesn't seem like 
>>enough according to the output of /proc/net/rpc/nfsd.  What's 
>>the limit 
>>on the maximum number of threads I can run?
>>
>>Ouput of /proc/net/rpc/nfsd:
>>rc 21716 821664 85468545
>>fh 233099 88275136 0 233232 6591060
>>io 2359266294 1934417182
>>th 256 19536 1012.250 787.570 875.870 1350.400 840.930 220.190 96.470 
>>50.970 20.000 229.690
>>ra 512 4558260 16517 7803 5421 4228 3293 2686 1808 1279 1270 923900
>>net 86311942 86311942 0 0
>>rpc 86311925 17 16 1 0
>>proc2 18 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
>>proc3 22 100 47898973 4984 2138510 29020056 120 5542814 390404 117607 
>>130 0 9 163535 8 103856 62847 516154 205343 17118 772 60 128525
>>
>>All the exports from the server have these options: 
>>rw,no_root_squash,sync
>>And I'm passing these options to the kernel:
>>/bin/echo 2097152 > /proc/sys/net/core/rmem_default
>>/bin/echo 2097152 > /proc/sys/net/core/rmem_max
>>/bin/echo "65536"  > /proc/sys/fs/file-max
>>
>>And even with all of this, I'm having issues with this box.  
>>The client 
>>NFS mounts are extreamly slow.  So slow, that some services 
>>time out and 
>>the daemon stops all together.  This is a very bad thing.  So I've 
>>pulled my hair out, beat my head against the wall, and contemplated 
>>using a sledge hammer to finish this slow painful death.  I've tried 
>>connecting the server via 100 FD instead of Gig to see if 
>>that would fix 
>>the problem, nada.  So, I got around to thinking, that when I had 
>>configured older 3Ware 6500 RAID cards in a RAID 5 on another server, 
>>performance sucked.  Converting it to RAID 10 solved that issue.  The 
>>RAID 5 performance was supposed to be fixed in the 7500 series,but I 
>>suspected it was not.  So I decided to explore this tangent 
>>and pull a 
>>couple of all nighters to make this happen.  So....
>>
>>I broke the Software RAID, reconfigured one of the 
>>controllers as RAID 
>>10, giving me 640 GB of space.  Started copying as much data 
>>as I could 
>>between 10pm-7am Saturday and Sunday night, and as of this 
>>morning, I've 
>>been able to move 1/4 of the mail (one full mount) to the RAID 10. 
>>Already performance of my NFS has increased.  Customers aren't 
>>complaining now about slow mail (or no mail access at all for that 
>>matter).  After tonight I should have all the mail moved over to the 
>>RAID 10 and I should be able to give you an update tomorrow.  If 
>>everything goes as planned, I'll move the web sites the next day, and 
>>then this weekend, I'll reconfigure the controller that is in 
>>a RAID 5 
>>config, to a RAID 10, and then bring up the software RAID 1 
>>between the 
>>controllers.
>>
>>So, I think your problem is caused by RAID 5 and not NFS, 
>>just like mine 
>>is.  I'll know more tomorrow.
>>
>>If anyone can see anything wrong with my configs,  or other 
>>optimizations I can make, please let me know.  This is a very high 
>>profile production environment.  I need to get this thing running 
>>without a hitch.
>>
>>	Chris Dos
>>
>>Matt Heaton wrote:
>> > I run a hosting service that hosts about 700,000 websites. 
>> We have 2
>> > NFS servers running Redhat 7.2 (2.4.18 custom kernal, no
>> > nfs patches).  The servers are 850 GIGS each (IDE RAID 5). 
>>THe clients
>> > are all 7.2 Redhat with custom 2.4.18 kernels on them.  My 
>>question is
>> > this.  I believe lookups/attribs on the files and directories are
>> > slowing down performance considerably because we literally have 4-5
>> > million files on each nfs server that we export.  One of 
>>the NFS servers
>> > is running EXT3 and the other is XFS.  Both work ok, but 
>>under heavy
>> > loads the clients die because the server can't export stuff fast
>> > enough.  The total bandwidth out of each NFS server is LESS than 10
>> > Mbit.  The trouble is that I am serving a bunch of SMALL 
>>files.  Either
>> > I am running out of seek time on my boxes (IDE Raid 850 GIGS per
>> > server), or it is taking forever to find the files.
>> >
>> > Here are my questions.
>> >
>> > 1) Can I increase the cache on the client side to hold the entire
>> > directory structure of both NFS servers?
>> >
>> > 2) How can I tell if I am just maxing the seek time out on 
>>my NFS server?
>> >
>> > 3) Each NFS server serves about 60-100 files per second.  
>>Is this too
>> > many per second?  Could I possibly be maxing
>> > out seek time on the NFS servers?  My IDE Raid card is the 
>>3ware 750
>> > with 8 individual IDE ports on it.
>> >
>> > 4) Is there anything like cachefs being developed for 
>>linux??  Any other
>> > suggestions for persistent client caching for NFS?
>> > Free or commercial is fine.
>> >
>> > Thanks for your answers to some or all of my questions.
>> >
>> > Matt
>> >
>> >
>>
>>
>>
>>
>>-------------------------------------------------------
>>This sf.net emial is sponsored by: Influence the future of 
>>Java(TM) technology. Join the Java Community Process(SM) (JCP(SM)) 
>>program now. http://ad.doubleclick.net/clk;4699841;7576298;k?
>>http://www.sun.com/javavote
>>_______________________________________________
>>NFS maillist  -  NFS@lists.sourceforge.net
>>https://lists.sourceforge.net/lists/listinfo/nfs
>>
> 
> 



-------------------------------------------------------
This sf.net emial is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ad.doubleclick.net/clk;4699841;7576301;v?http://www.sun.com/javavote
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
