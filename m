From: Bernd Schubert <bernd-schubert@web.de>
Subject: nfs problems since server runs 2.4.19
Date: Fri, 20 Sep 2002 16:27:29 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200209201627.29328.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from relay.uni-heidelberg.de ([129.206.100.212])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17sOkt-000273-00
	for <nfs@lists.sourceforge.net>; Fri, 20 Sep 2002 07:27:40 -0700
Received: from ix.urz.uni-heidelberg.de (mail.urz.uni-heidelberg.de [129.206.119.234])
	by relay.uni-heidelberg.de (8.12.4/8.12.4) with ESMTP id g8KERUL0027690
	for <nfs@lists.sourceforge.net>; Fri, 20 Sep 2002 16:27:30 +0200 (MET DST)
Received: from euklid (bernd@euklid.pci.uni-heidelberg.de [129.206.21.104])
	by ix.urz.uni-heidelberg.de (8.8.8/8.8.8) with ESMTP id QAA43424
	for <nfs@lists.sourceforge.net>; Fri, 20 Sep 2002 16:27:29 +0200
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

Hi,

we have some strange problems since we run our server with a patched 2.4.=
19=20
(all the nfs patches that are in 2.4.20 except the 2 tcp ones).=20

Well on the server we rather often get the following lines for several of=
 our=20
clients:
Sep 20 13:08:45 coulomb rpc.statd[866]: Received erroneous SM_UNMON reque=
st=20
from coulomb for 192.168.0.1

On some clients we get the following messages:
Sep 20 13:44:28 cauchy kernel: nsm_mon_unmon: rpc failed, status=3D-5
Sep 20 13:44:28 cauchy kernel: lockd: cannot monitor 192.168.0.100
Sep 20 13:44:28 cauchy kernel: lockd: failed to monitor 192.168.0.100
Sep 20 13:44:41 cauchy kernel: statd: server localhost not responding, ti=
med=20
out

Well, when this happens on the client, no kde program is working any long=
er=20
(other window managers that need the home directory as well, work fine). =
The=20
solution for this is to start the rpc.statd on the client.


Well, since all of this happend after we upgraded from 2.4.18 to=20
2.4.19+nfs-patches, I think its in direct connection with the upgrade.


Thanks,

Bernd

--=20
Bernd Schubert
Physikalisch Chemisches Institut
Abt. Theoretische Chemie
INF 229, 69120 Heidelberg
Tel.: 06221/54-5210
e-mail: =09bernd (dot) schubert (at) pci (dot) uni-heidelberg (dot) de=20


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
