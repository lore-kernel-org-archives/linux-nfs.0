From: "Weber, Eugene F (Gene)" <efw@agere.com>
Subject: RPC Time Out
Date: Mon, 1 Dec 2003 13:38:31 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <FEF7905AD5F3DE4988CBEF096C280A4C1A48E0@pauex2ku02.agere.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AQswP-0002h3-00
	for <nfs@lists.sourceforge.net>; Mon, 01 Dec 2003 10:38:37 -0800
Received: from alageremail2.agere.com ([192.19.192.110])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AQswP-00060r-A9
	for nfs@lists.sourceforge.net; Mon, 01 Dec 2003 10:38:37 -0800
Received: from alerelay.agere.com (alerelay.agere.com [135.14.190.33])
	by alageremail2.agere.com (8.11.7+Sun/8.10.2) with ESMTP id hB1IcWY18135
	for <nfs@lists.sourceforge.net>; Mon, 1 Dec 2003 13:38:32 -0500 (EST)
Received: from palex2kh01.ags.agere.com (palex2kh01.agere.com [128.94.210.100])
	by alerelay.agere.com (8.11.6+Sun/8.11.6) with ESMTP id hB1IcVD17265
	for <nfs@lists.sourceforge.net>; Mon, 1 Dec 2003 13:38:31 -0500 (EST)
To: <nfs@lists.sourceforge.net>
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

Top of Form 1

Hi,
I am trying to install Debian Linux on an old laptop that=20
does not have a CD-ROM drive. I did a basic incomplete=20
installation of 3.01r "Woody" (kernel is 2.2) using floppy=20
disks. I have a second laptop that has a complete=20
RedHat 8.0 (kernel is 2.4) installation and a CD-ROM=20
drive. My plan has been to network the two laptops,=20
mount the CD-ROM drive from the RedHat machine and=20
complete the Debian install.=20

I have what appears to be a working 802.11b wireless=20
network between the machines. IP addresses are=20
assigned, and each machine can ping the other. The=20
RedHat machine is 192.168.2.57 and the Debian machine=20
is 192.168.2.51. So I tried to do the mount based on=20
the "NFS-HOWTO" on linux.org.=20

SETTING UP THE SERVER
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
On the RedHat machine I set=20
up /etc/exports, /etc/hosts.deny & /etc/hosts.allow as=20
follows:

exports
-----------
/dev/cdrom 192.168.2.51
(ro,no_root_squash,no_subtree_check)
/home/efw 192.168.2.51(ro,no_root_squash)

hosts.deny
----------------
ALL:ALL

hosts.allow
----------------
ALL:192.168.2.51

A rpcinfo on the Red hat machine shows that it was only=20
running portmapper, status and sgi_fam. All of the=20
appropriate services existed under /sbin and /usr/sbin so=20
I launched them with a script I called "nfs_start" to=20
launch them in the correct order.

nfs_start
-------------
/usr/sbin/rpc.mountd
/usr/sbin/rpc.nfsd
/sbin/rpc.statd
/sbin/rpc.lockd
/usr/sbin/rpc.rquotad

rpcinfo -p now showed:
program vers proto port
100000 2 tcp 111 portmapper
100000 2 udp 111 portmapper
391002 2 tcp 1029 sgi_fam
100005 1 udp 1025 mountd
100005 1 tcp 1030 mountd
100005 2 udp 1025 mountd
100005 2 tcp 1030 mountd
100005 3 udp 1025 mountd
100005 3 tcp 1030 mountd
100003 2 udp 2049 nfs
100003 3 udp 2049 nfs
100021 1 udp 1026 nlockmgr
100021 3 udp 1026 nlockmgr
100021 4 udp 1026 nlockmgr
100024 1 udp 1027 status
100024 1 tcp 1031 status
100011 1 udp 797 rquotad
100011 2 udp 797 rquotad
100011 1 tcp 800 rquotad
100011 2 tcp 800 rquotad

SETTING UP THE CLIENT
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
rpcinfo -p on the Debian laptop gave an rpc error. I saw=20
that none of the services existed anywhere on the=20
machine. I installed package "portmap_5-2_i386.deb"=20
and package "nfs-common_1.0-2_i386.deb". After the=20
successful installs, portmap, statd and lockd all existed=20
under /sbin. The installation also said it started each of=20
the services. rpcinfo -p now showed:

program vers proto port
100000 2 tcp 111 portmapper
100000 2 udp 111 portmapper
100024 1 udp 1024 status
100024 1 tcp 1024 status

I though perhaps lockd was not started, but executing it=20
and then checking rpcinfo -p gives the same result??=20
The shown services now seemed to be launched at boot=20
up.

rpcinfo -p 192.168.2.57 from the client gives the same=20
result as doing rpcinfo -p on the server. Likewise doing=20
rpcinfo -p 192.168.2.51 from the server gives the same=20
result as doing rpcinfo -p on the client.

If I execute "mount 192.168.2.57:/dev/cdrom /cdrom" on=20
the Debian client system it sits for a while and then=20
comes back with "mount RPC: Timed out". Same=20
with "mount 192.168.2.57:/home/efw /fred" on the=20
Debian client system, it sits for a while and then comes=20
back with "mount RPC: Timed out".

The HOWTO says you would like the version of nfs-utils,=20
but I have no clue how to determine that.

If anyone understands what the problem I am=20
encountering is I would appreciate your help.

Thanks & Best Regards,

Gene Weber Bottom of Form 1



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
