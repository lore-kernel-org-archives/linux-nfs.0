From: Jeremy Sanders <jss@ast.cam.ac.uk>
Subject: Locking from Tru64
Date: Tue, 4 Feb 2003 15:34:49 +0000 (GMT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.53.0302041525090.22528@xpc1.ast.cam.ac.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rose.csi.cam.ac.uk ([131.111.8.13])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18g56Z-0005Qr-00
	for <nfs@lists.sourceforge.net>; Tue, 04 Feb 2003 07:35:23 -0800
Received: from cass41.ast.cam.ac.uk ([131.111.69.186])
	by rose.csi.cam.ac.uk with esmtp (Exim 4.10)
	id 18g563-0005Of-00
	for nfs@lists.sourceforge.net; Tue, 04 Feb 2003 15:34:51 +0000
Received: from xserv1.ast.cam.ac.uk (IDENT:UBjF2zQn8DbzVx/qQbd5YO3A6v0DWoEO@xserv1.ast.cam.ac.uk [131.111.69.235])
	by cass41.ast.cam.ac.uk (8.12.5+Sun/8.12.5) with ESMTP id h14FYnNS023025
	for <nfs@lists.sourceforge.net>; Tue, 4 Feb 2003 15:34:49 GMT
Received: from xpc1.ast.cam.ac.uk (IDENT:OqdBaRIJQsaAUoe8OhWzxfV86B/WblzL@xpc1.ast.cam.ac.uk [131.111.68.219])
	by xserv1.ast.cam.ac.uk (8.11.6/8.11.6) with ESMTP id h14FYnU20484
	for <nfs@lists.sourceforge.net>; Tue, 4 Feb 2003 15:34:49 GMT
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

Hi,

I don't know whether anyone had any ideas about my last problem? That's
the problem where the linux clients had to be rebooted when the linux
server was.

I have got an additional problem which I don't understand. We're locking
mail spools over NFS from a Tru64 5.1B client machine to Linux
2.4.18-17.7.x (RedHat) server. Using a simple C program which opens the
file, does lockf (fd, F_LOCK, 1)) and then closes it after 10 seconds,
some users are able to lock their mail spool (one seen, actually) and many
users are unable!

The mail spool files:

[root@xserv1 mail]# ls -l rmj jss
-rw-------    1 jss      users      111406 Feb  4 14:55 jss
-rw-------    1 rmj      users        3196 Feb  4 14:48 rmj

[root@xserv1 mail]# ls -ln rmj jss
-rw-------    1 914      15         111406 Feb  4 14:55 jss
-rw-------    1 90       15           3196 Feb  4 14:48 rmj

The tcpdump (here tru64 is the client, linux is the linux server machine,
and server is an IP alias address for linux) traces for locking the mail
spools for each user are:

For rmj where locking works:

15:04:37.123839 tru64.1420724309 > server.nfs: 108 getattr fh Unknown/1
15:04:37.123931 linux.nfs > tru64.1420724309: reply ok 112 (DF)
15:04:37.124128 tru64.1437501525 > server.nfs: 116 lookup fh Unknown/1 "rmj"
15:04:37.124181 linux.nfs > tru64.1437501525: reply ok 232 (DF)
15:04:37.124408 tru64.1454278741 > server.nfs: 112 getattr fh Unknown/1
15:04:37.124467 linux.nfs > tru64.1454278741: reply ok 112 (DF)
15:04:37.124649 tru64.1471055957 > server.nfs: 112 getattr fh Unknown/1
15:04:37.124704 linux.nfs > tru64.1471055957: reply ok 112 (DF)
15:04:37.124887 tru64.1487833173 > server.nfs: 112 getattr fh Unknown/1
15:04:37.124929 linux.nfs > tru64.1487833173: reply ok 112 (DF)
15:04:37.125516 tru64.693 > server.32775:  udp 168 (DF)
15:04:37.125599 linux.32775 > tru64.693:  udp 24 (DF)
15:04:37.125630 linux.794 > tru64.sunrpc:  udp 56 (DF)
15:04:37.125849 tru64.sunrpc > linux.794:  udp 28
15:04:37.125897 linux.799 > tru64.1035:  udp 136 (DF)
15:04:47.126257 tru64.693 > server.32775:  udp 152 (DF)
15:04:47.126361 linux.799 > tru64.1035:  udp 136 (DF)
15:04:47.126371 linux.32775 > tru64.693:  udp 24 (DF)

