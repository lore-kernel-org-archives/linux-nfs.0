From: Salvador Peralta <speralta@willamette.edu>
Subject: Recent intermittent problem authenticating clients against NFS.
Date: Wed, 30 Oct 2002 15:26:05 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3DC06A8D.8020706@willamette.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from earth.willamette.edu ([158.104.100.101])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1872FC-00064g-00
	for <nfs@lists.sourceforge.net>; Wed, 30 Oct 2002 15:27:26 -0800
Received: from smtp1 (smtp1 [158.104.100.20])
	by earth.willamette.edu (8.9.3/8.9.3/happy) with ESMTP
	id PAA10549 for <nfs@lists.sourceforge.net>; Wed, 30 Oct 2002 15:27:25 -0800 (PST)
Received: from hermes (hermes.willamette.edu [158.104.100.30])
	by smtp1.willamette.edu (8.12.3/8.12.3) with ESMTP id g9UNRGG1002108
	for <nfs@lists.sourceforge.net>; Wed, 30 Oct 2002 15:27:16 -0800 (PST)
Received: from willamette.edu ([158.104.2.159])
 by hermes.willamette.edu (iPlanet Messaging Server 5.2 HotFix 0.9 (built Jul
 29 2002)) with ESMTP id <0H4T00KGVIHG5F@hermes.willamette.edu> for
 nfs@lists.sourceforge.net; Wed, 30 Oct 2002 15:27:16 -0800 (PST)
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

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hello all,

We are experiencing an (apparently) recent phenomenon involving
intermittent problem authenticating clients against NFS.

Clients can generally connect, but periodically, a random given client
will attempt to authenticate against NFS, and will fail with  (example)
"Oct 30 14:02:46 info-1 rpc.mountd: refused mount request from lib-ncd9
for /home (/): no export entry"  logged in /var/log/messages.

Once first client fails to authenticate, each subsequent attempt to
authenticate from any client fails causing a cascading effect until each
parent process managing connection is killed and/or client system is
hard rebooted which is now taking down our ncd900 terminals on an
all-too regular basis.

Previous admin tells me that the wildcard option in /etc/exports has
been in place for a few years before these problems started occuring.

Problem does not appear to affect xterminals running telnet on the same
network using os.350.

Many thanks for any insights people can provide.

Relevent Info:

(Red Hat Linux 7.1 2.96-98)
Linux version 2.4.7-10smp
clients: ncd900 / os.900
nfs-utils-0.3.1-13

$ cat /etc/exports
/export *(ro)
/home/ncbridge *(ro)
/home/tekxp *(ro)

$ netstat -a | grep lib-ncd5
tcp        0      0 158.104.2.149:42992     lib-ncd5:x11           
ESTABLISHED tcp        0      0 158.104.2.149:42399    
lib-ncd5:x11            ESTABLISHED tcp        0      0
158.104.2.149:42400     lib-ncd5:x11            ESTABLISHED tcp       
0      0 158.104.2.149:42401     lib-ncd5:x11            ESTABLISHED
tcp        0      0 158.104.2.149:42357     lib-ncd5:x11           
ESTABLISHED tcp        0      0 info-1:xfs             
lib-ncd5:1026           ESTABLISHED

$ /usr/sbin/rpcinfo -p localhost
~   program vers proto   port
~    100000    2   tcp    111  portmapper
~    100000    2   udp    111  portmapper
~    100024    1   udp  32768  status
~    100024    1   tcp  32768  status
~    391002    2   tcp  32769  sgi_fam
~    100011    1   udp    701  rquotad
~    100011    2   udp    701  rquotad
~    100011    1   tcp    704  rquotad
~    100011    2   tcp    704  rquotad
~    100005    1   udp  32769  mountd
~    100005    1   tcp  32770  mountd
~    100005    2   udp  32769  mountd
~    100005    2   tcp  32770  mountd
~    100005    3   udp  32769  mountd
~    100005    3   tcp  32770  mountd
~    100003    2   udp   2049  nfs
~    100003    3   udp   2049  nfs
~    100021    1   udp  32770  nlockmgr
~    100021    3   udp  32770  nlockmgr
~    100021    4   udp  32770  nlockmgr

- --
Salvador Peralta
Systems Administrator
Mark O. Hatfield Library
Willamette University
http://www.willamette.edu/~speralta

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQE9wGqMNmBW4SNQemURAi/fAKDrzZVkI242rfmllI/FRiVmLH+AcwCgu454
0ViI3Th+MJfjYdvSgpaHXhg=
=VE4/
-----END PGP SIGNATURE-----





-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
