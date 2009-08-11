From: maximilian attems <max-U9r9yeDMy7A@public.gmane.org>
Subject: nfs MNT include cleanup
Date: Tue, 11 Aug 2009 12:44:18 +0200
Message-ID: <20090811104418.GA6175@stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>, klibc@zytor.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:59487 "EHLO
	baikonur.stro.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753084AbZHKMF3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Aug 2009 08:05:29 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2ad780978b7c0c3e7877949f098cbd06e7c73839 broke klibc build
MNTPROC_MNT and MNTPROC_UMNT no longer defined.

usr/kinit/nfsmount/mount.c: In function =E2=80=98mount_call=E2=80=99:
usr/kinit/nfsmount/mount.c:179: error: =E2=80=98MNTPROC_MNT=E2=80=99 un=
declared (first use in this function)
usr/kinit/nfsmount/mount.c:179: error: (Each undeclared identifier is r=
eported only once
usr/kinit/nfsmount/mount.c:179: error: for each function it appears in.=
)
usr/kinit/nfsmount/mount.c: In function =E2=80=98mount_v2=E2=80=99:
usr/kinit/nfsmount/mount.c:211: error: =E2=80=98MNTPROC_MNT=E2=80=99 un=
declared (first use in this function)
usr/kinit/nfsmount/mount.c: In function =E2=80=98umount_v2=E2=80=99:
usr/kinit/nfsmount/mount.c:226: error: =E2=80=98MNTPROC_UMNT=E2=80=99 u=
ndeclared (first use in this function)
usr/kinit/nfsmount/mount.c: In function =E2=80=98mount_v3=E2=80=99:
usr/kinit/nfsmount/mount.c:232: error: =E2=80=98MNTPROC_MNT=E2=80=99 un=
declared (first use in this function)
usr/kinit/nfsmount/mount.c: In function =E2=80=98umount_v3=E2=80=99:
usr/kinit/nfsmount/mount.c:251: error: =E2=80=98MNTPROC_UMNT=E2=80=99 u=
ndeclared (first use in this function)
make[4]: *** [usr/kinit/nfsmount/mount.o] Error 1
make[3]: *** [usr/kinit/nfsmount] Error 2
make[2]: *** [all] Error 2
make[1]: *** [klibc] Error 2
make[1]: Leaving directory `/home/maks/src/klibc-latest'

