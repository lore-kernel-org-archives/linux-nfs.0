From: Ingo Saitz <Ingo.Saitz@stud.uni-hannover.de>
Subject: PROBLEM: mounting an nfs export hangs the rpc.mountd
	kernelthread in 2.6.19-rc4
Date: Wed, 1 Nov 2006 03:45:19 +0100
Message-ID: <20061101024519.GA4426@schwan.zoo>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0549358420=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gf66f-0003SS-HD
	for nfs@lists.sourceforge.net; Tue, 31 Oct 2006 18:45:33 -0800
Received: from mx.stud.uni-hannover.de
	([130.75.176.3] helo=studserv.stud.uni-hannover.de ident=root)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gf66e-0007I5-HK
	for nfs@lists.sourceforge.net; Tue, 31 Oct 2006 18:45:34 -0800
Received: from schwan (ingo@localhost [127.0.0.1])
	by studserv.stud.uni-hannover.de (8.13.8/8.13.8) with ESMTP id
	kA12jKim025188
	for <nfs@lists.sourceforge.net>; Wed, 1 Nov 2006 03:45:21 +0100 (MET)
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


--===============0549358420==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="wac7ysb48OaltWcw"
Content-Disposition: inline


--wac7ysb48OaltWcw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

[1.] One line summary of the problem:   =20

Mounting an NFS export hangs the rpc.mountd kernel thread in 2.6.19-rc4


[2.] Full description of the problem/report:

After the first mount of an exported NFS share, the rpc.mountd process
does not answer and starts consuming 100% CPU.

Output from top:
 1664 root      15   0  1704  692  524 R  100  0.1  17:40.97 rpc.mountd

[3.] Keywords (i.e., modules, networking, kernel):

nfsd, rpc.mountd, 2.6.19-rc4


[4.] Kernel version (from /proc/version):

Linux version 2.6.19-rc4-pinguin20061031 (ingo@pinguin) (gcc version 4.1.2 =
20060901 (prerelease) (Debian 4.1.1-13)) #1 SMP Tue Oct 31 21:57:24 UTC 2006


[5.] Output of Oops.. message (if applicable) with symbolic information=20
     resolved (see Documentation/oops-tracing.txt)

n/a


[6.] A small shell script or example program which triggers the
     problem (if possible)

mount server:/DATA


[7.] Environment

[7.1.] Software (add the output of the ver_linux script here)

The nfs server is Debian testing, nfs-kernel-server version 1.0.10-2.

$ scripts/ver_linux
If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.

Linux pinguin 2.6.19-rc4-pinguin20061031 #1 SMP Tue Oct 31 21:57:24 UTC 200=
6 x86_64 GNU/Linux

Gnu C                  4.1.2
Gnu make               3.81
binutils               2.17
util-linux             2.12r
mount                  2.12r
module-init-tools      3.2.2
e2fsprogs              1.39
Linux C Library        2.3.6
Dynamic linker (ldd)   2.3.6
Procps                 3.2.7
Net-tools              1.60
Console-tools          0.2.3
Sh-utils               5.97
udev                   100
Modules Loaded         nfs tun crc32 nfsd exportfs lockd sunrpc lp thermal =
fan button processor ac battery dm_snapshot dm_mirror dm_mod 8250_pnp snd_h=
da_intel snd_hda_codec snd_pcm_oss snd_mixer_oss sg snd_pcm sr_mod i2c_i801=
 cdrom iTCO_wdt snd_timer intel_agp i2c_core e1000 psmouse 8250 serial_core=
 pcspkr evdev rtc parport_pc parport snd soundcore snd_page_alloc floppy un=
ix


[7.2.] Processor information (from /proc/cpuinfo):

processor       : 0
vendor_id       : GenuineIntel
cpu family      : 6
model           : 15
model name      : Intel(R) Core(TM)2 CPU          6300  @ 1.86GHz
stepping        : 6
cpu MHz         : 1862.002
cache size      : 2048 KB
physical id     : 0
siblings        : 2
core id         : 0
cpu cores       : 2
fpu             : yes
fpu_exception   : yes
cpuid level     : 10
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca =
cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm syscall nx lm co=
nstant_tsc pni monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr lahf_lm
bogomips        : 3726.93
clflush size    : 64
cache_alignment : 64
address sizes   : 36 bits physical, 48 bits virtual
power management:

processor       : 1
vendor_id       : GenuineIntel
cpu family      : 6
model           : 15
model name      : Intel(R) Core(TM)2 CPU          6300  @ 1.86GHz
stepping        : 6
cpu MHz         : 1862.002
cache size      : 2048 KB
physical id     : 0
siblings        : 2
core id         : 1
cpu cores       : 2
fpu             : yes
fpu_exception   : yes
cpuid level     : 10
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca =
cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm syscall nx lm co=
nstant_tsc pni monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr lahf_lm
bogomips        : 3724.18
clflush size    : 64
cache_alignment : 64
address sizes   : 36 bits physical, 48 bits virtual
power management:


[7.3.] Module information (from /proc/modules):
[7.4.] Loaded driver and hardware information (/proc/ioports, /proc/iomem)
[7.5.] PCI information ('lspci -vvv' as root)
[7.6.] SCSI information (from /proc/scsi/scsi)

Please tell me if you think any of these are relevant.


[7.7.] Other information that might be relevant to the problem
       (please look in /proc and include all information that you
       think to be relevant):

The kernel is compiled for the x86_64 arch, the userspace and the nfs
kernel server code is still compiled for i386. The exported filesystems
are all ext3.

$ grep 'NFS\|RPC\|LOCKD' /boot/config-`uname -r`
CONFIG_LOCKDEP_SUPPORT=3Dy
CONFIG_NFS_FS=3Dm
CONFIG_NFS_V3=3Dy
# CONFIG_NFS_V3_ACL is not set
CONFIG_NFS_V4=3Dy
# CONFIG_NFS_DIRECTIO is not set
CONFIG_NFSD=3Dm
CONFIG_NFSD_V3=3Dy
# CONFIG_NFSD_V3_ACL is not set
CONFIG_NFSD_V4=3Dy
CONFIG_NFSD_TCP=3Dy
CONFIG_LOCKD=3Dm
CONFIG_LOCKD_V4=3Dy
CONFIG_NFS_COMMON=3Dy
CONFIG_SUNRPC=3Dm
CONFIG_SUNRPC_GSS=3Dm
CONFIG_RPCSEC_GSS_KRB5=3Dm
CONFIG_RPCSEC_GSS_SPKM3=3Dm
CONFIG_RXRPC=3Dm

The exports look like this:
/DATA	10.11.12.13(rw,async,subtree_check)

The fstab on the client look like ths:
server:/DATA	/DATA/	nfs	defaults	0	0


[X.] Other notes, patches, fixes, workarounds:

--=20
Man hat schon Igel nach Westen kotzen sehen!
(alte indianische Weisheit)



----- End forwarded message -----

--=20
Man hat schon Igel nach Westen kotzen sehen!
(alte indianische Weisheit)

--wac7ysb48OaltWcw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQFFSAo/4XrXtQkN2NURAuPlAJ4gm0PyitONiaJXBT9uW96ptGzp0QCeJOp0
5ruQvxnp/ot4Gh9fL5HHSuQ=
=ehCh
-----END PGP SIGNATURE-----

--wac7ysb48OaltWcw--


--===============0549358420==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--===============0549358420==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0549358420==--
