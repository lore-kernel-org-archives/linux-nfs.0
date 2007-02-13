From: Norman Weathers <norman.r.weathers@conocophillips.com>
Subject: Broken nfsd in recent kernels
Date: Mon, 12 Feb 2007 18:26:08 -0600
Message-ID: <1171326368.8065.36.camel@hoeplx2923>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HGlUt-0001UI-Ci
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 16:26:17 -0800
Received: from mailman1.ppco.com ([138.32.33.10])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1HGlUu-00027u-MX
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 16:26:17 -0800
Received: from bvlextrd2.conoco.net (bvlextrd2.conoco.net [158.139.203.93])
	by mailman1.ppco.com (Switch-3.1.8/Switch-3.1.7) with ESMTP id
	l1D0Q9ZB007187
	for <nfs@lists.sourceforge.net>; Mon, 12 Feb 2007 18:26:09 -0600
Received: from bvlexbh2.conoco.net (bvlexbh2.conoco.net [138.32.45.42])
	by mail1.ppco.com (Switch-3.1.8/Switch-3.1.7) with ESMTP id
	l1D0Q9ZC010512
	for <nfs@lists.sourceforge.net>; Mon, 12 Feb 2007 18:26:09 -0600
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

Hello,

I have noticed, at least in our Fedora 6 test case, that recent kernels
(2.6.18 and 2.6.19) that there appears to be a "read hell" issue.  Has
anyone else seen this?

For instance, using iozone, during a write case (32 kb blocks) to a Sun
x4100 running Fedora Core 6 and the Fedora core kernels, I get decent
throughput.  But, as soon as the test goes from write to rewrite, I see
a large amount of read activity (via iostat) on the NFS server.  It
looks like 4kb read blocks.

The host nodes involved have the following configuration:

uname -a
Linux hoepld15 2.6.18-1.2868.fc6 #1 SMP Fri Dec 15 17:29:48 EST 2006
x86_64 x86_64 x86_64 GNU/Linux

free:
             total       used       free     shared    buffers
cached
Mem:       8044904    7968452      76452          0      17592
7489888
-/+ buffers/cache:     460972    7583932
Swap:      4192956        156    4192800

cat /proc/cpuinfo
processor       : 0
vendor_id       : AuthenticAMD
cpu family      : 15
model           : 33
model name      : Dual Core AMD Opteron(tm) Processor 280
stepping        : 2
cpu MHz         : 2400.000
cache size      : 1024 KB
physical id     : 0
siblings        : 2
core id         : 0
cpu cores       : 2
fpu             : yes
fpu_exception   : yes
cpuid level     : 1
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext
fxsr_opt lm 3dnowext 3dnow pni lahf_lm cmp_legacy
bogomips        : 4789.93
TLB size        : 1024 4K pages
clflush size    : 64
cache_alignment : 64
address sizes   : 40 bits physical, 48 bits virtual
power management: ts fid vid ttp

processor       : 1
vendor_id       : AuthenticAMD
cpu family      : 15
model           : 33
model name      : Dual Core AMD Opteron(tm) Processor 280
stepping        : 2
cpu MHz         : 2400.000
cache size      : 1024 KB
physical id     : 0
siblings        : 2
core id         : 1
cpu cores       : 2
fpu             : yes
fpu_exception   : yes
cpuid level     : 1
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext
fxsr_opt lm 3dnowext 3dnow pni lahf_lm cmp_legacy
bogomips        : 4689.98
TLB size        : 1024 4K pages
clflush size    : 64
cache_alignment : 64
address sizes   : 40 bits physical, 48 bits virtual
power management: ts fid vid ttp

processor       : 2
vendor_id       : AuthenticAMD
cpu family      : 15
model           : 33
model name      : Dual Core AMD Opteron(tm) Processor 280
stepping        : 2
cpu MHz         : 2400.000
cache size      : 1024 KB
physical id     : 1
siblings        : 2
core id         : 0
cpu cores       : 2
fpu             : yes
fpu_exception   : yes
cpuid level     : 1
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext
fxsr_opt lm 3dnowext 3dnow pni lahf_lm cmp_legacy
bogomips        : 4785.70
TLB size        : 1024 4K pages
clflush size    : 64
cache_alignment : 64
address sizes   : 40 bits physical, 48 bits virtual
power management: ts fid vid ttp

processor       : 3
vendor_id       : AuthenticAMD
cpu family      : 15
model           : 33
model name      : Dual Core AMD Opteron(tm) Processor 280
stepping        : 2
cpu MHz         : 2400.000
cache size      : 1024 KB
physical id     : 1
siblings        : 2
core id         : 1
cpu cores       : 2
fpu             : yes
fpu_exception   : yes
cpuid level     : 1
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext
fxsr_opt lm 3dnowext 3dnow pni lahf_lm cmp_legacy
bogomips        : 4785.70
TLB size        : 1024 4K pages
clflush size    : 64
cache_alignment : 64
address sizes   : 40 bits physical, 48 bits virtual
power management: ts fid vid ttp


I can run from any of our Fedora Clients (3, 4, or 6) and completely
swamp the server with read requests when there shouldn't be any read
requests at all.

I find that if I try to open a file that isn't there with an
fopen(name,"w"), I am ok because I truncate the file.  If I try and
fopen(name,"r+"), then I get into trouble where it wants to read these
4KB blocks.  It is not a trivial amount as on our system I am able to
pull of almost 2000 tps of 4 KB blocks, which kills our boxes.  I know
it is the NFS layer because if I run the disk exercise programs such as
iozone and another in house program locally on the NFS server, it is
fine, but the minute I run it remote, and it tries to open a file that
already exists and has > 0 bytes, it goes nuts.  I haven't been able to
try a vanilla kernel yet because I am having trouble finding a node free
that I can test with.

Also, I have ruled out 64 bit and 32 bit problems.  The NFS server I had
been using is a 64 bit box, but I just tested the same thing serving a
filesystem from my 32 bit laptop, and it also has the issue (it is a FC6
as well).  Also, I have ruled out filesystems.  The 64 bit server was
using XFS, and my laptop is using ext3, and both systems have the same
issue.

If there is any other information I can get you, please let me know.

In the mean time, we are trying to setup some tests using the latest
(2.6.20) kernel.

Thanks for your time,

Norman Weathers



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
