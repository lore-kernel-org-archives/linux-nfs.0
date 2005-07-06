From: Maximus <john.maximus@gmail.com>
Subject: Nfs Server not responding ?
Date: Wed, 6 Jul 2005 07:32:46 -0400
Message-ID: <3634de7405070604326a08bedd@mail.gmail.com>
Reply-To: Maximus <john.maximus@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.92] (helo=sc8-sf-mx2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dq899-00089n-Jt
	for nfs@lists.sourceforge.net; Wed, 06 Jul 2005 04:32:55 -0700
Received: from zproxy.gmail.com ([64.233.162.207])
	by sc8-sf-mx2-new.sourceforge.net with esmtp (Exim 4.44)
	id 1Dq899-0006E3-Cv
	for nfs@lists.sourceforge.net; Wed, 06 Jul 2005 04:32:55 -0700
Received: by zproxy.gmail.com with SMTP id 9so541685nzo
        for <nfs@lists.sourceforge.net>; Wed, 06 Jul 2005 04:32:46 -0700 (PDT)
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

Hi,
  I am getting the following error in my system

I have a root file system ar /home/rootfs

I dont know what is the problem. please help.

The Kernel is getting copied on target ; But root file system is not
getting mounted
using NFS.

The Kernel and the root file system is in the same machine
XX.YY.13.112.

IP-Config: Got DHCP answer from XX.YY.13.112, my address is XX.YY.13.65
IP-Config: Complete:
      device=3Deth0, addr=3DXX.YY.13.65, mask=3D255.255.255.0,
gw=3D255.255.255.255,
     host=3DXX.YY.13.65, domain=3D, nis-domain=3D(none),
     bootserver=3DXX.YY.13.112, rootserver=3DXX.YY.13.112,
rootpath=3D/home/rootfs
Looking up port of RPC 100003/2 on XX.YY.13.112
Looking up port of RPC 100005/1 on XX.YY.13.112
Root-NFS: Server returned error -13 while mounting /home/rootfs
VFS: Unable to mount root fs via NFS, trying floppy.
VFS: No root yet, retrying to mount root on nfs (unknown-block(2,0))
VFS: No root yet, retrying to mount root on nfs (unknown-block(2,0))
VFS: No root yet, retrying to mount root on nfs (unknown-block(2,0))
VFS: No root yet, retrying to mount root on nfs (unknown-block(2,0))
VFS: No root yet, retrying to mount root on nfs (unknown-block(2,0))
VFS: No root yet, retrying to mount root on nfs (unknown-block(2,0))
VFS: Cannot open root device "nfs" or unknown-block(2,0)
Please append a correct "root=3D" boot option
Kernel panic: VFS: Unable to mount root fs on unknown-block(2,0)

File : /etc/exports looks like this
/home/rootfs (rw,no_root_squash,no_all_squash)

File:/etc/dhcpd.conf looks this this

ddns-update-style ad-hoc;
allow bootp;
subnet XX.YY.13.0 netmask 255.255.255.0 {
default-lease-time 1209600;
max-lease-time 31557600;
group {
host hello.i2.com {
hardware Ethernet 00:0E:99:XX:YY:ZZ;
fixed-address XX.YY.13.65;
option root-path "/home/rootfs";

}
}
}


I also face one more issue i am facing is:
   i have 2 kernels (both of them 2.6.12) made out of the same
defconfig but compiled using 2 different tool chains.

For Kernel1:

If I specify bootargs=20
mem=3D30M console=3DttyS0,115200 rw root=3D/dev/nfs
nfsroot=3DXX.YY.13.112:/home/rootfs ip=3DXX.YY.13.65:XX.YY.13.112

it Works.

Otherwise it does not work ?.

For Kernel2:
Does not work with the above bootargs

Works Only if bootargs are mem=3D30M console=3DttyS0,115200 rw root=3D/dev/=
nfs=20

Please advice,

I dont know what the problem is ?.

How to analyse the problem and solve it ?.



Regards,
John


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
