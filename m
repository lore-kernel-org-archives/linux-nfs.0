From: Jerome Walters <jeronimo-CNLtBM1LHs6sTnJN9+BGXg@public.gmane.org>
Subject: nfs: server not responding
Date: Sat, 16 May 2009 00:57:01 +0000 (UTC)
Message-ID: <loom.20090516T005618-989@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:36243 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752431AbZEPBAF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 May 2009 21:00:05 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1M58Fu-0003Oe-Lv
	for linux-nfs@vger.kernel.org; Sat, 16 May 2009 01:00:03 +0000
Received: from vanilla.varna.spnet.net ([212.50.0.56])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sat, 16 May 2009 01:00:02 +0000
Received: from jeronimo by vanilla.varna.spnet.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sat, 16 May 2009 01:00:02 +0000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Description of problem:
Periodically, and with no obvious cause, all NFS connections between ou=
r Debian=20
Testing (_Squeeze_) x86 client (a diskless node which uses nfsroot and =
boots=20
from the server) and our Debian Testing (_Squeeze_) x86 server hang and=
 dmesg=20
on the client side informs that the server is "not responding".

The server is responding to everyone else's requests.=20

Restarting the nfsd on the server doesn't appear to solve the problem.

At first I wasnt able to capture some debug information since /var/log =
was=20
mounted over the nfs, so I have installed a hard drive where I mounted=20
only /var/log to be able to capture debug logs from the client as well.


Debug Logs:=20
http://fixity.net/tmp/client.log.gz - Kernel RPC Debug Log from the cli=
ent
http://fixity.net/tmp/server.log.gz - Kernel RPC Debug Log from the ser=
ver


How reproducible:
Happens from 10 to 90 minutes after booting the diskless node.


Actual results:
NFS connections stop responding, system hangs or becomes very slow and=20
unresponsive (it doesnt respond to Ctrl+Alt+Del as well). 60 to 90 minu=
tes=20
after the first server time out client says server OK but the client is=
 still=20
unresponsive. Immediately after that the client logs server connection =
loss=20
again which leads to continues loop. Client is still unresponsive. Some=
times=20
client resumes normal operation for couple of hours but then the proble=
m=20
repeats.


Connectivity info:=20
Both the client and the server are connected to Gigabit Ethernet Cisco =
Metro=20
series managable switch. Both of them use Intel Pro 82545GM Gigabit Eth=
ernet=20
Server Controllers. Neither one of them log any Ethernet errors and non=
e are=20
logged by the switch.


Expected results:
NFS connections continue to function and don't fail like clockwork when=
 every=20
other client on the network has no issues.


Client & Server Load:
=46or the purposes of testing both machines were only running needed da=
emons and=20
weren=E2=80=99t loaded at all.


Client & Server Kernel:
On both the client and server custom compiled linux 2.6.29.3 kernel was=
 used.=20
Configuration file @ http://fixity.net/tmp/config-2.6.29.3.gz


Client & Server Network interface fragmented packet queue length:
net.ipv4.ipfrag_high_thresh =3D 524288
net.ipv4.ipfrag_low_thresh =3D 393216


Client Versions:
libnfsidmap2/squeeze uptodate 0.21-2
nfs-common/squeeze uptodate 1:1.1.4-1


Client Mount (cat /proc/mounts | grep nfsroot):
10.11.11.1:/nfsroot / nfs=20
rw,vers=3D3,rsize=3D524288,wsize=3D524288,namlen=3D255,hard,nointr,nolo=
ck,proto=3Dtcp,time
o=3D7,retrans=3D10,sec=3Dsys,addr=3D10.11.11.1 0 0


Client fstab:
proc            /proc           proc    defaults        0       0
/dev/nfs        /               nfs     defaults        1       1
none            /tmp            tmpfs   defaults        0       0
none            /var/run        tmpfs   defaults        0       0
none            /var/lock       tmpfs   defaults        0       0
none            /var/tmp        tmpfs   defaults        0       0


Client Daemons:
portmap, rpc.statd, rpc.idmapd


Server Daemons:
portmap, rpc.statd, rpc.idmapd, rpc.mountd --manage-gids


Server Versions:
libnfsidmap2/squeeze uptodate 0.21-2
nfs-common/squeeze uptodate 1:1.1.4-1
nfs-kernel-server/testing uptodate 1:1.1.4-1


Server Export:
/nfsroot 10.11.11.*(rw,no_root_squash,async,no_subtree_check)


Server Options:
RPCNFSDCOUNT=3D16
RPCNFSDPRIORITY=3D0
RPCMOUNTDOPTS=3D--manage-gids
NEED_SVCGSSD=3Dno
RPCSVCGSSDOPTS=3Dno


Additional Info:
Since I have read that tweaking the nfsroot mount options could improve=
 the=20
situation a have tested with different options as follows:
rsize/wsize=3D1024|2048|4096|8192|32768|524288
timeo=3D15|60|600
retrans=3D3|10|20
None resulted in solving the problem.





Any help or suggestions on fixing the problem would be highly appreciat=
ed. I=20
have been messing with that problem for the last couple of weeks and ra=
n out of=20
ideas.


Best Regards,
Jerome Walters

