From: Yan Rui <rui.yan@gmail.com>
Subject: How to increase rsize/wsize ?
Date: Mon, 21 Jun 2010 23:29:49 +0800
Message-ID: <AANLkTimkEM7CPctkwYiWa-rGXDs3EHNl-hldu5fQYqRo@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:55967 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932718Ab0FUP3t convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jun 2010 11:29:49 -0400
Received: by pvh11 with SMTP id 11so290970pvh.19
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jun 2010 08:29:49 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I failed to mount a nfs share with a bigger rsize/wsize (in my case,
512K).=A0=A0 The biggest rsize/wsize I can get is only 256KB on my Ubun=
tu
9.10 server box.=A0 Can anyone give me some suggestions?

root@d03:~# exportfs -v
/tmp=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0 <world>(rw,wdelay,root_squash=
,no_subtree_check)

root@d04:~# mount -t nfs -o wsize=3D524288,rsize=3D524288 d03:/tmp /mnt=
/nfs

root@d04:~# nfsstat -m
/mnt/nfs from d03:/tmp
=A0Flags:=A0=A0=A0 rw,relatime,vers=3D3,rsize=3D262144,wsize=3D262144,n=
amlen=3D255,hard,proto=3Dtcp,timeo=3D600,retrans=3D2,sec=3Dsys,mountadd=
r=3D10.0.0.3,mountvers=3D3,mountproto=3Dtcp,addr=3D10.0.0.3

root@d03:~# uname -a
Linux d03 2.6.31-14-server #48-Ubuntu SMP Fri Oct 16 15:07:34 UTC 2009
x86_64 GNU/Linux

root@d03:~# dpkg -l | grep nfs
ii=A0 nfs-common=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0 1:1.2.0-2ubuntu8
 NFS support files common to client and serve
ii=A0 nfs-kernel-server=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
 1:1.2.0-2ubuntu8
 support for NFS kernel server

According to NFS-HOWTO, I have checked the kernel const
NFSSVC_MAXBLKSIZE.  It is 1M on 2.6.31.

Any comments will be appreciated!

Regards,
Rui
