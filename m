From: Tom Georgoulias <tom.georgoulias@motorola.com>
Subject: linux nfs test results for solaris, linux, hpux clients
Date: Thu, 29 May 2003 09:05:15 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3ED6139B.5040106@motorola.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from motgate5.mot.com ([144.189.100.105])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19LO1w-0006hh-00
	for <nfs@lists.sourceforge.net>; Thu, 29 May 2003 07:05:20 -0700
Received: from il06exr03.mot.com (il06exr03.mot.com [129.188.137.133])
	by motgate5.mot.com (Motorola/Motgate5) with ESMTP id h4TE5IVi014321
	for <nfs@lists.sourceforge.net>; Thu, 29 May 2003 07:05:19 -0700 (MST)
Received: from az33exm31.corp.mot.com (az33exm31.corp.mot.com [10.64.65.145])
	by il06exr03.mot.com (Motorola/il06exr03) with ESMTP id h4TE5Gax022984
	for <nfs@lists.sourceforge.net>; Thu, 29 May 2003 09:05:16 -0500
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

I've read the archives of this list with great interest in trying to 
solve a problem I've seen between solaris clients and a linux NFS 
server.  Performance is still poor between the two and I'm hoping 
someone on this list can give me some pointers on how to correct that. 
Below are the results from a series of tests.  I hope they prove useful 
to others.

Tom
--
Problem:
Users are reporting sluggish behavior when using any of the filesystems 
NFS mounted from a Linux file server.  Further investigation found that 
the problem exists between solaris clients and the linux server.

I tested various NFS configuration settings and client-server and 
combinations by timing the untar operation of a 51MB file when using GNU 
tar

time gtar xf mozilla-sparc-sun-solaris2.8-1.4b.tar

and when reading/writing a 512MB file with dd.

Round One

For comparison, the times it takes to untar the file on the local disk

Local disk times
client		server		time
solaris		local disk	0m5.759s
linux		local disk 	0m0.602s
hpux 		local disk 	0m3.834s

Solaris NFS server
NFS Flags
Solaris serving Solaris
vers=3,proto=tcp,sec=sys,hard,intr,link,symlink,acl,rsize=32768,wsize=32768,retrans=5,timeo=600
Solaris serving Linux
(no nfsstat -m output to use) rw,timeo=600,retrans=5,rsize=8192,wsize=8192
Solaris serving HPUX
vers=2,proto=udp,auth=unix,hard,intr,dynamic,devs,rsize=8192,wsize=8192,retrans=5

System Specs:
Sun E450, Solaris 8 kernel Generic_108528-18, A3500 StorEdge array, RAID 
Manager 6.22.1, VXFS 3.4, trunked quad fast ethernet

Client		Server		Time		NFS	blk	Proto
solaris		solaris		0m15.989s 	3	32k	TCP
linux		solaris		0m12.687s 	3	8k	UDP
hpux		solaris		0m26.990s 	2	8k	UDP

Linux NFS server
System specs:
Dell PowerEdge 2650 (2x24.GHz Xeon, 6GB RAM, root disk sda RAID5 on a 
PERC3/Di), Gigabit ethernet.
PowerVault 220S disk array is attached by a PERC3/DC (w/BIOS v1.72) and 
split backplane with 7 disks on each channel (no hot spare) and 2 
logical drives, sdb & sdc.  Each logical drive has two filesystems, 
split into 300GB and 100GB respectively.

NFS Flags:
Linux serving Solaris:
vers=3,proto=udp,sec=none,hard,intr,link,symlink,rsize=8192,wsize=8192,retrans=5,timeo=11
Linux serving Linux
(no nfsstat -m output to use) rw,timeo=600,retrans=5,rsize=8192,wsize=8192
Linux serving HUPX:
vers=2,proto=udp,auth=unix,hard,intr,dynamic,devs,rsize=8192,wsize=8192,retrans=5

Test Result Matrices
Red Hat kernel 2.4.18-27.7.xbigmem
ext3 data=writeback
export=sync

Client		Server	Time		NFS	blk 	Proto

solaris 	linux	2m47.605s 	3	8k	UDP
solaris 	linux	0m44.793s 	2	8k	UDP
linux		linux	0m15.250s 	3	8k 	UDP
hpux		linux	0m32.364s 	2	8k 	UDP