For jss where locking hangs:

15:12:53.746512 tru64.1840220245 > server.nfs: 108 getattr fh Unknown/1
15:12:53.746607 linux.nfs > tru64.1840220245: reply ok 112 (DF)
15:12:53.746804 tru64.1856997461 > server.nfs: 108 getattr fh Unknown/1
15:12:53.746849 linux.nfs > tru64.1856997461: reply ok 112 (DF)
15:12:53.747041 tru64.1873774677 > server.nfs: 108 getattr fh Unknown/1
15:12:53.747084 linux.nfs > tru64.1873774677: reply ok 112 (DF)
15:12:53.747270 tru64.1890551893 > server.nfs: 116 lookup fh Unknown/1 "jss"
15:12:53.747330 linux.nfs > tru64.1890551893: reply ok 232 (DF)
15:12:53.747561 tru64.1907329109 > server.nfs: 112 getattr fh Unknown/1
15:12:53.747604 linux.nfs > tru64.1907329109: reply ok 112 (DF)
15:12:53.747783 tru64.1924106325 > server.nfs: 112 getattr fh Unknown/1
15:12:53.747837 linux.nfs > tru64.1924106325: reply ok 112 (DF)
15:12:53.748014 tru64.1940883541 > server.nfs: 112 getattr fh Unknown/1
15:12:53.748068 linux.nfs > tru64.1940883541: reply ok 112 (DF)
15:12:53.748687 tru64.693 > server.32775:  udp 168 (DF)
15:12:53.749174 linux.32775 > tru64.693:  udp 24 (DF)
15:12:53.749186 linux.796 > tru64.sunrpc:  udp 56 (DF)
15:12:53.749414 tru64.sunrpc > linux.796:  udp 28
15:12:53.749443 linux.797 > tru64.1035:  udp 92 (DF)
15:12:54.758566 tru64.693 > server.32775:  udp 168 (DF)
15:12:54.758649 linux.797 > tru64.1035:  udp 92 (DF)
15:12:54.758658 linux.32775 > tru64.693:  udp 24 (DF)
15:12:55.764532 tru64.693 > server.32775:  udp 168 (DF)
15:12:55.764613 linux.797 > tru64.1035:  udp 92 (DF)
15:12:55.764623 linux.32775 > tru64.693:  udp 24 (DF)
15:12:56.770309 tru64.693 > server.32775:  udp 168 (DF)
15:12:56.770371 linux.797 > tru64.1035:  udp 92 (DF)
15:12:56.770378 linux.32775 > tru64.693:  udp 24 (DF)
15:12:57.774218 tru64.693 > server.32775:  udp 168 (DF)
15:12:57.774290 linux.797 > tru64.1035:  udp 92 (DF)
15:12:57.774299 linux.32775 > tru64.693:  udp 24 (DF)
15:12:58.782025 tru64.693 > server.32775:  udp 168 (DF)
15:12:58.782102 linux.797 > tru64.1035:  udp 92 (DF)
15:12:58.782111 linux.32775 > tru64.693:  udp 24 (DF)
15:12:59.787892 tru64.693 > server.32775:  udp 168 (DF)
15:12:59.787967 linux.797 > tru64.1035:  udp 92 (DF)
15:12:59.787974 linux.32775 > tru64.693:  udp 24 (DF)
15:13:00.786273 tru64.693 > server.32775:  udp 160 (DF)
15:13:00.786336 linux.797 > tru64.1035:  udp 92 (DF)
15:13:00.786345 linux.32775 > tru64.693:  udp 24 (DF)
[ carries on like this ]

There doesn't appear to be anything on the two accounts which can cause
the difference. Both users belong to the same groups (specifically users).

Any ideas? Exactly the same thing is also seen using a Tru64 4.0F machine
as the client.

Thanks very much

Jeremy

-- 
Jeremy Sanders <jss@ast.cam.ac.uk>   http://www-xray.ast.cam.ac.uk/~jss/
X-Ray Group, Institute of Astronomy, University of Cambridge, UK.
Public Key Server PGP Key ID: E1AAE053


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
