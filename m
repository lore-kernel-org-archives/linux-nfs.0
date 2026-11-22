Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=142.132.201.35
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795363313;
	b=YyDkeiJPDMr18COLbqvQTeTNf2NmT4mfa/YPAU8X9K50ib4TBkCVLGrK15cYFtfWQC4O
	 iPx6pgDl8HHkP4K3mRwvbGAldUqiVcAGNykLcWa/K3srWJRpSzprdi0/xB+wtFdLNJgeL
	 L6uDJGY2AZGi4URKHBe2im9Ms1MKpoz08B2A/aNFjcI5X48d1KIrMXfJhjcltarQw0TeK
	 9r744jYQkZCyLEWIH7PK3oWP4PwfOXwvBnBWCS5rB5pgwWjk1+tU7KHj7R74PLg51c5E9
	 3v3epysK+U3qmxH7Tt2Gu3x2YsTOCKy1iNgugCSoDwbW4YSqUG+LptbERSVTIODodeg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795363313;
	h=DMARC-Filter:DKIM-Signature:Original-Subject:Author:Received:Date:
	 From:To:Subject:Message-ID:Mime-Version:Content-Type:
	 Content-Disposition:X-Public-Key-URL:X-homepage;
	bh=oCJj//RxD2XEJtAz71zJC3j7stZCPJ4b7XIf8I3bWTk=;
	b=isvNQxrwk+Gw3eg/d5Jcca4i2NbUdueIRiYgYaCPHGYqKIuJAzI3OCELzKi+99bYvDBZ
	 yjIhcAPkDSzHHPxY5XwhkQw9fnfULaZjuUf8kf+uE9QxYkHo7ARbCGedliATVMQDCLL97
	 hCokw+F8F9NxGtP8BdAuVFIXlL+2dAabq//wsIaKhG5+ldeZ7OD3mb0P9MyedVOTUpAIb
	 izIe+fQQoIr3Qeu1uWeVDykIDDUXdX7dDeuSbN09oVgNIwPoqDjCLV9HsGTp1cj15b8j1
	 9+vaMWO4Xipfy6TLqWcCnOSR8H+Kqq2aFseXecwXOD1u4C0kH6FnAe9wty2zpcOIcrg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=helgefjell.de;
	spf=pass smtp.mailfrom=helgefjell.de;
	dkim=pass header.d=helgefjell.de header.i=@helgefjell.de header.a=rsa-sha256 header.s=selector.helgefjell header.b=hUPoDGpU;
	arc=none smtp.remote-ip=142.132.201.35
Received: from mail.helgefjell.de (mail.helgefjell.de [142.132.201.35])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (prime256v1) server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9C18A606A320
	for <linux-nfs@vger.kernel.org>; Sun, 22 Nov 2026 16:01:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 9C18A606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=helgefjell.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=helgefjell.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=helgefjell.de header.i=@helgefjell.de header.a=rsa-sha256 header.s=selector.helgefjell header.b=hUPoDGpU
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=helgefjell.de;
	s=selector.helgefjell; t=1795363304;
	bh=oCJj//RxD2XEJtAz71zJC3j7stZCPJ4b7XIf8I3bWTk=;
	h=Date:From:To:Subject;
	b=hUPoDGpU8lGqvYM3TtGC5SbwGkuXwaRTMWwmtIBsWSTGcCHtSoHK28nW0b/7Qo90R
	 drKrBLpacrlzhkr9bsEHbq2IFCfyFIHCmk3b2DxqNF7uNDqIFiLzbvkvDiDsVI9g0q
	 oM6+XbAy0eb0ul//FaXIAVtHCJyP3mfoaVRYWM4AjGFEFpN0igUpiPwkvnFKTh2hXA
	 gBIH5umGOg76q0oPt5hRrSdLLM6Vn4QqZTMwx0jOm9dhrlYqkbxlnDFa6bdAV2NGvM
	 RTW2jYrSKm8sNGLrxZVzlw5oCq4daShZzcj5li29K343qtrtPF3sfKBrq/xPaAUSHO
	 63MAqBPspAQ3w==
