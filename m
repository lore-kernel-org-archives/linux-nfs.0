From: Holger Burde <hburde@t-online.de>
Subject: NFSv4 problem ..
Date: Sun, 15 May 2005 14:02:02 +0200
Message-ID: <1116158522.12936.28.camel@marvin.hb-consult.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DXIiE-0001N4-Ld
	for nfs@lists.sourceforge.net; Sun, 15 May 2005 05:59:18 -0700
Received: from mailout09.sul.t-online.com ([194.25.134.84])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DXIiD-0004MS-Jw
	for nfs@lists.sourceforge.net; Sun, 15 May 2005 05:59:18 -0700
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

Hi;

Doing some experiments with NFSv4 i stumbled over a problem were 'some'
progs hang on writes others do not. The hangs are 100% reproducable. vi,
ar hang on every write and nedit works (4 whatever reason ..).
The progs are only killable with -9. Restarting Services, rebooting etc.
does not help. The configuration seems ok. I did the test with selinux
and without (no enforcing) - same result.=20

Both boxes are Dual Xeon's with smp Kernel
Server : FC3 with latest patches (2.6.11-1.14_FC3smp)
Client : FC3 with latest patches (2.6.11-1.14_FC3smp)

Clients mounts homedir from Server (no automount involved)
No Kerberos/GSS at the moment.

Server: Test Setup

/etc/exports

/NFS4 a.b.c.d/e
(rw,insecure,no_subtree_check,sync,wdelay,no_all_squash,no_root_squash,fs=
id=3D0)
/NFS4/joe    a.b.c.d/e
(rw,nohide,insecure,no_subtree_check,sync,wdelay,no_all_squash,no_root_sq=
uash)
....

/etc/fstab
....
/home/joe            /NFS4/joe	           none    bind            0 0
/home/opt            /NFS4/opt             none    bind            0 0
...


[root@neutrino ~]# rpcinfo -p neutrino
   Program Vers Proto   Port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100011    1   udp    701  rquotad
    100011    2   udp    701  rquotad
    100011    1   tcp    704  rquotad
    100011    2   tcp    704  rquotad
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    4   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100021    1   udp  32770  nlockmgr
    100021    3   udp  32770  nlockmgr
    100021    4   udp  32770  nlockmgr
    100021    1   tcp  32771  nlockmgr
    100021    3   tcp  32771  nlockmgr
    100021    4   tcp  32771  nlockmgr
    100005    1   udp    716  mountd
    100005    1   tcp    719  mountd
    100005    2   udp    716  mountd
    100005    2   tcp    719  mountd
    100005    3   udp    716  mountd
    100005    3   tcp    719  mountd
    100024    1   udp  32779  status
    100024    1   tcp  32774  status

rpc.idmapd,rpc.statd, rpc.rquotad, rpc.mountd running

Client : Test Setup


Options: (tried also with sync and no rsize,wsize)
async,auto,exec,_netdev,nodev,rw,retry=3D5,rsize=3D32768,
wsize=3D32768,proto=3Dtcp,soft,intr

mount -v -t nfs4 -o $OPTIONS  host:/joe /home/joe

#mount -v -t nfs4 $OP $HOST:/opt /home/opt
[root@wimp bin]# rpcinfo -p wimp
   Program Vers Proto   Port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  32768  status
    100024    1   tcp  32768  status
1073741824    1   tcp  32770


rpc.statd,  rpc.idmapd are running

On both boxes no visable errors (/var/log/messages etc.)

Any idea what may cause this problem? or how to get rid of it ????


Thx in advance

hb

  =20
--=20
Dipl. Inform. H. Burde
----------------------------------------------------
EMail: hburde@t-online.de ; hburde@uni-bremen.de
Wenn Gau=C3=9F heute lebte, w=C3=A4re er ein Hacker. /P.Sarnak=20
----------------------------------------------------



-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=3D7393&alloc_id=3D16281&op=3Dclick
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
