From: "Larry Sendlosky" <Larry.Sendlosky@storigen.com>
Subject: RE: ~2.4.20-pre3 -> 2.4.21 :  nfs client read performance "broken"
Date: Wed, 2 Jul 2003 17:26:03 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <7BFCE5F1EF28D64198522688F5449D5A01FF2AF8@xchangeserver2.storigen.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [65.193.106.66] (helo=xchangeserver2.storigen.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Xp7C-0004UX-00
	for <nfs@lists.sourceforge.net>; Wed, 02 Jul 2003 14:26:10 -0700
To: "George Georgalis" <george@galis.org>
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

Hi George,

Thanks for the nudge.  The "problem" turned out to
be too small of a output socket queue size (wmem_default, wmem_max)
for nfsd on the server. The patchset that seemed to break
the nfs client caused the client to have more nfs reads in flight at the
same time which in turn put more load on nfsd on the server causing it =
to
do more frequent socket writes. The "too small" socket size caused
dropped outbound udp packets which caused retransmits on the client. =
Once I set
wmem_default and wmem_max to 256K on the server,
the "problem" went away and I actually got slightly better single stream
performance than before the patchset. That fact that changing the client
made the problem appear made me ignore the server until Chuck suggested
changing the socket parameters. Chuck and Trond were a big help.

larry



-----Original Message-----
From: George Georgalis [mailto:george@galis.org]
Sent: Wednesday, July 02, 2003 3:53 PM
To: Larry Sendlosky
Subject: Re: ~2.4.20-pre3 -> 2.4.21 : nfs client read performance
"broken"


I don't see any followups, did you get any?

// George



On Fri, Jun 27, 2003 at 01:11:59PM -0400, Larry Sendlosky wrote:
>We recently started using 2.4.21, a move up from 2.4.18. Somebody
>in the group brought to my attention a nfs client performance
>problem using 2.4.21 vs 2.4.18. Single client read throughput can be
>cut in half!
>
>I've narrowed down the problem to the "congestion
>avoidance" patches that went into RPC, specifically changesets
>1.555.49.11, .12, and .13. A kernel built with 1.555.48.10
>works just fine, and everything after exhibits the performance
>problem I will describe below. Building a kernel from the RH9
>CD sources shows the same problem.
>
>I've searched the mailing lists and google'd and cannot find any
>other mention of this problem, so I'm hoping that I've missed something
>obvious because nobody else has complained.
>
>Client: Dell 600 connected to 100Mb switch. 512MB memory.
>Server: Tyan 2510 running 2.4.18 connected to same 100Mb switch. 1GB =
memory.
>
>The 100MB switch has 5 ports with 2 other basically inactive systems
>in my office.
>
>Performance summary:
>
>Client running "pre-congestion control" RPC (circa 2.4.20-pre3)
>can read 50MB of file data in about 5 seconds realtime with
>each 256K buffer read taking less than 40ms with 0 RPC client =
retransmits.
>
>Client running 2.4.21 can read 50MB of file data in about 10 seconds
>realtime with 2/3 of the 256K buffer reads taking greater than 40ms =
with about
>300 RPC client retransmits.
>
>The only conclusion I can draw from my data is that the "congestion =
avoidance"
>code is fundamentally broken because it can't handle the degenerate
>case where there is *no* congestion.=20
>
>Extra info:
>
>In the RPC code, I tried treating UDP and TCP the same wrt the
>"nocongestion control" flag, .i.e. in xprt_setup, in xprt.c
>
>		       xprt->cwnd =3D RPC_MAXCWND;
>		       xprt->nocong =3D 1;
>
>for both protocols. My intend was to "neuter" the congestion avoidance
>code. Well, the client reads never finished.
>
>I also did some "spot" instrumentation and noticed that the new
>code "ratchets" down the RPC timeout values as part of the algorithm.
>In my test case, the timer gets down to 40ms and timeouts start to
>occur and it continues to get some timeouts using that value =
thereafter.
>This causes the retransmits. So, in another attempt to "neuter" the =
code, I=20
>changed rpc_calc_rto in sunrpc/timer.c to never return a timer value
>less than 100ms. I know all my reads happen much faster. However, with
>that change, I see just as many timeouts of 100ms timers! And, many
>I/O completion times go above 100ms. This is one of the reasons why I
>think the code is broken.=20
>
>
>Performance data:
>
>Below shows the actual data I was referring to above. The 'workq' =
program
>is an in-house tool that we use to "beat on" disks and filesystems.
>'workq -r -t1 -f10 -S5M -s256k -dv' means use 1 thread to read 5MB
>from 10 files using a 256k buffer. The files already exist.
>
>Thanks for any help,
>
>larry
>
>
>[root@johny2 root]# uname -a
>Linux pooperscooper 2.4.20-pre3 #2 SMP Fri Jun 27 09:35:01 EDT 2003 =
i686 n
>
>[root@pooperscooper root]# !mount   =20
>mount -t nfs -o rsize=3D8192,wsize=3D8192 lws02:/var/data /var/data
>
>[root@pooperscooper root]# cat /proc/mounts
>rootfs / rootfs rw 0 0
>/dev/root / ext3 rw 0 0
>/proc /proc proc rw 0 0
>/dev/md1 /boot ext3 rw 0 0
>/dev/md7 /var ext3 rw 0 0
>none /dev/pts devpts rw 0 0
>none /dev/shm tmpfs rw 0 0
>/dev/md10 /.metadata ext3 rw,noatime 0 0
>lws02:/var/data /var/data nfs =
rw,v3,rsize=3D8192,wsize=3D8192,hard,udp,lock,addr=3Dlw0
>
>[root@pooperscooper root]# nfsstat -c
>Client rpc stats:
>calls      retrans    authrefrsh
>3          0          0      =20
>Client nfs v2:
>null       getattr    setattr    root       lookup     readlink  =20
>0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>read       wrcache    write      create     remove     rename    =20
>0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>link       symlink    mkdir      rmdir      readdir    fsstat    =20
>0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>
>Client nfs v3:
>null       getattr    setattr    lookup     access     readlink  =20
>0       0% 1      33% 0       0% 0       0% 0       0% 0       0%=20
>read       write      create     mkdir      symlink    mknod     =20
>0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>remove     rmdir      rename     link       readdir    readdirplus
>0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>fsstat     fsinfo     pathconf   commit    =20
>1      33% 1      33% 0       0% 0       0%=20
>
>[root@pooperscooper root]# cd /var
>[root@pooperscooper var]# ls -l data/fifty.dat=20
>-rw-r--r--    1 root     root     52428800 Jun 24 16:25 data/fifty.dat
>
>[root@pooperscooper var]# time cat data/fifty.dat > /dev/null
>
>real    0m4.820s
>user    0m0.010s
>sys     0m0.120s
>
>
>[root@pooperscooper var]# nfsstat -c
>Client rpc stats:
>calls      retrans    authrefrsh
>12736      0          0      =20
>Client nfs v2:
>null       getattr    setattr    root       lookup     readlink  =20
>0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>read       wrcache    write      create     remove     rename    =20
>0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>link       symlink    mkdir      rmdir      readdir    fsstat    =20
>0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>
>Client nfs v3:
>null       getattr    setattr    lookup     access     readlink  =20
>0       0% 6       0% 0       0% 1       0% 9       0% 0       0%=20
>read       write      create     mkdir      symlink    mknod     =20
>6400   99% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>remove     rmdir      rename     link       readdir    readdirplus
>0       0% 0       0% 0       0% 0       0% 1       0% 0       0%=20
>fsstat     fsinfo     pathconf   commit    =20
>1       0% 1       0% 0       0% 0       0%=20
>
>[root@pooperscooper var]# !umount
>umount /var/data
>
>[root@pooperscooper var]# !mount
>mount -t nfs -o rsize=3D8192,wsize=3D8192 lws02:/var/data /var/data
>
>[root@pooperscooper var]# nfsstat -c
>Client rpc stats:
>calls      retrans    authrefrsh
>12739      0          0      =20
>Client nfs v2:
>null       getattr    setattr    root       lookup     readlink  =20
>0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>read       wrcache    write      create     remove     rename    =20
>0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>link       symlink    mkdir      rmdir      readdir    fsstat    =20
>0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>
>Client nfs v3:
>null       getattr    setattr    lookup     access     readlink  =20
>0       0% 7       0% 0       0% 1       0% 9       0% 0       0%=20
>read       write      create     mkdir      symlink    mknod     =20
>6400   99% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>remove     rmdir      rename     link       readdir    readdirplus
>0       0% 0       0% 0       0% 0       0% 1       0% 0       0%=20
>fsstat     fsinfo     pathconf   commit    =20
>2       0% 2       0% 0       0% 0       0%=20
>
>[root@pooperscooper var]# ls -l data                              =20
>total 102576
>-rwxr-xr-x    1 root     root      5242880 Jun 23 11:15 disk0.dat
>-rwxr-xr-x    1 root     root      5242880 Jun 23 11:15 disk1.dat
>-rwxr-xr-x    1 root     root      5242880 Jun 23 11:15 disk2.dat
>-rwxr-xr-x    1 root     root      5242880 Jun 23 11:15 disk3.dat
>-rwxr-xr-x    1 root     root      5242880 Jun 23 11:15 disk4.dat
>-rwxr-xr-x    1 root     root      5242880 Jun 23 11:15 disk5.dat
>-rwxr-xr-x    1 root     root      5242880 Jun 23 11:15 disk6.dat
>-rwxr-xr-x    1 root     root      5242880 Jun 23 11:15 disk7.dat
>-rwxr-xr-x    1 root     root      5242880 Jun 23 11:15 disk8.dat
>-rwxr-xr-x    1 root     root      5242880 Jun 23 11:15 disk9.dat
>-rw-r--r--    1 root     root     52428800 Jun 24 16:25 fifty.dat
>
>[root@pooperscooper var]# /usr/local/bin/workq -r -t1 -f10 -S5M -s256k =
-dv
>
>Copyright (c) 2000-2003, Storigen Systems, Inc.
>All rights reserved.
>
> OP  THDS IOSZ FILS FSIZ BOFF FOFF BWDTH   CPUT  CLOCKT %CPUMbs CSWIT =
FAULT
>---- ---- ---- ---- ---- ---- ---- ----- ------- ------ ------- ----- =
-----
>READ    1  256   10    5    0    0 010.3 000.130 0004.9 0.01625     0   =
  7
> 10ms    =3D          0
> 20ms    =3D          4
> 30ms    =3D        192
> 40ms    =3D          4
> 50ms    =3D          0
> 60ms    =3D          0
> 70ms    =3D          0
> 80ms    =3D          0
> 90ms    =3D          0
> 100ms   =3D          0
> 200ms   =3D          0
> 300ms   =3D          0
> 400ms   =3D          0
> 500ms   =3D          0
> 600ms   =3D          0
> 700ms   =3D          0
> 800ms   =3D          0
> 900ms   =3D          0
> 1000ms  =3D          0
> >1s     =3D          0
> all_ios =3D        200
> min     =3D      0.012
> max     =3D      0.036
>
>[root@pooperscooper var]# nfsstat -c
>Client rpc stats:
>calls      retrans    authrefrsh
>25395      0          0      =20
>Client nfs v2:
>null       getattr    setattr    root       lookup     readlink  =20
>0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>read       wrcache    write      create     remove     rename    =20
>0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>link       symlink    mkdir      rmdir      readdir    fsstat    =20
>0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>
>Client nfs v3:
>null       getattr    setattr    lookup     access     readlink  =20
>0       0% 18      0% 0       0% 12      0% 42      0% 0       0%=20
>read       write      create     mkdir      symlink    mknod     =20
>12800  99% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>remove     rmdir      rename     link       readdir    readdirplus
>0       0% 0       0% 0       0% 0       0% 2       0% 0       0%=20
>fsstat     fsinfo     pathconf   commit    =20
>2       0% 2       0% 0       0% 0       0%=20
>
>[root@pooperscooper var]#=20
>
>************************************************************************=
*******
>Bad performance
>************************************************************************=
******
>
>[root@pooperscooper root]# uname -a
>
>Linux pooperscooper 2.4.21 #1 SMP Tue Jun 24 08:40:50 EDT 2003 in
>
>[root@pooperscooper root]# cd /var
>
>[root@pooperscooper var]# !mount
>mount -t nfs -o rsize=3D8192,wsize=3D8192 lws02:/var/data /var/data
>
>[root@pooperscooper var]# cat /proc/mounts
>rootfs / rootfs rw 0 0
>/dev/root / ext3 rw 0 0
>/proc /proc proc rw 0 0
>/dev/md1 /boot ext3 rw 0 0
>/dev/md7 /var ext3 rw 0 0
>none /dev/pts devpts rw 0 0
>none /dev/shm tmpfs rw 0 0
>/dev/md10 /.metadata ext3 rw,noatime 0 0
>lws02:/var/data /var/data nfs =
rw,v3,rsize=3D8192,wsize=3D8192,hard,udp,lock,addr=3Dlw0
>
>[root@pooperscooper var]# nfsstat -c
>Client rpc stats:
>calls      retrans    authrefrsh
>3          0          0      =20
>Client nfs v2:
>null       getattr    setattr    root       lookup     readlink  =20
>0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>read       wrcache    write      create     remove     rename    =20
>0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>link       symlink    mkdir      rmdir      readdir    fsstat    =20
>0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>
>Client nfs v3:
>null       getattr    setattr    lookup     access     readlink  =20
>0       0% 1      33% 0       0% 0       0% 0       0% 0       0%=20
>read       write      create     mkdir      symlink    mknod     =20
>0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>remove     rmdir      rename     link       readdir    readdirplus
>0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>fsstat     fsinfo     pathconf   commit    =20
>1      33% 1      33% 0       0% 0       0%=20
>
>[root@pooperscooper var]# time cat data/fifty.dat > /dev/null=20
>
>real    0m10.183s
>user    0m0.000s
>sys     0m0.030s
>
>[root@pooperscooper var]# nfsstat -c
>Client rpc stats:
>calls      retrans    authrefrsh
>6412       304        0      =20
>Client nfs v2:
>null       getattr    setattr    root       lookup     readlink  =20
>0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>read       wrcache    write      create     remove     rename    =20
>0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>link       symlink    mkdir      rmdir      readdir    fsstat    =20
>0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>
>Client nfs v3:
>null       getattr    setattr    lookup     access     readlink  =20
>0       0% 4       0% 0       0% 1       0% 4       0% 0       0%=20
>read       write      create     mkdir      symlink    mknod     =20
>6400   99% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>remove     rmdir      rename     link       readdir    readdirplus
>0       0% 0       0% 0       0% 0       0% 1       0% 0       0%=20
>fsstat     fsinfo     pathconf   commit    =20
>1       0% 1       0% 0       0% 0       0%=20
>
>[root@pooperscooper var]# !umount=20
>umount /var/data
>
>[root@pooperscooper var]# !mount
>mount -t nfs -o rsize=3D8192,wsize=3D8192 lws02:/var/data /var/data
>
>[root@pooperscooper var]# nfsstat -c
>Client rpc stats:
>calls      retrans    authrefrsh
>6415       304        0      =20
>Client nfs v2:
>null       getattr    setattr    root       lookup     readlink  =20
>0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>read       wrcache    write      create     remove     rename    =20
>0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>link       symlink    mkdir      rmdir      readdir    fsstat    =20
>0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>
>Client nfs v3:
>null       getattr    setattr    lookup     access     readlink  =20
>0       0% 5       0% 0       0% 1       0% 4       0% 0       0%=20
>read       write      create     mkdir      symlink    mknod     =20
>6400   99% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>remove     rmdir      rename     link       readdir    readdirplus
>0       0% 0       0% 0       0% 0       0% 1       0% 0       0%=20
>fsstat     fsinfo     pathconf   commit    =20
>2       0% 2       0% 0       0% 0       0%=20
>
>[root@pooperscooper var]# /usr/local/bin/workq -r -t1 -f10 -S5M -s256k =
-dv
>
>Copyright (c) 2000-2003, Storigen Systems, Inc.
>All rights reserved.
>
> OP  THDS IOSZ FILS FSIZ BOFF FOFF BWDTH   CPUT  CLOCKT %CPUMbs CSWIT =
FAULT
>---- ---- ---- ---- ---- ---- ---- ----- ------- ------ ------- ----- =
-----
>READ    1  256   10    5    0    0 004.6 000.100 0011.0 0.01250     0   =
  7
> 10ms    =3D          0
> 20ms    =3D         61
> 30ms    =3D          4
> 40ms    =3D          0
> 50ms    =3D         29
> 60ms    =3D         24
> 70ms    =3D          0
> 80ms    =3D         20
> 90ms    =3D         56
> 100ms   =3D          4
> 200ms   =3D          1
> 300ms   =3D          0
> 400ms   =3D          0
> 500ms   =3D          1
> 600ms   =3D          0
> 700ms   =3D          0
> 800ms   =3D          0
> 900ms   =3D          0
> 1000ms  =3D          0
> >1s     =3D          0
> all_ios =3D        200
> min     =3D      0.012
> max     =3D       0.46
>
>[root@pooperscooper var]# nfsstat -c
>Client rpc stats:
>calls      retrans    authrefrsh
>12847      644        0      =20
>Client nfs v2:
>null       getattr    setattr    root       lookup     readlink  =20
>0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>read       wrcache    write      create     remove     rename    =20
>0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>link       symlink    mkdir      rmdir      readdir    fsstat    =20
>0       0% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>
>Client nfs v3:
>null       getattr    setattr    lookup     access     readlink  =20
>0       0% 5       0% 0       0% 11      0% 25      0% 0       0%=20
>read       write      create     mkdir      symlink    mknod     =20
>12800  99% 0       0% 0       0% 0       0% 0       0% 0       0%=20
>remove     rmdir      rename     link       readdir    readdirplus
>0       0% 0       0% 0       0% 0       0% 2       0% 0       0%=20
>fsstat     fsinfo     pathconf   commit    =20
>2       0% 2       0% 0       0% 0       0%=20
>-
>To unsubscribe from this list: send the line "unsubscribe linux-kernel" =
in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>Please read the FAQ at  http://www.tux.org/lkml/
>

--=20
GEORGE GEORGALIS, System Admin/Architect    cell: 646-331-2027    =
<IXOYE><
Security Services, Web, Mail,            mailto:george@galis.org=20
Multimedia, DB, DNS and Metrics.       http://www.galis.org/george=20




-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
