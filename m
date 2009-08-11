From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: nfs MNT include cleanup
Date: Tue, 11 Aug 2009 14:55:32 -0400
Message-ID: <C7D2AC7D-48B2-4206-A6B1-3780FE7D51CE@oracle.com>
References: <20090811104418.GA6175@stro.at>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=WINDOWS-1252;
	format=flowed	delsp=yes
Cc: linux-nfs@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>, klibc@zytor.com
To: maximilian attems <max-U9r9yeDMy7A@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:37518 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030AbZHKS4M convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Aug 2009 14:56:12 -0400
In-Reply-To: <20090811104418.GA6175-U9r9yeDMy7A@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 11, 2009, at 6:44 AM, maximilian attems wrote:
> 2ad780978b7c0c3e7877949f098cbd06e7c73839 broke klibc build
> MNTPROC_MNT and MNTPROC_UMNT no longer defined.

I assume then that klibc is out of tree?  I can't find it in my kernel =
=20
repo.

> usr/kinit/nfsmount/mount.c: In function =91mount_call=92:
> usr/kinit/nfsmount/mount.c:179: error: =91MNTPROC_MNT=92 undeclared =20
> (first use in this function)
> usr/kinit/nfsmount/mount.c:179: error: (Each undeclared identifier =20
> is reported only once
> usr/kinit/nfsmount/mount.c:179: error: for each function it appears =20
> in.)
> usr/kinit/nfsmount/mount.c: In function =91mount_v2=92:
> usr/kinit/nfsmount/mount.c:211: error: =91MNTPROC_MNT=92 undeclared =20
> (first use in this function)
> usr/kinit/nfsmount/mount.c: In function =91umount_v2=92:
> usr/kinit/nfsmount/mount.c:226: error: =91MNTPROC_UMNT=92 undeclared =
=20
> (first use in this function)
> usr/kinit/nfsmount/mount.c: In function =91mount_v3=92:
> usr/kinit/nfsmount/mount.c:232: error: =91MNTPROC_MNT=92 undeclared =20
> (first use in this function)
> usr/kinit/nfsmount/mount.c: In function =91umount_v3=92:
> usr/kinit/nfsmount/mount.c:251: error: =91MNTPROC_UMNT=92 undeclared =
=20
> (first use in this function)
> make[4]: *** [usr/kinit/nfsmount/mount.o] Error 1
> make[3]: *** [usr/kinit/nfsmount] Error 2
> make[2]: *** [all] Error 2
> make[1]: *** [klibc] Error 2
> make[1]: Leaving directory `/home/maks/src/klibc-latest'

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com