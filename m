From: philippe musial <happylinuxuser@yahoo.fr>
Subject: unknow auth error with a nfs mounted root client
Date: Mon, 18 Jun 2007 16:49:43 +0200 (CEST)
Message-ID: <20070618144943.8723.qmail@web23003.mail.ird.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I0KIZ-00073v-77
	for nfs@lists.sourceforge.net; Mon, 18 Jun 2007 09:41:51 -0700
Received: from web23003.mail.ird.yahoo.com ([217.146.189.28])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1I0KHV-0002lU-LQ
	for nfs@lists.sourceforge.net; Mon, 18 Jun 2007 09:40:46 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi everybody,

I try to duplicate a model built in a chrooted
environment under Debian Etch with replicator. I made
a boot disk and when I use it on the target computer
(192.168.1.3) I get this message:
call_verify: unknown auth error: 7
Root-NFS: Server returned error -5 while mounting
/export/install/miniroot.

cat /etc/hosts.allow:
portmap: 192.168.1.3
rpc.mountd: 192.168.1.3

rpcinfo -p localhost:
   program no_version protocole  no_port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp   1784  status
    100024    1   tcp   4759  status
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    4   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100021    1   udp   1785  nlockmgr
    100021    3   udp   1785  nlockmgr
    100021    4   udp   1785  nlockmgr
    100021    1   tcp   3420  nlockmgr
    100021    3   tcp   3420  nlockmgr
    100021    4   tcp   3420  nlockmgr
    100005    1   udp    812  mountd
    100005    1   tcp    815  mountd
    100005    2   udp    812  mountd
    100005    2   tcp    815  mountd
    100005    3   udp    812  mountd
    100005    3   tcp    815  mountd

I didn't find this error message with google, so could
you please help me to solve this problem?

Thanks






      =

	=

		=

___________________________________________________________________________ =

D=E9couvrez une nouvelle fa=E7on d'obtenir des r=E9ponses =E0 toutes vos qu=
estions ! =

Profitez des connaissances, des opinions et des exp=E9riences des internaut=
es sur Yahoo! Questions/R=E9ponses =

http://fr.answers.yahoo.com

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
