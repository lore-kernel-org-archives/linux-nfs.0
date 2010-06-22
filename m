From: Yan Rui <rui.yan@gmail.com>
Subject: Re: How to increase rsize/wsize ?
Date: Tue, 22 Jun 2010 11:20:56 +0800
Message-ID: <AANLkTilOZZyoXHypeILWYRlWi6PBV5jXNinSe4jbpmNC@mail.gmail.com>
References: <AANLkTimkEM7CPctkwYiWa-rGXDs3EHNl-hldu5fQYqRo@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:41183 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758758Ab0FVDU5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jun 2010 23:20:57 -0400
Received: by pwj8 with SMTP id 8so656602pwj.19
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jun 2010 20:20:56 -0700 (PDT)
In-Reply-To: <AANLkTimkEM7CPctkwYiWa-rGXDs3EHNl-hldu5fQYqRo-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

More info on this issue..

The client and server are directly conected  to a gigabit switch. The
MTU is default 1500.  Server and client (in my case, d03 and d04) are
with the same hardware, OS and configurations.

Thanks,
Rui

On Mon, Jun 21, 2010 at 11:29 PM, Yan Rui <rui.yan@gmail.com> wrote:
> Hi,
>
> I failed to mount a nfs share with a bigger rsize/wsize (in my case,
> 512K).=A0=A0 The biggest rsize/wsize I can get is only 256KB on my Ub=
untu
> 9.10 server box.=A0 Can anyone give me some suggestions?
>
> root@d03:~# exportfs -v
> /tmp=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0 <world>(rw,wdelay,root_squa=
sh,no_subtree_check)
>
> root@d04:~# mount -t nfs -o wsize=3D524288,rsize=3D524288 d03:/tmp /m=
nt/nfs
>
> root@d04:~# nfsstat -m
> /mnt/nfs from d03:/tmp
> =A0Flags:=A0=A0=A0 rw,relatime,vers=3D3,rsize=3D262144,wsize=3D262144=
,namlen=3D255,hard,proto=3Dtcp,timeo=3D600,retrans=3D2,sec=3Dsys,mounta=
ddr=3D10.0.0.3,mountvers=3D3,mountproto=3Dtcp,addr=3D10.0.0.3
>
> root@d03:~# uname -a
> Linux d03 2.6.31-14-server #48-Ubuntu SMP Fri Oct 16 15:07:34 UTC 200=
9
> x86_64 GNU/Linux
>
> root@d03:~# dpkg -l | grep nfs
> ii=A0 nfs-common=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0 1:1.2.0-2ubuntu8
> =A0NFS support files common to client and serve
> ii=A0 nfs-kernel-server=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
 1:1.2.0-2ubuntu8
> =A0support for NFS kernel server
>
> According to NFS-HOWTO, I have checked the kernel const
> NFSSVC_MAXBLKSIZE. =A0It is 1M on 2.6.31.
>
> Any comments will be appreciated!
>
> Regards,
> Rui
>