Original-Subject: Issues in man pages of nfs
Author: Helge Kreutzmann <debian@helgefjell.de>
Received: from localhost (localhost [127.0.0.1])
  (uid 1002)
  by mail.helgefjell.de with local
  id 00000000000200EF.000000006B0311E8.00197584; Sun, 22 Nov 2026 16:01:44 +0000
Date: Sun, 22 Nov 2026 16:01:44 +0000
From: Helge Kreutzmann <debian@helgefjell.de>
To: linux-nfs@vger.kernel.org
Subject: Issues in man pages of nfs
Message-ID: <awMR6CffeHfoUy09@meinfjell.helgefjelltest.de>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256; protocol="application/pgp-signature"; boundary="=_meinfjell-1668484-1795363304-0001-2"
Content-Disposition: inline
X-Public-Key-URL: http://www.helgefjell.de/data/debian_neu.asc
X-homepage: http://www.helgefjell.de/debian

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_meinfjell-1668484-1795363304-0001-2
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dear NFS maintainer,
the manpage-l10n project[1] maintains a large number of translations of
man pages both from a large variety of sources (including NFS) as
well for a large variety of target languages.

During their work translators notice different possible issues in the
original (english) man pages. Sometimes this is a straightforward
typo, sometimes a hard to read sentence, sometimes this is a
convention not held up and sometimes we simply do not understand the
original.

We use several distributions as sources and update regularly (at
least every 2 month). This means we are fairly recent (some
distributions like archlinux also update frequently) but might miss
your latest upstream version once in a while, so the error might be
already fixed. We apologize and ask you to close the issue immediately
if this should be the case, but given the huge volume of projects and
the very limited number of volunteers we are not able to double check
each and every issue.

Secondly we translators see the manpages in the neutral po format,
i.e. converted and harmonized, but not the original source (be it man,
groff, xml or other). So we cannot provide a true patch (where
possible), but only an approximation which you need to convert into
your source format.

Finally the issues I'm reporting have accumulated over time and are
not always discovered by me, so sometimes my description of the
problem my be a bit limited - do not hesitate to ask so we can clarify
them.

I'm now reporting the issues for your project. If future reports
should use another channel, please let me know.

[1] https://manpages-l10n-team.pages.debian.net/manpages-l10n/

Man page: exportfs.8
Issue:    missing period at the end of sentence

"B<exportfs> will also recognize the B<state-directory-path> and B<no-"
"netlink> values from both the B<[mountd]> section and the B<[exportd]> "
"section.  When B<no-netlink> is set, B<exportfs> will skip the netlink pro=
be "
"and use the legacy I</proc> interfaces for cache flushing and export "
"validation"
--
Man page: exportfs.8
Issue:    B<exports(5)> =E2=86=92 B<exports>(5)

"The I<host:/path> argument specifies a local directory to export, along wi=
th "
"the client or clients who are permitted to access it.  See B<exports(5)> f=
or "
"a description of supported options and access list formats."
--
Man page: nfs.5
Issue:    Why is the word "option" in bold?

"The B<sloppy> option is an alternative to specifying B<mount.nfs> -s "
"B<option.>"
--
Man page: nfs.5
Issue:    If is =E2=86=92 If it

"When the client discovers a new filesystem on a NFSv4.1+ server, the "
"B<trunkdiscovery> mount option will cause it to send a GETATTR for the "
"fs_locations attribute.  If is receives a non-zero length reply, it will "
"iterate through the response, and for each server location it will establi=
sh "
"a connection, send an EXCHANGE_ID, and test for session trunking.  If the "
"trunking test succeeds, the connection will be added to the existing set o=
f "
"transports for the server, subject to the limit specified by the "
"B<max_connect> option.  The default is B<notrunkdiscovery>."
--
Man page: nfs.5
Issue:    B<nfsmount.conf(5)> =E2=86=92 B<nfsmount.conf>(5)

"If the mount command is configured to do so, all of the mount options "
"described in the previous section can also be configured in the I</etc/"
"nfsmount.conf> file. See B<nfsmount.conf(5)> for details."
--
Man page: nfs.conf.5
Issue:    Remove comma at the end

"Recognized values: B<threads>, B<min-threads>, B<host>, B<scope>, B<port>,=
 "
