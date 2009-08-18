From: maximilian attems <max-U9r9yeDMy7A@public.gmane.org>
Subject: Re: nfs MNT include cleanup
Date: Tue, 18 Aug 2009 12:36:53 +0200
Message-ID: <20090818103653.GB3954@stro.at>
References: <20090811104418.GA6175@stro.at>
 <C7D2AC7D-48B2-4206-A6B1-3780FE7D51CE@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>, klibc@zytor.com
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:48566 "EHLO
	baikonur.stro.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758107AbZHRKhU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Aug 2009 06:37:20 -0400
In-Reply-To: <C7D2AC7D-48B2-4206-A6B1-3780FE7D51CE@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 11 Aug 2009, Chuck Lever wrote:

> On Aug 11, 2009, at 6:44 AM, maximilian attems wrote:
> >2ad780978b7c0c3e7877949f098cbd06e7c73839 broke klibc build
> >MNTPROC_MNT and MNTPROC_UMNT no longer defined.
>=20
> I assume then that klibc is out of tree?  I can't find it in my
> kernel repo.

sorry for late reply, indeed you'll find it here:
http://git.kernel.org/?p=3Dlibs/klibc/klibc.git;a=3Dsummary
=20
> >usr/kinit/nfsmount/mount.c: In function =E2=80=98mount_call=E2=80=99=
:
> >usr/kinit/nfsmount/mount.c:179: error: =E2=80=98MNTPROC_MNT=E2=80=99=
 undeclared
> >(first use in this function)
> >usr/kinit/nfsmount/mount.c:179: error: (Each undeclared identifier
> >is reported only once
> >usr/kinit/nfsmount/mount.c:179: error: for each function it
> >appears in.)
> >usr/kinit/nfsmount/mount.c: In function =E2=80=98mount_v2=E2=80=99:
> >usr/kinit/nfsmount/mount.c:211: error: =E2=80=98MNTPROC_MNT=E2=80=99=
 undeclared
> >(first use in this function)
> >usr/kinit/nfsmount/mount.c: In function =E2=80=98umount_v2=E2=80=99:
> >usr/kinit/nfsmount/mount.c:226: error: =E2=80=98MNTPROC_UMNT=E2=80=99=
 undeclared
> >(first use in this function)
> >usr/kinit/nfsmount/mount.c: In function =E2=80=98mount_v3=E2=80=99:
> >usr/kinit/nfsmount/mount.c:232: error: =E2=80=98MNTPROC_MNT=E2=80=99=
 undeclared
> >(first use in this function)
> >usr/kinit/nfsmount/mount.c: In function =E2=80=98umount_v3=E2=80=99:
> >usr/kinit/nfsmount/mount.c:251: error: =E2=80=98MNTPROC_UMNT=E2=80=99=
 undeclared
> >(first use in this function)
> >make[4]: *** [usr/kinit/nfsmount/mount.o] Error 1
> >make[3]: *** [usr/kinit/nfsmount] Error 2
> >make[2]: *** [all] Error 2
> >make[1]: *** [klibc] Error 2
> >make[1]: Leaving directory `/home/maks/src/klibc-latest'

we might still define those for ourselve, let's see..