Red Hat kernel 2.4.18-27.7.xbigmem
ext3 data=writeback
export = async

Client		Server	Time		NFS	blk 	Proto

solaris		linux	0m37.203s 	3	8k 	UDP
solaris		linux	0m17.549s 	2	8k 	UDP
linux		linux	0m6.065s 	3	8k 	UDP
hpux		linux	0m7.373s 	2	8k 	UDP

Comments:

1. We are not the first to document poor performance between Linux NFS 
servers and Solaris clients:
http://marc.theaimsgroup.com/?l=linux-nfs&m=104576641530466&w=2
2. Major differences between the Solaris NFS and Linux NFS servers are 
in the read/write block sizes (32 vs 8) and protocol (TCP vs UDP).
3. NFS over TCP is not standard in the Linux kernel, although patches 
exist that enable it.
4. async provides the biggest boost, but at considerable risk.
5. HPUX uses NFSv2.
6. ext3=journal mode was found to be slower than data=writeback mode 
during prior tests.  Those results are not presented here but I do have 
them.

Round Two

Goal:  Explore increasing the 8k rsize and wsize to 32k, upgrading 
nfs-utils from the 0.3.3 version Red Hat uses on 7.3 to the latest from 
nfs.sourceforge.net.

Testing was done on a standalone PE2650 with similar specs to eclipse0 
used in round one (except it has 2 GB RAM, lacks an attached disk array, 
gigabit ethernet, and doesn't have RAID 5 root disk).  Using this 
standalone system allowed constant reboots and config changes w/o 
affecting production usage, but I'll be the first to admin the 
differences in system specs do not make for apples to apples comparison. 
  In investigating this problem, the linux->solaris file transfer times 
differ by such an degree that getting them reduced by any substantial 
amount is a welcome result.

A custom kernel, 2.4.20-13.7-nfs32k, was built using the Red Hat's 
sources and 2.4.20-13.7-i686-smp config file, with only this change made 
to the file  /usr/src/linux-2.4/include/linux/nfsd/const.h:

NFSSVC_MAXBLKSIZE = 32*1024 (instead of 8*1024)

An nfs-utils-1.0.3-1 RPM was built from the nfs-utils-1.0.3.tar.gz using 
rpmbuild -ta.   The new shell nfs shell script offers the ability to 
tune settings through /etc/sysconfig/nfs.

The HPUX client used in the test was a J6000 running HP-UX 11.00, the 
solaris client was an Ultra 5 running Solaris 9, and the Linux client 
was a homebuilt system running Red Hat 7.3.


ext3=writeback
export=sync
protocol=UDP
nfs-utils-0.3.3-5

Client	2.4.18-27.7.xsmp	2.4.20-13.7smp	2.4.20-13.7-nfs32k (32k)

solaris	6m29.022s		5m16.398s		5m10.682s
linux	0m54.925s		1m0.617s		1m0.937
hpux	2m10.108s		2m23.827s		2m23.346s

ext3=writeback
export=sync
protocol=UDP
nfs-utils-1.0.3-1


Client 	2.4.18-27.7.xsmp 	2.4.20-13.7smp 	2.4.20-13.7-nfs32k (32k)

solaris	6m8.165s		5m40.673s		4m58.887s
linux	0m54.960s		0m54.675s		0m54.583s
hpux	2m31.231s		2m4.462s		2m3.181s


Comments:

1. Enabling  32k block sizes didn't offer much over the default 
2.4.20-13.7smp kernel from Red Hat.  Need to investigate if 32k blocks 
are being used in transfers...
2. Upgrading nfs-utils offered a possible slight performance improvement 
w/o even using the tuning options built into the script.

Round Three

Goal: Why isn't 32k block enabled kernel producing better results?

ext3=writeback
export=sync
protocol=UDP
kernel 2.4.20-13.7-nfs32k (32k blk enabled)
solaris client

Manually mounted exported filesystem to control block sizes.

Requested: mount -o vers=3,proto=udp,rsize=1024,wsize=1024 
eclipse5:/export/nfstest /mnt
/mnt on eclipse5:/export/nfstest 
remote/read/write/setuid/vers=3/proto=udp/rsize=1024/wsize=1024/xattr/dev=3e40251

Requested: mount -o vers=3,proto=udp,rsize=4096,wsize=4096 
eclipse5:/export/nfstest /mnt
Actual: /mnt on eclipse5:/export/nfstest 
remote/read/write/setuid/vers=3/proto=udp/rsize=4096/wsize=4096/xattr/dev=3e40252

Requested: mount -o vers=3,proto=udp,rsize=8192,wsize=8192 
eclipse5:/export/nfstest /mnt
Actual: /mnt on eclipse5:/export/nfstest 
remote/read/write/setuid/vers=3/proto=udp/rsize=8192/wsize=8192/xattr/dev=3e40240

Requested: mount -o vers=3,proto=udp,rsize=32768,wsize=32768 
eclipse5:/export/nfstest /mnt
Actual: /mnt on eclipse5:/export/nfstest 
remote/read/write/setuid/vers=3/proto=udp/rsize=32768/wsize=32768/xattr/dev=3e40244

blk	gtar xf mozilla-sparc-sun-solaris2.8-1.4b.tar

1k	28m17.027s
4k	9m21.745s
8k 	5m21.860s
32k	5m25.239s

blk	dd if=/dev/zero of=testfile bs=16k count=32768
1k	1m58.466s
4k	1m9.550s
8k 	1m3.851s
32k	1m2.341s


blk	dd if=testfile of=/dev/null bs=16k
1k	2m28.614s
4k	1m4.399s
8k 	0m55.388s
32k	0m46.847s


Comments:
Is there anything else that needs to be set to enable 32k blocks?!  It 
doesn't seem to have any real effect.  Need to investigate this further..


Round Four
Goal:  Test tuning aspects in nfs-utils /etc/sysconfig/nfs, namely 
increase in memory limits on input queue (using TUNE_QUEUE="yes")


ext3=writeback
export=sync
protocol=UDP
nfs-utils-1.0.3-1
memory limits on input queue =262144

Client	2.4.20-13.7smp		2.4.20-13.7-nfs32k (32k)

solaris	5m20.016s		4m40.454s
linux	0m54.699s		0m54.676s
hpux	2m7.327s		2m6.008s

Comments:

1. Enabling TUNE_QUEUE="yes" in /etc/sysconfig/nfs and taking 256k as 
the memory limit on the input queue improves performance.
2. Added several companion lines to the startup script thato made 
changes that were originally applied to just rmem_default and rmem_max 
to wmem_default and wmem_max as well.  These changes go into effect only 
if TUNE_QUEUE is enabled.

i.e.
/sbin/sysctl -w net.core.wmem_default=$NFS_QS >/dev/null 2>&1
/sbin/sysctl -w net.core.wmem_max=$NFS_QS >/dev/null 2>&1


Round Five

Time to see what NFS over TCP looks like.

ext3=writeback
export=sync
protocol=TCP
nfs-utils-1.0.3-1
memory limits on input queue =262144

Client	2.4.20-13.7nfstcp32k (32k)

solaris	5m3.401s
linux	0m54.430s
hpux	2m6.208s

Comments:

1. NFS over TCP doesn't buy us a whole lot.  In fact, it was slightly 
worse for solaris.
2. No real change for Linux & HP-UP either.


Round Six

Exploring more options in /etc/sysconfig/nfs and their effect on 
Solaris.  One interesting option is:  MOUNTD_TCP "Don't advertise TCP 
for mount" Perhaps solaris is geting confused by this?

ext3=writeback
export=sync
protocol=TCP
nfs-utils-1.0.3-1
2.4.20-13.7nfs32k

Client	MOUNTD_TCP=no 	NFS_QS=524288

solaris	4m37.912s	4m41.035s

Comments:

1. MOUNTD_TCP didn't make any difference.
2. Increasing input queue produced similar results, but probably helps 
more with many nfsd and clients accesses.

Round Up

 From this set of tests, it appears that the following settings give the 
best performance:
Kernel 2.4.20-13.7 with 32k block support enabled.
nfs-utils-1.0.3 with TUNE_QUEUE=yes & wmem_[default|max] changes
Protocol=UDP
data=writeback

One unresolved issue from these tests is why the 32k block size enabled 
kernel doesn't seem to behave any different from the default kernel with 
8k block support.

The poor performance between solaris clients and linux nfs servers still 
remains.  Despite all of my efforts in the test cases above, the best 
improvement I can manage is 25%.



-------------------------------------------------------
This SF.net email is sponsored by: eBay
Get office equipment for less on eBay!
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
