From: "Jake Hammer" <hammer@clarkisland.com>
Subject: NFS read ok, write ok, simultaneous R+W=TERRIBLE
Date: Wed, 4 Dec 2002 18:44:24 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <CFEAJJEGMGECBCJFLGDBMEHJCJAA.hammer@clarkisland.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cynaptic.com ([128.121.116.181])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Jm0B-0005Qy-00
	for <nfs@lists.sourceforge.net>; Wed, 04 Dec 2002 18:44:35 -0800
Received: from phasmida (dsl081-053-223.sfo1.dsl.speakeasy.net [64.81.53.223]) by cynaptic.com (8.11.6) id gB52iUd13269 for <nfs@lists.sourceforge.net>; Wed, 4 Dec 2002 19:44:30 -0700 (MST)
To: "NFS" <nfs@lists.sourceforge.net>
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

Hi All,

I'm working with a 2.4.19 + all Neil Brown 2.4.19 patches on a P4 Xeon
system, 2048MB ram, uniprocessor kernel. Distro is Debian Woody Stable. Disk
subsystem is ATA RAID 5, 14 spindles. On writes from 15 100base-T clients
via a Foundry switch, I am able to see 45MB/sec writes and 60MB/sec reads.
Clients are DD'ing 10GB files to and from the box simultaneously. Mount =
mount -o proto=udp,vers=2,wsize=32768,rsize=32768 bigbox:/space

The problem is on read + write. As soon as the clients switch from read only
or write only and do BOTH read and write, the CPU pegs and performance drops
to 3MB/sec (three MB/s)! TOP shows that 4 of the NFSd's are consuming all of
the CPU. It's like they are contending for some kind of resource like a lock
or something.

Any help would be sincerely appreciated. This is very strange behavior. It
also happens with 2.4.18 + all Neil Brown patches for 2.4.18.

Thanks,

Jake Hammer




-------------------------------------------------------
This SF.net email is sponsored by: Microsoft Visual Studio.NET 
comprehensive development tool, built to increase your 
productivity. Try a free online hosted session at:
http://ads.sourceforge.net/cgi-bin/redirect.pl?micr0003en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