"B<grace-time>, B<lease-time>, B<udp>, B<tcp>, B<vers3>, B<vers4>, "
"B<vers4.0>, B<vers4.1>, B<vers4.2>, B<rdma>, B<fh-key-file>,"
--
Man page: nfsd.7
Issue:    back-slash vs. backslash, should be consistent

"Each line of the file contains a path name, a client name, and a number of=
 "
"options in parentheses.  Any space, tab, newline or back-slash character i=
n "
"the path name or client name will be replaced by a backslash followed by t=
he "
"octal ASCII code for that character."
--
Man page: nfsd.7
Issue:    thread currently =E2=86=92 threads currently

"This file represents the number of B<nfsd> thread currently running.  "
"Reading it will show the number of threads.  Writing an ASCII decimal numb=
er "
"will cause the number of threads to be changed (increased or decreased as "
"necessary) to achieve that number."
--
Man page: nfsd.7
Issue:    The first sentence is logical, but I would expect any file to con=
tain what I've written to it - is there some "twist" I'm missing?

"This is a somewhat unusual file in that what is read from it depends on wh=
at "
"was just written to it.  It provides a transactional interface where a "
"program can open the file, write a request, and read a response.  If two "
"separate programs open, write, and read at the same time, their requests "
"will not be mixed up."
--
Man page: nfsd.7
Issue:    can be display =E2=86=92 can be displayed

"The directory B</proc/net/rpc> in the B<procfs> filesystem contains a numb=
er "
"of files and directories.  The files contain statistics that can be displa=
y "
"using the I<nfsstat> program.  The directories contain information about "
"various caches that the NFS server maintains to keep track of access "
"permissions that different clients have for different filesystems.  The "
"caches are:"
--
Man page: nfsd.7
Issue 1:  select(2) or poll(2) =E2=86=92 B<select>(2) or B<poll>(2)
Issue 2:  and end-of-file =E2=86=92 an end-of-file

"If the program uses select(2) or poll(2) to discover if it can read from t=
he "
"B<channel> then it will never see and end-of-file but when all requests ha=
ve "
"been answered, it will block until another request appears."
--
Man page: nfsd.8
Issue:    B<netconfig(5).> =E2=86=92 B<netconfig>(5) (no full stop in SEE A=
LSO)

"B<nfsd>(7), B<rpc.mountd>(8), B<exports>(5), B<exportfs>(8), B<nfs.conf>(5=
), "
"B<rpc.rquotad>(8), B<nfsstat>(8), B<netconfig(5).>"
--
Man page: nfsmount.conf.5
Issue 1:  =C2=BBVariables are assignmen statements =E2=80=A6 variables=C2=
=AB =E2=80=A6?
Issue 2:  independant =E2=86=92 independent

"The configuration file is made up of multiple section headers followed by "
"variable assignments associated with that section.  A section header is "
"defined by a string enclosed by B<[> and B<]> brackets.  Variable "
"assignments are assignment statements that assign values to particular "
"variables using the B<=3D> operator, as in B<Proto=3DTcp>.  The variables =
that "
"can be assigned are the set of NFS specific mount options listed in "
"B<nfs>(5)  together with the filesystem-independant mount options listed i=
n "
"B<mount>(8)  and three additions: B<Sloppy=3DTrue> has the same effect as =
the "
"B<-s> option to I<mount>, and B<Foreground=3DTrue> and B<Background=3DTrue=
> have "
"the same effect as B<bg> and B<fg>."
--
Man page: nfsmount.conf.5
Issue:    over-ride =E2=86=92 override

"Default NFS mount configuration files, variables set in the later file ove=
r-"
"ride those in the earlier file."
--
Man page: nfsmount.conf.5
Issue:    Remove comma at the end
"B<nfs>(5), B<mount>(8),"
--
Man page: nfs.systemd.7
Issue 1:  I<nfs-utils> =E2=86=92 B<nfs-utils>
Issue 2:  I<systemd> =E2=86=92 B<systemd>(8)

