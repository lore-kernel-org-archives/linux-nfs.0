From: Banu Cosmin <sharpcoder@xnet.ro>
Subject: local unmount problem after starting or using NFS
Date: Wed, 25 Dec 2002 23:06:30 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200212252306.30993.sharpcoder@xnet.ro>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mta1.xnet.ro ([217.10.192.225])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18RIlk-00022q-00
	for <nfs@lists.sourceforge.net>; Wed, 25 Dec 2002 13:08:48 -0800
Received: from tavi (213.233.78.138.dial.xnet.ro [213.233.78.138] (may be forged))
	(authenticated (0 bits))
	by mta1.xnet.ro (Switch-2.2.0/Switch-2.2.0) with ESMTP id gBPL8c910390
	for <nfs@lists.sourceforge.net>; Wed, 25 Dec 2002 23:08:38 +0200
To: nfs@lists.sourceforge.net
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

Hello!

=09I am posting this since I searched about it on the internet and it see=
ms like=20
there are many people having these types of problems, yet no good solutio=
n=20
found.
=09I want to show you some scenarios and then pose the questions, and hop=
e=20
someone can help:

=09-- Local UnMounting doesn't work --

=091. consider the following:
=09=09- the linux sistem boots
=09=09- some local filesystems are automounted under `/mnt` (or some othe=
r=20
directory)
=09=09- the NFS service starts up
=09=09- the machine finishes loading the linux system
=09=09- now, when the user logs in, if he tries to unmount a local filesy=
stem=20
(`umount /mnt/drive`) mounted by automount, he gets `umount: /mnt/drive:=20
device busy`; it seems like, although the user didn't launch any process=20
which uses /mnt/drive, the NFS service somehow locked it and it cannot be=
=20
locally unmounted
=09=09- note: this scenario can be avoided by not letting automount to mo=
unt local=20
partitions at system startup; the NFS service must be started before any=20
local mounting takes place; however this doesn't work in scenario 2
=092. the previous scenario problem can be obtained also like this:
=09=09- NFS Server boots, no automount takes place
=09=09- NFS Client boots (another machine)
=09=09- NFS Server locally mounts /mnt/drive; please note that in this si=
tuation,=20
if we want to unmount /mnt/drive, we can do so, we don't get any errors, =
as=20
long as the following step takes place
=09=09- the Client mounts Server:/mnt/drive
=09=09- the Client gets its job done, then unmounts Server:/mnt/drive
=09=09- if the Server tries to unmount the local filesystem (`umount /mnt=
/drive`),=20
he gets `umount: /mnt/drive: device busy`; it is the same result as in=20
scenario 1
=09I did a little research and found that these two situations can be res=
ovled=20
with the following steps:
=09=09a. `exportfs -u Client:/mnt/drive` for each client that has access =
to that=20
drive (or a `exportfs -ua` for all exports)
=09=09b. unmount the local partition `umount /mnt/drive`, which succeedes=
 this=20
time
=09=09c. `exportfs Client:/mnt/drive` for each client that has access to =
that=20
drive (or a `exportfs -ra` for all exports)
=09OR
=09=09a. the NFS service on Server is stopped
=09=09b. unmount the local partition `umount /mnt/drive`
=09=09c. the NFS service on Server is started

=09Anyway, it seems like this problem is valid only for the local mounted=
=20
filesystems (partitions, cdrom, etc.) which appear in the '/etc/exports'=20
config file, thus shared to the outside world. It would be great if someo=
ne=20
could tell us what really goes on when NFS starts up, or when the Client=20
nfs-mounts the Server's local mounted drive. I'm kind of new to linux but=
 it=20
seems like on startup all entries in `/etc/exports` are somehow locked...=
 we=20
need gurus here :)

=09Thanks in advance for any help,
=09=09Banu Cosmin.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
