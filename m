From: Andrew Theurer <habanero@us.ibm.com>
Subject: Re: huge number of intr/s on large nfs server
Date: Tue, 15 Oct 2002 16:22:07 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200210151622.07097.habanero@us.ibm.com>
References: <CFEAJJEGMGECBCJFLGDBAEGICFAA.enorwood@effrem.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: "Daniel Phillips" <phillips@arcor.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mg01.austin.ibm.com ([192.35.232.18])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 181ZKY-0008W6-00
	for <nfs@lists.sourceforge.net>; Tue, 15 Oct 2002 14:34:22 -0700
To: "Eff Norwood" <enorwood@effrem.com>, <nfs@lists.sourceforge.net>
In-Reply-To: <CFEAJJEGMGECBCJFLGDBAEGICFAA.enorwood@effrem.com>
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

On Monday 14 October 2002 3:21 pm, Eff Norwood wrote:
> Hi All,
>
> I have a 2.4.18 kernel running on a dual 2.4Ghz Xeon platform using
> software RAID 5 via IBM's EVMS and EXT3. The system is being used as an=
 NFS
> server and although local disk performance is excellent, NFS performanc=
e
> (over UDP and TCP, vers 2 and 3 with multiple different client mount bl=
ock
> sizes) is poor to bad. Looking at mpstat while the system is under load
> shows the %system to be quite high (94-96%) but most interestingly show=
s
> the number of intr/s (context switches) to be 17-18K plus!

Are you sure you want to use raid5?  I thought there was a lot of overhea=
d vs=20
mirroring.  Look for evms_raid5d or something similar in top when you do =
a dd=20
test.  Do you have enough disks to spare to do mirroring? =20

What mode did you use for ext3?  try data=3Dwriteback

> Since I was not sure what was causing all of these context switches, I
> installed SGI kernprof and ran it during a 15 minute run. I used this
> command to start kernprof: 'kernprof -r -d time -f 1000 -t pc -b -c all=
'
> and this one to stop it: 'kernprof -e -i | sort -nr +2 | less >
> big_csswitch.txt'
>
> The output of this collection is located here (18Kb):
>
> http://www.effrem.com/linux/kernel/dev/big_csswitch.txt
>
> Most interesting to me is why in the top three results:
>
> default_idle [c010542c]: 861190
> _text_lock_inode [c015d031]: 141795
> UNKNOWN_KERNEL [c01227f0]: 101532
>
> that default_idle would be the highest value when the CPUs showed 94-96=
%
> busy. Also interesting is what UNKNOWN_KERNEL is. ???

This can be any module, binary only or not, for kernprof.  It is most lik=
ely=20
your module for the GigE card. Can you check, and if possible, build it i=
nto=20
the kernel?  Actually, can you build everything in the kernel, so kernpro=
f=20
may see all functions?=20

Also, make sure you reset the kernel profile after starting the test, and=
 stop=20
the profile before the test ends.  Otherwise you are getting idle time=20
before/after the test.=20

> The server described above has 14 internal IDE disks configured as soft=
ware
> Raid 5 and connected to the network with one Syskonnect copper gigabit
> card. I used 30 100 base-T connected clients all of which performed
> sequential writes to one large 1.3TB volume on the file server. They we=
re
> mounted NFSv2, UDP, 8K r+w size for this run. I was able to achieve onl=
y
> 35MB/sec of sustained NFS write throughput. Local disk performance (e.g=
=2E dd
> file) for sustained writes is *much* higher. I am using knfsd with the
> latest 2.4.18 Neil Brown fixes from his site. Distribution is Debian 3.=
0
> Woody Stable.

Sorry but I forgot, maybe someone can tell me, are the nfs writes async o=
r=20
not? =20

There is a udp scaling problem, but it does not sound like you have hit t=
hat=20
(yet) if you are 95% CPU. =20

Are you running hyperthreading?  This is a little off topic, but when the=
=20
first problem is fixed, you might want to try hyperthreading.   I saw a 2=
5%=20
improvement in netbench (samba) on a 2 way P4 Xeon. =20

Also, your local dd test simulated the clients, right?  30 dd's?  What=20
throughput did you get? =20

-Andrew


-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?
http://www.viaverio.com/consolidator/osdn.cfm
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
