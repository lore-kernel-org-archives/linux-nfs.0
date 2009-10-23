From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFSv4 Kernel-server requires 2x manual restart after reboot?
	Maybe a timing problem?
Date: Fri, 23 Oct 2009 14:24:13 -0400
Message-ID: <20091023182413.GA32155@fieldses.org>
References: <babafd2f0910231007h329e75b7raa7207d0b816a72a@mail.gmail.com> <20091023172719.GB31133@fieldses.org> <babafd2f0910231057o4898c643n4605ef9b0e4686d8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: Ben DJ <bendj095124367913213465@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35201 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751564AbZJWSW7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Oct 2009 14:22:59 -0400
In-Reply-To: <babafd2f0910231057o4898c643n4605ef9b0e4686d8-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 23, 2009 at 10:57:57AM -0700, Ben DJ wrote:
> Hi Bruce,
>=20
> On Fri, Oct 23, 2009 at 10:27 AM, J. Bruce Fields <bfields@fieldses.o=
rg> wrote:
> > On Fri, Oct 23, 2009 at 10:07:23AM -0700, Ben DJ wrote:
> >> I've installed NFSv4 as nfs-kernel-server.
> >
> > What distro and versions are you using?
>=20
> I'm currently working on Opensuse 11.2 RC1.
>=20
> At the moment,
>=20
> kernel-default-base-2.6.31.3-1.1.x86_64
> kernel-default-2.6.31.3-1.1.x86_64
> kernel-default-devel-2.6.31.3-1.1.x86_64
>=20
> quota-nfs-3.17-3.1.x86_64
> nfsidmap-0.21-3.14.x86_64
> nfs-doc-1.1.3-20.1.x86_64
> nfs-client-1.1.3-20.1.x86_64
> nfs-kernel-server-1.1.3-20.1.x86_64
>=20
>=20
> > Huh. =C2=A0What filesystem is at /nfs/test?
>=20
> I'm not entirely sure what you're asking for.
>=20
> /nfs/test is on my "/" volume, which is ext3 (someday, ext4 -- but no=
t yet).
>=20
> Is that what you mean?

Right.  Actually I should have asked what the output of the "mount" and
"exportfs -v" commands were on the server.

--b.

> Also I found that switching from mounts in /etc/fstab to using autofs
> gets rid of the mount-after-boot issues
>=20
> cat /etc/auto.master
> 	/test /etc/auto.misc
> cat /etc/auto.misc
> 	cd -fstype=3Diso9660,ro,nosuid,nodev :/dev/cdrom
> 	nfs4_test -fstype=3Dnfs4,rw 192.168.1.2:/
> chkconfig autofs on
> reboot
>=20
> But now, immediately after reboot,
>=20
> ls /test/nfs4_test/
> 	bin/  boot/  dev/  etc/  home/  lib/  lib64/  lost+found/  media/
> mnt/  mnt.auto/  nfs/  opt/  proc/  root/  sbin/  selinux/  srv/  sys=
/
>  tmp/  usr/  var/
>=20
> which is mounted, and feels like progress.
>=20
> But the mount is of 192.168.1.2's "/" root.  I expected the NFSv4
> exported-root @ /nfs, instead.
>=20
> Thanks for your time.
>=20
> BenDJ
>=20
>=20
>=20
> Thanks.
>=20
> BedDJ
