From: Eric Whiting <ewhiting@amis.com>
Subject: Re: NFS read ok, write ok, simultaneous R+W=TERRIBLE
Date: Wed, 04 Dec 2002 22:01:04 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3DEEDD90.915BAFF7@amis.com>
References: <CFEAJJEGMGECBCJFLGDBMEHJCJAA.hammer@clarkisland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dermis.amis.com ([207.141.5.253])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Jo8M-00018F-00
	for <nfs@lists.sourceforge.net>; Wed, 04 Dec 2002 21:01:10 -0800
To: Jake Hammer <hammer@clarkisland.com>
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

Jake,

Your results are similar to what I see -- I don't really have a
solution, but here are some things to consider:

1. Make sure your network is clean and doing duplex right. (test using
two ftp sessions moving those 10 gig files -- one reading while one
writes) Ftp will let you know if the TCP part of your network is healthy
under full duplex loads.

2. Try TCP mounts

3. Try NFS V3

4. Make sure your IDE RAID system on the server is healthy. Can it
handle concurrent read/write processes on the local box -- with NFS out
of the picture?

What is the filesystem you have on the RAID5 setup?
reiserfs/ext3/xfs/jfs?
What sort of IDE HW raid supports 14 disks? Or are you using SW raid?

I would like to see a solution to this sort of problem as well.

eric




Jake Hammer wrote:
> 
> Hi All,
> 
> I'm working with a 2.4.19 + all Neil Brown 2.4.19 patches on a P4 Xeon
> system, 2048MB ram, uniprocessor kernel. Distro is Debian Woody Stable. Disk
> subsystem is ATA RAID 5, 14 spindles. On writes from 15 100base-T clients
> via a Foundry switch, I am able to see 45MB/sec writes and 60MB/sec reads.
> Clients are DD'ing 10GB files to and from the box simultaneously. Mount =
> mount -o proto=udp,vers=2,wsize=32768,rsize=32768 bigbox:/space
> 
> The problem is on read + write. As soon as the clients switch from read only
> or write only and do BOTH read and write, the CPU pegs and performance drops
> to 3MB/sec (three MB/s)! TOP shows that 4 of the NFSd's are consuming all of
> the CPU. It's like they are contending for some kind of resource like a lock
> or something.
> 
> Any help would be sincerely appreciated. This is very strange behavior. It
> also happens with 2.4.18 + all Neil Brown patches for 2.4.18.
> 
> Thanks,
> 
> Jake Hammer
> 
> -------------------------------------------------------
> This SF.net email is sponsored by: Microsoft Visual Studio.NET
> comprehensive development tool, built to increase your
> productivity. Try a free online hosted session at:
> http://ads.sourceforge.net/cgi-bin/redirect.pl?micr0003en
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This SF.net email is sponsored by: Microsoft Visual Studio.NET 
comprehensive development tool, built to increase your 
productivity. Try a free online hosted session at:
http://ads.sourceforge.net/cgi-bin/redirect.pl?micr0003en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
