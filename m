From: "Heflin, Roger A." <Roger.A.Heflin@conoco.com>
Subject: RE: huge number of intr/s on large nfs server
Date: Tue, 15 Oct 2002 09:02:05 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5CA6F03EF05E0046AC5594562398B9165E77BB@poexmb3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from usamail1.conoco.com ([12.31.208.226])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 181SGx-0002ku-00
	for <nfs@lists.sourceforge.net>; Tue, 15 Oct 2002 07:02:11 -0700
To: <nfs@lists.sourceforge.net>,
	<enorwood@effrem.com>
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

You say 35MB/second, and 17k context switches, so that is about
2k/context switch.    You get at least 1 context switch per every
few packets sent out, and you get 1 context switch for each disk
io done (I believe), the more data you send out, the more context
switches/interrupts that you will get.   Things that appear to reduce
the numbers are using larger packets (32k seems to reduce the
numbers over 8k nfs-wsize,rsize), making anything else larger
may also reduce the total number.   And software raid should
increase the number a bit as more has to be taken care of by
the main cpu, whereas in hardware raid the parity writes
are invisible to the main cpu.  Also with hardware raid the=20
parity calcs are on the hardware and not on the main cpu,
so this reduces the main cpu usage.   With a hardware raid
setup I get performance numbers similar to what you are seeing,
only I get more like 50% cpu usage on a single slightly slower cpu.
With a SCSI fc 5+1 disk setup with a mylex controller I am getting
about 25MB/second writes.

Just doing local IO will produce lots and lots of interrupts/context
switches.

When you did the local dd you did make sure to break the cache?
Otherwise the results that you get will be rather useless.   I have
been finding that I can usually get about 1/2 of the local capacity
to the network across NFS when I break the cache, if you don't
break the cache you get very very large results.

                                          Roger

> Message: 1
> From: "Eff Norwood" <enorwood@effrem.com>
> To: <nfs@lists.sourceforge.net>
> Cc: "Daniel Phillips" <phillips@arcor.de>
> Date: Mon, 14 Oct 2002 13:21:15 -0700
> Subject: [NFS] huge number of intr/s on large nfs server
>=20
> Hi All,
>=20
> I have a 2.4.18 kernel running on a dual 2.4Ghz Xeon platform using =
software
> RAID 5 via IBM's EVMS and EXT3. The system is being used as an NFS =
server
> and although local disk performance is excellent, NFS performance =
(over UDP
> and TCP, vers 2 and 3 with multiple different client mount block =
sizes) is
> poor to bad. Looking at mpstat while the system is under load shows =
the
> %system to be quite high (94-96%) but most interestingly shows the =
number of
> intr/s (context switches) to be 17-18K plus!
>=20
> Since I was not sure what was causing all of these context switches, I
> installed SGI kernprof and ran it during a 15 minute run. I used this
> command to start kernprof: 'kernprof -r -d time -f 1000 -t pc -b -c =
all' and
> this one to stop it: 'kernprof -e -i | sort -nr +2 | less >
> big_csswitch.txt'
>=20
> The output of this collection is located here (18Kb):
>=20
> http://www.effrem.com/linux/kernel/dev/big_csswitch.txt
>=20
> Most interesting to me is why in the top three results:
>=20
> default_idle [c010542c]: 861190
> _text_lock_inode [c015d031]: 141795
> UNKNOWN_KERNEL [c01227f0]: 101532
>=20
> that default_idle would be the highest value when the CPUs showed =
94-96%
> busy. Also interesting is what UNKNOWN_KERNEL is. ???
>=20
> The server described above has 14 internal IDE disks configured as =
software
> Raid 5 and connected to the network with one Syskonnect copper gigabit =
card.
> I used 30 100 base-T connected clients all of which performed =
sequential
> writes to one large 1.3TB volume on the file server. They were mounted
> NFSv2, UDP, 8K r+w size for this run. I was able to achieve only =
35MB/sec of
> sustained NFS write throughput. Local disk performance (e.g. dd file) =
for
> sustained writes is *much* higher. I am using knfsd with the latest =
2.4.18
> Neil Brown fixes from his site. Distribution is Debian 3.0 Woody =
Stable.
>=20
> Many thanks in advance for the insight,
>=20
> Eff Norwood
>=20
>=20
>=20
>=20
>=20


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
