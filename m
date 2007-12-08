From: Bruce Guenter <bruce@untroubled.org>
Subject: PROBLEM: Duplicated entries in large NFS shared directory
Date: Sat, 8 Dec 2007 08:12:51 -0600
Message-ID: <20071208141251.GA18235@untroubled.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="EVF5PPMfhYS0aIcm"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from zak.futurequest.net ([69.5.6.152]:56904 "HELO
	zak.futurequest.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751111AbXLHOTf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 8 Dec 2007 09:19:35 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--EVF5PPMfhYS0aIcm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi.

I have a large directory (almost 40,000 entries) on an ext3 filesystem
that is shared over NFS.  I discovered recently when listing the
directory on the client, one of the files appears twice.  The same file
does not appear twice on the server.

I did a capture using WireShark, and discovered that the offending file
name is being sent twice -- once as the last entry in a readdir reply
packet and then again as the first entry in the next readdir reply.

If I'm reading the trace right, the readdir call sends the cookie for
the last entry in the previous readdir reply and the server responds
with the next set of entries.  In this case, the server responds with
the entry containing the same cookie again.

The server is running vanilla 2.6.23.8.  I would be happy to provide any
further information that would help resolve this bug.

Linux ivanova 2.6.23.8 #2 Thu Dec 6 20:32:17 CST 2007 i686 AMD Athlon(TM)Pr=
ocessor AuthenticAMD GNU/Linux
=20
Gnu C                  3.4.6
Gnu make               3.81
binutils               Binutils
util-linux             2.12r
mount                  2.12r
module-init-tools      3.4
e2fsprogs              1.40.2
reiserfsprogs          3.6.19
Linux C Library        6.1
Dynamic linker (ldd)   2.6.1
Procps                 3.2.7
Net-tools              1.60
Kbd                    1.13
Sh-utils               6.9
udev                   115
Modules Loaded         ide_generic ide_core via686a eeprom lm80 i2c_viapro =
i2c_core nfsd exportfs lockd sunrpc iptable_nat nf_nat ipt_REJECT ipt_LOG n=
f_conntrack_ipv4 xt_connbytes nf_conntrack nfnetlink xt_tcpudp iptable_filt=
er ip_tables x_tables tulip uhci_hcd ehci_hcd sg ohci_hcd usbcore ext3 jbd

processor	: 0
vendor_id	: AuthenticAMD
cpu family	: 6
model		: 4
model name	: AMD Athlon(TM)Processor
stepping	: 4
cpu MHz		: 1399.972
cache size	: 256 KB
fdiv_bug	: no
hlt_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 1
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 sep mtrr pge mca
cmov pat pse36 mmx fxsr syscall mmxext 3dnowext 3dnow
bogomips	: 2801.40
clflush size	: 32

ide_generic 1152 0 [permanent], Live 0xf8955000
ide_core 119572 1 ide_generic, Live 0xf8a0e000
via686a 14608 0 - Live 0xf89bf000
eeprom 7584 0 - Live 0xf8963000
lm80 17312 0 - Live 0xf896a000
i2c_viapro 8732 0 - Live 0xf892c000
i2c_core 25104 3 eeprom,lm80,i2c_viapro, Live 0xf89b7000
nfsd 98152 13 - Live 0xf89d5000
exportfs 5760 1 nfsd, Live 0xf8950000
lockd 69224 2 nfsd, Live 0xf8973000
sunrpc 171868 5 nfsd,lockd, Live 0xf898c000
iptable_nat 7620 1 - Live 0xf893c000
nf_nat 19692 1 iptable_nat, Live 0xf8957000
ipt_REJECT 4480 1 - Live 0xf8939000
ipt_LOG 6144 2 - Live 0xf8930000
nf_conntrack_ipv4 17864 3 iptable_nat, Live 0xf8933000
xt_connbytes 2944 1 - Live 0xf889e000
nf_conntrack 61028 4 iptable_nat,nf_nat,nf_conntrack_ipv4,xt_connbytes,
Live 0xf8940000
nfnetlink 6104 3 nf_nat,nf_conntrack_ipv4,nf_conntrack, Live 0xf8899000
xt_tcpudp 3392 4 - Live 0xf889c000
iptable_filter 2884 1 - Live 0xf8891000
ip_tables 13848 2 iptable_nat,iptable_filter, Live 0xf8894000
x_tables 15172 6
iptable_nat,ipt_REJECT,ipt_LOG,xt_connbytes,xt_tcpudp,ip_tables, Live
0xf8807000
tulip 52128 0 - Live 0xf88a0000
uhci_hcd 25556 0 - Live 0xf8886000
ehci_hcd 32536 0 - Live 0xf887d000
sg 32168 0 - Live 0xf8874000
ohci_hcd 21900 0 - Live 0xf880f000
usbcore 138780 4 uhci_hcd,ehci_hcd,ohci_hcd, Live 0xf8828000
ext3 117960 1 - Live 0xf884b000
jbd 54632 1 ext3, Live 0xf8819000

--=20
Bruce Guenter <bruce@untroubled.org>                http://untroubled.org/

--EVF5PPMfhYS0aIcm
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFHWqZj6W+y3GmZgOgRAvg2AKCTvXZYHlKcF4ViuWg/+rc864zMMACdFqtr
2vaKTJUvhj5l/TCCFi0E6+4=
=M1om
-----END PGP SIGNATURE-----

--EVF5PPMfhYS0aIcm--
