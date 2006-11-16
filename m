From: "Ulrich Windl" <ulrich.windl@rz.uni-regensburg.de>
Subject: Problems with SLES10 (2.6.16.21-0.25-xen) NFS client: no
	locks, hanging mounts
Date: Thu, 16 Nov 2006 11:54:07 +0100
Message-ID: <455C515D.12136.104B8B29@Ulrich.Windl.rkdvmks1.ngate.uni-regensburg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GketV-0006lP-Cx
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 02:54:57 -0800
Received: from rrzmta2.rz.uni-regensburg.de ([132.199.1.17])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GketV-0005pC-63
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 02:54:58 -0800
Received: from rrzmta2.rz.uni-regensburg.de (localhost [127.0.0.1])
	by localhost (Postfix) with SMTP id 215666D46C
	for <nfs@lists.sourceforge.net>; Thu, 16 Nov 2006 11:54:52 +0100 (CET)
Received: from mailgate.dvm.klinik.uni-regensburg.de
	(kgate2.klinik.uni-regensburg.de [132.199.176.19])
	by rrzmta2.rz.uni-regensburg.de (Postfix) with ESMTP id 19FAB6D449
	for <nfs@lists.sourceforge.net>; Thu, 16 Nov 2006 11:54:52 +0100 (CET)
Received: from rkdvmks1.ngate.uni-regensburg.de
	(rkdvmks1.dvm.klinik.uni-regensburg.de [132.199.176.1])
	by mailgate.dvm.klinik.uni-regensburg.de
	(8.12.11.20060308/8.12.11/20060824MT-1) with ESMTP id kAGAsOAR020146
	for <nfs@lists.sourceforge.net>; Thu, 16 Nov 2006 11:54:43 +0100
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi,

(I'm not subscribed to this list)
When I had a temporary need for more diskspace on a XEN VM running SLES10 
(x86_64), I tried to mount an NFS filesystem to Linux, but I had problems:

1) When Solaris 9 (SPARC) was the server (server1), mount succeeded, but locking 
failed:

Application (SuSE "build") said:
initializing rpm db...
warning: waiting for transaction lock on /var/lib/rpm/__db.000
error: can't create transaction lock on /var/lib/rpm/__db.000

/var/log/messages said:
Nov 16 10:27:31 nfs-client kernel: lockd: failed to monitor server1
Nov 16 10:27:31 nfs-client kernel: lockd/statd: failed to create 
/var/lib/nfs/sm/server1: err=-2

2) When trying to use SLES9 (i386, Kernel 2.6.5-7.282-default) as NFS server 
(server2), mount on the client hung hard (only kill -9 did work). The rpc.mountd 
was waiting for data while the client hung:

strace:
open("/proc/fs/nfsd/filehandle", O_RDWR) = 10
fstat64(10, {st_mode=S_IFREG|0600, st_size=0, ...}) = 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 
0x40019000
write(10, "*.dvm.our-domain,r"..., 85) = 85
read(10, "\\x0100000600fd000b020000006e2200"..., 4096) = 75
close(10)                               = 0
munmap(0x40019000, 4096)                = 0
write(8, "\200\0\0Pb\376%\321\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 84) = 84
select(1024, [3 4 5 6 7 8], NULL, NULL, NULL) = 1 (in [8])
poll([{fd=8, events=POLLIN, revents=POLLIN}], 1, 35000) = 1
read(8, "", 4000)                       = 0
close(8)                                = 0
select(1024, [3 4 5 6 7], NULL, NULL, NULL <unfinished ...>

Tracing the network traffic, I found this final data exchange:

11:29:43.869678 IP (tos 0x0, ttl  64, id 50629, offset 0, flags [DF], proto: TCP 
(6), length: 200) nfs-client.dvm.our-domain.2253585828 > server2.dvm.our-
domain.nfs: 148 fsinfo fh 
Unknown/0100000600FD000B020000006E22000002000000000000000200000001000000
11:29:43.909121 IP (tos 0x0, ttl  64, id 29964, offset 0, flags [DF], proto: TCP 
(6), length: 52) server2.dvm.our-domain.nfs > nfs-client.dvm.our-domain.1023: ., 
cksum 0x655b (correct), ack 542460337 win 6432 <nop,nop,timestamp 470378359 
19011966>

Any helpful instructions?
Note: There a some hints that the locking code in the NFS client may have a 
problem, because I had a similar complaint for an NFS-mounted /home from HP-UX 
11.11 (Shell hangs during login)

Regards,
Ulrich


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
