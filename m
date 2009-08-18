From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: nfs MNT include cleanup
Date: Tue, 18 Aug 2009 08:45:49 -0400
Message-ID: <86201444-2DDC-47B0-A92E-81CB19224CCB@oracle.com>
References: <20090811104418.GA6175@stro.at> <C7D2AC7D-48B2-4206-A6B1-3780FE7D51CE@oracle.com> <20090818103653.GB3954@stro.at>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=WINDOWS-1252;
	format=flowed	delsp=yes
Cc: linux-nfs@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>, klibc@zytor.com
To: maximilian attems <max-U9r9yeDMy7A@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:56849 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385AbZHRMqA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Aug 2009 08:46:00 -0400
In-Reply-To: <20090818103653.GB3954-U9r9yeDMy7A@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 18, 2009, at 6:36 AM, maximilian attems wrote:
> On Tue, 11 Aug 2009, Chuck Lever wrote:
>
>> On Aug 11, 2009, at 6:44 AM, maximilian attems wrote:
>>> 2ad780978b7c0c3e7877949f098cbd06e7c73839 broke klibc build
>>> MNTPROC_MNT and MNTPROC_UMNT no longer defined.
>>
>> I assume then that klibc is out of tree?  I can't find it in my
>> kernel repo.
>
> sorry for late reply, indeed you'll find it here:
> http://git.kernel.org/?p=3Dlibs/klibc/klibc.git;a=3Dsummary
>
>>> usr/kinit/nfsmount/mount.c: In function =91mount_call=92:
>>> usr/kinit/nfsmount/mount.c:179: error: =91MNTPROC_MNT=92 undeclared
>>> (first use in this function)
>>> usr/kinit/nfsmount/mount.c:179: error: (Each undeclared identifier
>>> is reported only once
>>> usr/kinit/nfsmount/mount.c:179: error: for each function it
>>> appears in.)
>>> usr/kinit/nfsmount/mount.c: In function =91mount_v2=92:
>>> usr/kinit/nfsmount/mount.c:211: error: =91MNTPROC_MNT=92 undeclared
>>> (first use in this function)
>>> usr/kinit/nfsmount/mount.c: In function =91umount_v2=92:
>>> usr/kinit/nfsmount/mount.c:226: error: =91MNTPROC_UMNT=92 undeclare=
d
>>> (first use in this function)
>>> usr/kinit/nfsmount/mount.c: In function =91mount_v3=92:
>>> usr/kinit/nfsmount/mount.c:232: error: =91MNTPROC_MNT=92 undeclared
>>> (first use in this function)
>>> usr/kinit/nfsmount/mount.c: In function =91umount_v3=92:
>>> usr/kinit/nfsmount/mount.c:251: error: =91MNTPROC_UMNT=92 undeclare=
d
>>> (first use in this function)
>>> make[4]: *** [usr/kinit/nfsmount/mount.o] Error 1
>>> make[3]: *** [usr/kinit/nfsmount] Error 2
>>> make[2]: *** [all] Error 2
>>> make[1]: *** [klibc] Error 2
>>> make[1]: Leaving directory `/home/maks/src/klibc-latest'
>
> we might still define those for ourselve, let's see..

That makes sense to me as an immediate fix.

However, the kernel has its own NFS mount client (the piece that =20
handles rpcbind query and obtaining the root file handle), and you can =
=20
pass a C string of mount options to the kernel with mount(2).  Perhaps =
=20
in the long term, you might consider replacing the specialized code in =
=20
klibc with simply passing the server, export path, and mount options =20
right to the kernel and let it do the work.  This should work with any =
=20
kernel later than 2.6.23.

I'm happy to help with any questions.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com