"The I<nfs-utils> package provides a suite of I<systemd> unit files and "
"generators which allow the various services to be started and managed.  "
"These unit files and generators ensure that the services are started in th=
e "
"correct order, and the prerequisites are active before dependant services "
"start.  As there are quite a few unit files and generators, it is not "
"immediately obvious how best to achieve certain results.  The following "
"subsections attempt to cover the issues that are most likely to come up."
--
Man page: nfs.systemd.7
Issue 1:  systemd =E2=86=92 B<systemd>(1)
Issue 2:  I<nfs-utils> =E2=86=92 B<nfs-utils>

"systemd unit generators are small executables placed in I</usr/lib/systemd=
/"
"system-generators/> to dynamically extend the unit file hierarchy.  The "
"I<nfs-utils> package provides three:"
--
Man page: nfs.systemd.7
Issue:    /sysroot =E2=86=92 I</sysroot>

"It creates the B<sysroot.mount> unit to mount /sysroot via NFSv4 in the "
"initrd, if it detects one the following options in the kernel command line=
:"
--
Man page: nfs.systemd.7
Issue:    I<nfs-server.service> =E2=86=92 B<nfs-server.service>

"It creates ordering dependencies between I<nfs-server.service> and various=
 "
"filesystem mounts: it should start before any \"nfs\" mountpoints are "
"mounted, in case they are loop-back mounts, and after all exported "
"filesystems are mounted, so there is no risk of exporting the underlying "
"directory."
--
Man page: showmount.8
Issue:    formatting of sort -u

"B<showmount> queries the mount daemon on a remote host for information abo=
ut "
"the state of the NFS server on that machine.  With no options B<showmount>=
 "
"lists the set of clients who are mounting from that host.  The output from=
 "
"B<showmount> is designed to appear as though it were processed through "
"``sort -u''."
--
Man page: umount.nfs.8
Issue:    refer =E2=86=92 refer to the

"For further information please refer B<nfs>(5)  and B<umount>(8)  manual "
"pages."
--
Man page: umount.nfs.8
Issue:    Remove comma at the end
"B<nfs>(5), B<umount>(8),"

--=20
      Dr. Helge Kreutzmann                     debian@helgefjell.de
           Dipl.-Phys.                   http://www.helgefjell.de/debian.php
        64bit GNU powered                     gpg signed mail preferred

--=_meinfjell-1668484-1795363304-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEbZZfteMW0gNUynuwQbqlJmgq5nAFAmsDEdwACgkQQbqlJmgq
5nAvpw/9HYBUE8hmW067f8XjWoiKRpnqEWlwouB6V9iD3b+ekWCakAoKxQPm/s62
TfJkkbMN1BMyb3p50Rqh0m6+dgyDFWu286XyCNhb1SjRuSlBY7s0WnbMlfi/+WBl
2DeJNq5arBE6k+57wjCEG3fMwgYhy2U+LEN7gB+wEeDU0gmMrwt3pTUmqAf1wZMv
e/t1mApzbZr5vwN4MLYQ1OSw1zSMLnbKOIYQ37XOzyc/xy7wlH8kofoCxYIoGow5
4KncQR83aYnWQaWB4HJ9AKlzCYM9PpYaCLNIKSFrGi638VZD96zmrI1c1mVN6pUD
1d648k0iJT+gOcm49lBg9sS+5nOdKwG90Q0+690Snihpffw0jGyFErTdP7YOZ7Z9
15wj+YfIM99m2Lp9esI5ER2PoYOkNO6hMaq4ruUGbSYwHegY/PIDNC4MKcj/oqiQ
JNHE4so62YUoktoZ8U4lI3AVm/Pe6D3lkENhP3l4tSKztNHQ3VtZ+hTST1lJjc4/
IiZe8aynUubLCQQpcoVbRY+ukRNs905J1nPcHUtvqoEmVA8UI5+nC4WrObINx8bB
4+Is35dPAKh7HgGCipMIMiUREwjfOk7o9GWrTdnGxNmNr+4Bt+pzIcRH3lVzO+cl
VTqUDJnQpieK37jDs8HyD2n7cEpYE4WxognYPKWMHkDTVQ/tAJ4=
=rssd
-----END PGP SIGNATURE-----

--=_meinfjell-1668484-1795363304-0001-2--
