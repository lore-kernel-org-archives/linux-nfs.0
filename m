From: Ingo Saitz <Ingo.Saitz@stud.uni-hannover.de>
Subject: PROBLEM: can't mkdir() in 2.6.19-rc3
Date: Wed, 1 Nov 2006 03:16:47 +0100
Message-ID: <20061101021647.GA4203@schwan.zoo>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1494387322=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gf5f6-00016x-Co
	for nfs@lists.sourceforge.net; Tue, 31 Oct 2006 18:17:04 -0800
Received: from mx.stud.uni-hannover.de
	([130.75.176.3] helo=studserv.stud.uni-hannover.de ident=root)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gf5f4-0007nZ-T1
	for nfs@lists.sourceforge.net; Tue, 31 Oct 2006 18:17:05 -0800
Received: from schwan (ingo@localhost [127.0.0.1])
	by studserv.stud.uni-hannover.de (8.13.8/8.13.8) with ESMTP id
	kA12GnHZ013968
	for <nfs@lists.sourceforge.net>; Wed, 1 Nov 2006 03:16:50 +0100 (MET)
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


--===============1494387322==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Kj7319i9nmIyA2yE"
Content-Disposition: inline


--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

[1.] One line summary of the problem:   =20

Can't call mkdir() on 2.6.19-r3 nfsd


[2.] Full description of the problem/report:

When I call "mkdir foo" on an nfs mounted volume, the strace of mkdir shows

    mkdir("foo", 0777)                      =3D -1 EPERM (Operation not per=
mitted)

and the command fails. But if I do a "ls -ld foo" afterwards, the directory=
 got
created:

    drwxr-xr-x 2 ingo ingo 4096 2006-11-01 02:54 foo

The server is running 2.6.19-rc3, the client 2.6.18. The version of the
nfs-kernel-server ist 1.0.10. This did work with 2.6.18 as nfs server.


[3.] Keywords (i.e., modules, networking, kernel):

nfsd, mkdir, EPERM, 2.6.19-rc3


[4.] Kernel version (from /proc/version):

Linux version 2.6.19-rc3-pinguin20061024.1 (ingo@pinguin) (gcc version 4.1.=
2 20060901 (prerelease) (Debian 4.1.1-13)) #1 SMP Tue Oct 24 16:47:01 CEST =
2006


[5.] Output of Oops.. message (if applicable) with symbolic information=20
     resolved (see Documentation/oops-tracing.txt)

n/a, strace see above.


[6.] A small shell script or example program which triggers the
     problem (if possible)

mkdir foo


[7.] Environment

[7.1.] Software (add the output of the ver_linux script here)

The nfs server is Debian testing, nfs-kernel-server version 1.0.10-2.

$ scripts/ver_linux
If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.

Linux pinguin 2.6.19-rc3-pinguin20061024.1 #1 SMP Tue Oct 24 16:47:01 CEST =
2006 x86_64 GNU/Linux

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
da_intel snd_hda_codec snd_pcm_oss snd_mixer_oss sg snd_pcm i2c_i801 snd_ti=
mer iTCO_wdt 8250 serial_core i2c_core sr_mod intel_agp parport_pc parport =
e1000 cdrom floppy evdev snd soundcore snd_page_alloc psmouse rtc pcspkr un=
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


[X.] Other notes, patches, fixes, workarounds:

--=20
Man hat schon Igel nach Westen kotzen sehen!
(alte indianische Weisheit)

--Kj7319i9nmIyA2yE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQFFSAOP4XrXtQkN2NURAmWiAJ4gukJ5GfS1R+Ns4W291DMkeSG65QCgo3xH
QMS0sIWEK29aZS+98aI7K8M=
=BAEw
-----END PGP SIGNATURE-----

--Kj7319i9nmIyA2yE--


--===============1494387322==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--===============1494387322==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1494387322==--
