From: Kim Holviala <kim@holviala.com>
Subject: Spontaneous server reboot with 2.6.10 and nfsd
Date: Fri, 11 Feb 2005 14:56:14 +0200
Message-ID: <420CAB6E.4010003@holviala.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CzaLO-0007uv-1w
	for nfs@lists.sourceforge.net; Fri, 11 Feb 2005 04:56:22 -0800
Received: from ip213-185-37-13.laajakaista.mtv3.fi ([213.185.37.13] helo=three.holviala.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CzaLL-0000dX-HE
	for nfs@lists.sourceforge.net; Fri, 11 Feb 2005 04:56:21 -0800
Received: from dell.work.holviala.com (dell.work.holviala.com [10.10.1.1])
	by three.holviala.com (Postfix) with ESMTP id 793909148
	for <nfs@lists.sourceforge.net>; Fri, 11 Feb 2005 14:56:17 +0200 (EET)
Received: from [10.10.1.1] (dell.work.holviala.com [10.10.1.1])
	by dell.work.holviala.com (Postfix) with ESMTP id 1521DB6EF
	for <nfs@lists.sourceforge.net>; Fri, 11 Feb 2005 14:56:15 +0200 (EET)
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

I already posted this to LKML, but I don't think anyone was interested 
there... Here's the original posting:

===============
I hit an obscure bug last night when trying to copy files from an nfs
client to my nfs server. The server is a P3/800 with three IDE disks in
software RAID5 running vanilla 2.6.10 and Debian Sarge. The network is
local 100Mbit/s switched ethernet. The server exports a 220 gig
partition which contains a lot of data.

Oh, kernel configs and stuff from the server can be found from:
http://www.holviala.com/~kimmy/crash/

Anyway, I mount the export to a Linux client (tried with a few with
different 2.6 kernels and distros) and then start copying files from
clients CDROM to the server through NFS. After copying a few small
files, the first big one reboots the server. There are no log entries,
and the server has no local console so I don't know what happens. This
is reproduceable 100% of the time.
To narrow down the problem, I've tried the following:

- copied files from a different client running Gentoo: reboot
- exported a non-raided partition (hdc9) and tried that: reboot
- switched 2.6.10 to 2.6.11-rc3: reboot, but it took longer

I hope it's just something that I've done, but this server has been in
use for a long time now without any problems, and I haven't touched it
for a while.

So, if anyone knows what's wrong, or can tell me a way to debug the
situation more I'd be grateful. The server is in a place where it's
nearly impossible to have a local console - I could probably use a
serial one if necessary for debugging.
===============

So, that was my original posting. Since then I've tried localhost 
mounts, tcp, udp, different r/wsizes etc etc. I can still reliably 
reboot teh server remotely just by copying something to the NFS mount :-/.

Now, there are two things that I've tested that worked better than 
others: First I switched to async exports, mounted localhost:/export/tmp 
with udp and copied stuff there. The copying hang 
(http://www.holviala.com/~kimmy/crash/nfsd.log) but the server didn't 
crash. Woo! Tried that remotely and it once again rebooted the server...

And then I made one test with tcp,rsize=1024,wsize=1024 again with 
localhost:/export/tmp, and that worked ok. I haven't had the time to 
test that remotely, yet.

So, I can only assume that there's something wrong with using r/wsize 
which is bigger than MTU. However, I run a lot of stuff through that 
same network and I never see any TCP retransmissions or any other 
problems. Besides, I'm getting the same reboot even with localhost NFS 
mounts.

I have managed to capture some logs with nfsd logging on, those can be 
found from the above link.

I'd be grateful for any pointers, debugging flags, anything. I've 
crashed my server now maybe three dozen times trying to narrow the 
problem down....



Kim




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
