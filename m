From: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
Subject: Re: NFS Problems (kernel locks up)
Date: Wed, 19 Mar 2003 14:35:22 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5CA6F03EF05E0046AC5594562398B916A32893@POEXMB3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <madmax@iskon.hr>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from usamail2.conoco.com ([12.31.208.227])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18vkHm-0000OU-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Mar 2003 12:35:42 -0800
To: <nfs@lists.sourceforge.net>
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




	I would suggest running a machine stress test on the machine.

	I did had a situation where a large NFS load would quickly take
	down a machine, and finally determined that the actual hardware
	was bad, and when put under stress would crash, I swapped
	out the hardware (case+mb+memory+cpu) with another (I used
	all of the same hd's) and the machine quite crashing even under
	the same kind of load.   The original machine lasted 5-10 minutes
	under heavy NFS load, would last days under light NFS loads.

	We have had good luck with 2.4.19 and 2.4.21pre[34] as nfs=20
	servers.

	The only thing to watch out for on the number of files is that
	there are issues on unix (unix in general) with lots of files
	in a single directory, quite a number of things get slow with
	lots of files in a single dir. =20

	You might try one of the cpu burn in type programs and see if
	that also makes it fail, and maybe a disk benchmark and see if=20
	that makes it fail.

	If either of those make it fail, it is a hardware problem of some
	sort.

	I have a large number of NFS servers and we get a few odd crashes
	that generally are traced back to hardware issues.
		=09
						Roger

> Message: 4
> Date: Wed, 19 Mar 2003 19:22:41 +0100
> From: Kresimir Kukulj <madmax@iskon.hr>
> To: nfs@lists.sourceforge.net
> Subject: [NFS] NFS problems (kernel locks up)
>=20
> Hi
>=20
> We are trying to assess if linux could perform as a NFS server to =
linux
> client(s). In our test we moved part of mailboxes of a freemail =
service
> (after some initial testing) to a NFS storage (linux NFS server). It =
worked
> ok, and used very little resources. But, during the nightly backup, =
NFS
> server crashed. Symptoms were that:
>   1. client detected that NFS server is not responding
>   2. NFS server responded to ping, but you could not log in to it. =
Every
>      attempt to log-in stopped at TCP connection being established, =
but
>      daemon did not respond (I presume, that at that particular moment
>      TCP/IP stack was still working).
>   3. After cca 10 minutes, it locks up (not ping-able).
>   4. I have serial console attached to the server, and kernel did not
>      respond to SYS-REQ.
>   5. After turning off the power and then back on, server booted, and
>      resumed its function.
>=20
> This happened three times, every time during the backup (Networker),
> sometimes only 5 minutes after backup started, sometimes after 1.5 =
hours.
> This was all using 2.4.20 kernel (no extra patches), using NFSv3, udp, =
async.
> NFS client was using: =
rw,hard,intr,udp,rsize=3D8192,wsize=3D8192,nodev,nosuid
> NFS server used: rw,no_root_squash (default is async).
>=20
> Then, I have put 2.4.21-pre5 because it contained some NFS fixes. =
After
> that, server survived three days (2 incrementals and one full backup
> completed successfully). Then it crashed during the day for no =
apparent
> reason (we have the server monitored with 'cricket', and there were no
> unusual activities...).
>=20
> I have changed to NFSv2,sync,udp and it crashed during the backup that =
night,
> and then again during the day. This resulted with filesystem =
corruption
> (replaying the ext3 journal caused fsck to be invoked - couple of =
hours was
> wasted on checking).
>=20
> Now I have reverted back to NFSv3,udp, but kept 'sync'. I will see =
tonight
> will it survive or not.=20
>=20
> Filesystem is 99Gb ext3 partition, with 1024 block size, internal =
journal.
> That fs is 50% full, and contains around 290000 files (13.7% =
fragmentation).
> Files are between few kilobytes up to 10 Mb.
>=20
> Normal filesystem usage is ~200kb read, 300Kb write per second with < =
5%
> disk utilization. When backup runs, reading gets ~ 5Mb/sec with disk
> utilization of ~ 100%.
>=20
> Client and server are connected to the same switch, with no dropped =
packets.
>=20
> We are satisfied with performance (while the server works).
>=20
> Can anybody give a suggestion ? I have tried everything I can think =
of.>=20
> We would like to use linux as a NFS server, but if this does not work, =
we
> will be forced to consider alternatives like Solaris x86.
> Can anyone here suggest a good alternative NFS server OS (for x86) =
with a
> good support for SCSI HW RAID controllers ? ICP Vortex unfortunately =
is
> not supported under Solaris x86, but what other controllers (let's say =
for
> Solaris x86) do you reccommend ?
>=20
> Also, I am concerned about filesystem. Will ext3 be able to handle, =
let's
> say, 10 million files ? If not, will Solaris x86 UFS be any better.
> [ For us, reiser proved to be sometimes difficult, and we had couple =
of fs
> related crashes, so we are trying to find alternatives. Filesystem =
check
> on that amount of files is measured in days. ]
>=20
> Some info about hardware:
> Dell PowerApp 200 with 2 x Pentium III (Coppermine), each 1GHz.
> 1Gb memory, with CONFIG_HIGHMEM4G=3Dy.
> eepro100 ethernet
> ServerWorks chipset but nothing except CDROM is connected to it.
> ICP Vortex Hardware RAID model GDT8523RZ
> Driver for this (SCSI) controller is from 2.4.20 kernel (its pretty =
new).
> 5 FUJITSU MAJ3364MC 34Gb drives in RAID5 (4+hotfix).
> Filesystem is ext3 with journal=3Dordered.
>=20
> Kernel is vanilla 2.4.20, and 2.4.21-pre5.
> I can provide 'dmesg' and '.config' for that kernel.
>=20
> Distribution is Debian stable 3.0.
> These packages are installed:
> ii  nfs-common              1.0-2                   NFS support files =
common to client and server
> ii  nfs-kernel-server       1.0-2                   Kernel NFS server =
support
>=20
> NFS server and client use fixed ports as described at NFS-Howto:
> Kernel command line: root=3D/dev/sda2 lockd.udpport=3D32768 \
>                      lockd.tcpport=3D32768 console=3Dtty0 =
console=3DttyS0,9600
> statd, mountd are fixed as well, and iptables are configured to pass
> fragmented packets. By default, NFS server runs with 8 kernel threads
> (knfsd). According to /proc/net/rpc/nfsd there is no need for more =
kernel
> threads.
>=20
> Services that run on NFS client are POP3 and SMTP daemons and a web =
based
> frontend that uses them. Both daemons are configured to use their =
version of
> dot locking (as recommended).
>=20
> Thanks.
>=20
> --=20
> Kresimir Kukulj
> Iskon Internet d.d.
> ISS
> Savska 41/X.
> 10000 Zagreb
>=20
>=20
>=20
> --__--__--
>=20
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20
>=20
> End of NFS Digest


-------------------------------------------------------
This SF.net email is sponsored by: Does your code think in ink? 
You could win a Tablet PC. Get a free Tablet PC hat just for playing. 
What are you waiting for?
http://ads.sourceforge.net/cgi-bin/redirect.pl?micr5043en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
