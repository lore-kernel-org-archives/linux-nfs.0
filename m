From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: processes stuck in....?
Date: Tue, 6 May 2003 15:24:15 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113127DAD@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19DArM-0003pt-00
	for <nfs@lists.sourceforge.net>; Tue, 06 May 2003 15:24:28 -0700
To: "Jean-Christophe Ducom" <jducom@nd.edu>
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

hi jean-christophe-

i have a similar system here (1.26GHz dual Tualatin P-III
system with 1GB and SysKonnect GbE, currently running
2.4.21-pre7 on RH7.2) that i use to run a nightly backup
of about 45GB via tar over NFS.  (naturally there are
better ways to run a backup; i use this as an NFS client
exerciser).

your symptoms sound like a hardware problem to me.  have
you checked your mainboard and memory?

> -----Original Message-----
> From: Jean-Christophe Ducom [mailto:jducom@nd.edu]
> Sent: Tuesday, May 06, 2003 3:23 PM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] processes stuck in....?
>=20
>=20
> Hi,
>=20
> 	I'd like to get some feedback on a problem that freezes=20
> SMP clients so hard=20
> that a) even when a monitor is plugged, there is no display=20
> (no control from=20
> keyboard either)
> b) no terminal console access via serial port c) even=20
> nmi_watchdog can't get out=20
> of it apparently (no report)
> This happens usually in a pretty consistently when the nfs=20
> client creates a lot=20
> of files (like 800+) or write big file.
> I don't have any tcpdump or something else for now.
> Any idea/suggestion (change mount options?)
> Thanks for any help or feedback
>=20
> 		JC
>=20
>=20
>=20
>=20
>=20
> Client: Precision 530 Dual 1.7GhZ Xeon with Syskonnect SK9D21=20
> GigE, Redhat 7.2,=20
> kernel 2.4.21-rc1, nfs-utils-1.0.3-1 with ext2 file
> # rpcinfo -p
>     program vers proto   port
>      100000    2   tcp    111  portmapper
>      100000    2   udp    111  portmapper
>      100021    1   udp  32768  nlockmgr
>      100021    3   udp  32768  nlockmgr
>      100021    4   udp  32768  nlockmgr
>      100024    1   udp    904  status
>      100024    1   tcp    907  status
> The directory are mounted with option:
> 10.0.0.10:/export/data  /opt/data       nfs=20
> rw,nosuid,nodev,hard,intr,bg,rsize=3D8192,wsize=3D8192 0 0
>=20
> Excerpt from /var/log/messages:
> May  6 13:59:27 bob1 kernel: sk9dlin: Network Device Driver v1.03
> May  6 13:59:27 bob1 kernel: (C)Copyright 2001 SysKonnect GmbH.
> May  6 13:59:27 bob1 kernel: eth0: SysKonnect SK-9D21 Gigabit Ethernet
> May  6 13:59:27 bob1 kernel: eth0: network connection down
> May  6 13:59:27 bob1 kernel: eth0: NIC Link is downeth0:=20
> network connection down
> May  6 13:59:27 bob1 kernel: eth0: Network connection up using
> May  6 13:59:27 bob1 kernel:       speed        =3D 1000 Mbps
> May  6 13:59:27 bob1 kernel:       duplex mode  =3D full
> May  6 13:59:27 bob1 kernel:       card         =3D copper
> May  6 13:59:27 bob1 kernel:       flowctrl     =3D none
> May  6 13:59:27 bob1 kernel:       autoneg      =3D no
> .....
> May  6 13:59:24 bob1 sysctl: net.ipv4.ip_forward =3D 0
> May  6 13:59:24 bob1 sysctl: net.ipv4.conf.default.rp_filter =3D 1
> May  6 13:59:24 bob1 sysctl: kernel.sysrq =3D 0
> May  6 13:59:24 bob1 sysctl: kernel.shmall =3D 33554432
> May  6 13:59:24 bob1 sysctl: kernel.shmmax =3D 536870912
> May  6 13:59:24 bob1 sysctl: net.ipv4.tcp_fin_timeout =3D 30
> May  6 13:59:24 bob1 sysctl: net.ipv4.tcp_keepalive_time =3D 1800
> May  6 13:59:24 bob1 sysctl: net.ipv4.tcp_window_scaling =3D 0
> May  6 13:59:24 bob1 sysctl: net.ipv4.tcp_sack =3D 0
> May  6 13:59:24 bob1 sysctl: net.ipv4.tcp_timestamps =3D 0
> May  6 13:59:24 bob1 sysctl: net.ipv4.ip_no_pmtu_disc =3D 1
> May  6 13:59:24 bob1 sysctl: net.core.rmem_max =3D 262143
> May  6 13:59:24 bob1 sysctl: net.core.rmem_default =3D 262143
> May  6 13:59:24 bob1 sysctl: net.core.wmem_max =3D 262143
> .....
> May  6 13:59:34 bob1 rpc.lockd: lockdsvc: Function not implemented
> May  6 13:59:34 bob1 nfslock: rpc.lockd startup failed
> May  6 13:59:34 bob1 rpc.statd[724]: Version 1.0.3 Starting
> May  6 13:59:34 bob1 nfslock: rpc.statd startup succeeded
>=20
>=20
> -----------------------------
> Server: 530 Dual 1.7GhZ Xeon with Syskonnect SK9D21 GigE,=20
> Redhat 7.2, kernel=20
> 2.4.21-rc1, nfs-utils-1.0.3-1 with ext3 on a raid5
> # rpcinfo -p
>     program vers proto   port
>      100000    2   tcp    111  portmapper
>      100000    2   udp    111  portmapper
>      100011    1   udp    696  rquotad
>      100011    2   udp    696  rquotad
>      100011    1   tcp    699  rquotad
>      100011    2   tcp    699  rquotad
>      100003    2   udp   2049  nfs
>      100003    3   udp   2049  nfs
>      100021    1   udp  32768  nlockmgr
>      100021    3   udp  32768  nlockmgr
>      100021    4   udp  32768  nlockmgr
>      100005    1   udp    732  mountd
>      100005    1   tcp    735  mountd
>      100005    2   udp    732  mountd
>      100005    2   tcp    735  mountd
>      100005    3   udp    732  mountd
>      100005    3   tcp    735  mountd
>      100024    1   udp    757  status
>      100024    1   tcp    760  status
> # cat /etc/exports
> /export/data 10.0.3.0/8(rw) 10.0.0.1(rw)
>=20
>=20
> Excerpt From /var/log/messages:
> May  5 21:24:44 file1 exportfs[938]: /etc/exports [4]: No=20
> 'sync' or 'async'=20
> option specified for export "10.0.0.1:/export/data".  =20
> Assuming default=20
> behaviour ('sync').   NOTE: this default has changed from=20
> previous versions
> May  5 21:24:44 file1 nfs: Starting NFS services:  succeeded
> May  5 21:24:45 file1 nfs: rpc.rquotad startup succeeded
> May  5 21:24:45 file1 nfs: rpc.nfsd startup succeeded
> May  5 21:24:45 file1 nfs: rpc.mountd startup succeeded
> May  5 21:24:45 file1 nfslock: rpc.lockd startup succeeded
> May  5 21:24:45 file1 rpc.statd[1001]: Version 1.0.3 Starting
> May  5 21:24:45 file1 nfslock: rpc.statd startup succeeded
>=20
> The exported directory is on a Promise Ultratrak100 TX8=20
> connected to a Tekram=20
> 390U3W.
>=20
>=20
>=20
> -------------------------------------------------------
> Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
> The only event dedicated to issues related to Linux=20
> enterprise solutions
> www.enterpriselinuxforum.com
>=20
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
