From: pof <pau@eslack.org>
Subject: estrange nfs problem
Date: Thu, 3 Apr 2003 15:49:51 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030403154951.08738fc3.pau@eslack.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="pgp-sha1"; boundary="=.58'3tBORlKc2Kb"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 217-126-5-53.uc.nombres.ttd.es ([217.126.5.53] helo=s0.pofhq.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19156P-0006DW-00
	for <nfs@lists.sourceforge.net>; Thu, 03 Apr 2003 05:50:04 -0800
Received: from w0.pofhq.net (w0.pofhq.net [192.168.1.10])
	(authenticated bits=0)
	by pof.eslack.org with id h33Dne0S008530
	for <nfs@lists.sourceforge.net>; Thu, 3 Apr 2003 15:49:40 +0200
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

--=.58'3tBORlKc2Kb
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

Hello,

I'm experiencing extraneous locking problems with nfs and I don't know
what is causing them.

This is what I see in client's syslog:

Mar 31 02:14:35 w0 nfs: server 192.168.1.1 not responding, still trying
Mar 31 02:15:26 w0 nfs: server 192.168.1.1 OK
Mar 31 02:19:27 w0 nfs: server 192.168.1.1 not responding, still trying
Mar 31 02:25:05 w0 nfs: server 192.168.1.1 OK
Mar 31 02:29:42 w0 nfs: server 192.168.1.1 not responding, still trying
Mar 31 02:30:03 w0 nfs: server 192.168.1.1 OK
Mar 31 02:30:32 w0 nfs: server 192.168.1.1 not responding, still trying
Mar 31 02:32:04 w0 nfs: server 192.168.1.1 OK
Mar 31 02:35:25 w0 nfs: server 192.168.1.1 not responding, still trying
Mar 31 02:39:02 w0 nfs: server 192.168.1.1 OK
[...]
Apr  3 03:29:13 w0 nsm_mon_unmon: rpc failed, status=-13
Apr  3 03:29:13 w0 lockd: cannot monitor 192.168.1.1
Apr  3 03:29:13 w0 lockd: failed to monitor 192.168.1.1
Apr  3 03:29:13 w0 nsm_mon_unmon: rpc failed, status=-13
Apr  3 03:29:13 w0 lockd: cannot monitor 192.168.1.1
Apr  3 03:29:13 w0 lockd: failed to monitor 192.168.1.1
Apr  3 03:32:25 w0 nsm_mon_unmon: rpc failed, status=-13
Apr  3 03:32:25 w0 lockd: cannot monitor 192.168.1.1
Apr  3 03:32:25 w0 lockd: failed to monitor 192.168.1.1
[...]


This is my server configuration, I'm running nfs-utils version 1.0.1.
---
root@s0~# cat /etc/exports 
/home   w0.pofhq.net(rw,sync,wdelay,no_root_squash)
/home   rulez.pofhq.net(rw,sync,wdelay,no_root_squash)
/home/public   *.pofhq.net(rw,sync,wdelay,root_squash,all_squash)
/home/music   *.pofhq.net(ro,sync,wdelay,no_root_squash)

root@s0/usr/src/linux# cat .config |grep -i nfs
CONFIG_NFS_FS=y
CONFIG_NFS_V3=y
# CONFIG_ROOT_NFS is not set
CONFIG_NFSD=y
CONFIG_NFSD_V3=y
# CONFIG_NFSD_TCP is not set
# CONFIG_NCPFS_NFS_NS is not set

root@s0~# rpcinfo -p localhost
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  32769  status
    100024    1   tcp  44942  status
    100011    1   udp    773  rquotad
    100011    2   udp    773  rquotad
    100011    1   tcp    776  rquotad
    100011    2   tcp    776  rquotad
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100021    1   udp  32770  nlockmgr
    100021    3   udp  32770  nlockmgr
    100021    4   udp  32770  nlockmgr
    100021    1   tcp  41950  nlockmgr
    100021    3   tcp  41950  nlockmgr
    100021    4   tcp  41950  nlockmgr
    100005    1   udp  32771  mountd
    100005    1   tcp  58640  mountd
    100005    2   udp  32771  mountd
    100005    2   tcp  58640  mountd
    100005    3   udp  32771  mountd
    100005    3   tcp  58640  mountd

---

This is my client configuration:
---
/bin/mount 192.168.1.1:/home /home -o sync
/bin/mount 192.168.1.1:/home/distfiles /usr/portage/distfiles -o sync

pau@w0/usr/src/linux$ cat .config |grep -i nfs
CONFIG_NFS_FS=y
CONFIG_NFS_V3=y
# CONFIG_ROOT_NFS is not set
CONFIG_NFSD=m
# CONFIG_NFSD_V3 is not set
# CONFIG_NFSD_TCP is not set
# CONFIG_NCPFS_NFS_NS is not set

pau@w0~$ rpcinfo -p localhost
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100021    1   udp  32768  nlockmgr
    100021    3   udp  32768  nlockmgr
    100021    4   udp  32768  nlockmgr
---

Any help would be appreciated. Thank-you.

	pau.

--- 
 .----------------------------------------------.
|  Pau Oliva Fora         http://pof.eslack.org  |
|  KeyID: 665D05B533539E02 available at keyserv  |
 `----------------------------------------------'

--=.58'3tBORlKc2Kb
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQE+jDwFZl0FtTNTngIRAuw0AJ4xvbRVUyyOadVCc2z2Bm3gcwW1EACcD7LA
W16G/qOIHOa/ypCWWYe0jiw=
=ncW2
-----END PGP SIGNATURE-----

--=.58'3tBORlKc2Kb--


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
