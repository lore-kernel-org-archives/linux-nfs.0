From: Orion Poplawski <orion@cora.nwra.com>
Subject: rpc.statd dies with SIGPIPE with DEC/OSF client
Date: Tue, 11 Feb 2003 10:02:11 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <b2ba6i$iok$1@main.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from main.gmane.org ([80.91.224.249])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18idyU-0002aL-00
	for <nfs@lists.sourceforge.net>; Tue, 11 Feb 2003 09:13:39 -0800
Received: from root by main.gmane.org with local (Exim 3.35 #1 (Debian))
	id 18idvc-0005tY-00
	for <nfs@lists.sourceforge.net>; Tue, 11 Feb 2003 18:10:40 +0100
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

Linux server: Redhat 7.3, kernel 2.4.18-19.7.x, rpc.statd ver 0.3.3

When I reboot one of our Dec/alpha boxes (silverheels), rpc.statd 
crashes with sigpipe.  I believe that crash happens as the client comes 
back up.

Linux server is <localnet>.8
OSF Client is <localnet>.49, silverheels

The server mounts the home directory for a user from silverheels:
silverheels:/export/home/alexand on /home/alexand type nfs

The OSF client mounts /var/spool/mail from the linux server.

Any help would be greatly appreciated.

TIA,

  Orion Poplawski


strace on rpc.statd:

19253 select(1024, [4 5 6], NULL, NULL, NULL) = 1 (in [6])
19253 accept(6, {sin_family=AF_INET, sin_port=htons(979), 
sin_addr=inet_addr("<localnet>.49")}}, [16]) = 7 
                                                   19253 select(1024, [4 
5 6 7], NULL, NULL, NULL) = 1 (in [7]) 
19253 poll([{fd=7, events=POLLIN, revents=POLLIN}], 1, 35000) = 1 
                   19253 read(7, 
"\200\0\0T\337\37n\1\0\0\0\0\0\0\0\2\0\1\206\270\0\0\0\1"..., 4000) = 
152   <-name resolution snip->
19253 write(7, 
"\200\0\0\30\337\37n\1\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 28) = 28 
    <-name resolution snip->
19253 write(7, 
"\200\0\0\30\340\37n\1\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 28) = -1 EPIP
E (Broken pipe)
19253 --- SIGPIPE (Broken pipe) ---

tcp trace:

<syn/ack snip>

558 09:27:15.203142 <localnet>.49 -> <localnet>.8 STAT V1 NOTIFY Call 
XID 0xdf1f6e01

0000  00 20 e0 60 0b cd 00 00 f8 71 62 a4 08 00 45 00   . .`.....qb...E.
0010  00 80 30 ea 40 00 3c 06 09 fe 41 ab c0 31 41 ab   ..0.@.<...A..1A.
0020  c0 08 03 d3 dd 69 01 2f fa 6e 15 01 73 33 50 18   .....i./.n..s3P.
0030  83 2c 9e b5 00 00 80 00 00 54 df 1f 6e 01 00 00   .,.......T..n...
0040  00 00 00 00 00 02 00 01 86 b8 00 00 00 01 00 00   ................
0050  00 06 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0060  00 00 00 00 00 21 73 69 6c 76 65 72 68 65 65 6c   .....!silverheel
0070  73 2e 63 6f 6c 6f 72 61 64 6f 2d 72 65 73 65 61   s.colorado-resea
0080  72 63 68 2e 63 6f 6d 00 00 00 00 00 00 4f         rch.com......O

559 09:27:15.203210 <localnet>.8 -> <localnet>.49 TCP 56681 > 979 [ACK] 
Seq=352416563 Ack=19921606 Win=5840 Len=0

0000  00 00 f8 71 62 a4 00 20 e0 60 0b cd 08 00 45 00   ...qb.. .`....E.
0010  00 28 bf bd 40 00 40 06 77 82 41 ab c0 08 41 ab   .(..@.@.w.A...A.
0020  c0 31 dd 69 03 d3 15 01 73 33 01 2f fa c6 50 10   .1.i....s3./..P.
0030  16 d0 30 0d 00 00                                 ..0...

560 09:27:15.203146 <localnet>.49 -> <localnet>.8 STAT V1 NOTIFY Call 
XID 0xe01f6e01

0000  00 20 e0 60 0b cd 00 00 f8 71 62 a4 08 00 45 00   . .`.....qb...E.
0010  00 68 30 eb 40 00 3c 06 0a 15 41 ab c0 31 41 ab   .h0.@.<...A..1A.
0020  c0 08 03 d3 dd 69 01 2f fa c6 15 01 73 33 50 19   .....i./....s3P.
0030  83 2c 4e 42 00 00 80 00 00 3c e0 1f 6e 01 00 00   .,NB.....<..n...
0040  00 00 00 00 00 02 00 01 86 b8 00 00 00 01 00 00   ................
0050  00 06 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0060  00 00 00 00 00 09 6c 6f 63 61 6c 68 6f 73 74 00   ......localhost.
0070  00 00 00 00 00 4f                                 .....O

561 09:27:15.241399 <localnet>.8 -> <localnet>.49 TCP 56681 > 979 [ACK] 
Seq=352416563 Ack=19921671 Win=5840 Len=0

0000  00 00 f8 71 62 a4 00 20 e0 60 0b cd 08 00 45 00   ...qb.. .`....E.
0010  00 28 bf be 40 00 40 06 77 81 41 ab c0 08 41 ab   .(..@.@.w.A...A.
0020  c0 31 dd 69 03 d3 15 01 73 33 01 2f fb 07 50 10   .1.i....s3./..P.
0030  16 d0 2f cc 00 00                                 ../...

562 09:27:15.341256 <localnet>.8 -> <localnet>.49 STAT V1 NOTIFY Reply 
XID 0xdf1f6e01

0000  00 00 f8 71 62 a4 00 20 e0 60 0b cd 08 00 45 00   ...qb.. .`....E.
0010  00 44 bf bf 40 00 40 06 77 64 41 ab c0 08 41 ab   .D..@.@.wdA...A.
0020  c0 31 dd 69 03 d3 15 01 73 33 01 2f fb 07 50 18   .1.i....s3./..P.
0030  16 d0 62 6d 00 00 80 00 00 18 df 1f 6e 01 00 00   ..bm........n...
0040  00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0050  00 00                                             ..

563 09:27:15.341394 <localnet>.49 -> <localnet>.8 TCP 979 > 56681 [RST] 
Seq=19921671 Ack=0 Win=0 Len=0

0000  00 20 e0 60 0b cd 00 00 f8 71 62 a4 08 00 45 00   . .`.....qb...E.
0010  00 28 31 18 00 00 3c 06 4a 28 41 ab c0 31 41 ab   .(1...<.J(A..1A.
0020  c0 08 03 d3 dd 69 01 2f fb 07 00 00 00 00 50 04   .....i./......P.
0030  00 00 ce dc 00 00 00 00 00 00 00 00               ............




-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
