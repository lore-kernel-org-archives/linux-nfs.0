Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from agate.clustertech.com ([103.31.20.128]:44780 "EHLO
        agate.clustertech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752733AbeC1BVA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Mar 2018 21:21:00 -0400
Date: Wed, 28 Mar 2018 09:14:17 +0800
From: Dai Qizhi <qzdai@clustertech.com>
To: Amir Goldstein <amir73il@gmail.com>
Subject: Re: client side see wrong directory entries with nfs_export on overlayfs
Cc: linux-nfs@vger.kernel.org, linux-unionfs@vger.kernel.org
In-Reply-To: <CAOQ4uxgtD1F_S_tGoAKo7egqbXRGa-sM6SL-Ab7K62LN0FYBSA@mail.gmail.com>
References: <20180327182450.38D9.733CD922@clustertech.com> <CAOQ4uxgtD1F_S_tGoAKo7egqbXRGa-sM6SL-Ab7K62LN0FYBSA@mail.gmail.com>
Message-Id: <20180328091413.38DF.733CD922@clustertech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> 2018-03-27 13:24 GMT+03:00 Dai Qizhi <qzdai@clustertech.com>:
> > Dear Amir Goldstein,
> >
> 
> Hi Dai,
> 
> Do you mind if I re-posting your question to overlayfs mailing list.
> There are other people out there that would encounter the same
> problem and will benefit from my answer.

no problem. 
> 
> > I tested overlayfs with nfs_export feature , the kernel is built by
> > ubuntu , 4.16.0-041600rc7, http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.16-rc7/
> >
> > the problem is , when i export two different overlay mount points on
> > server side, then mount them use nfs on the client side, the client side
> > views the two differnet mount points as the same.
> >
> >
> > on server side:
> >
> > none on /mnt/m1 type overlay (rw,relatime,lowerdir=m1/ro,upperdir=m1/rw,workdir=
> > m1/w,index=on,nfs_export=on)
> > none on /mnt/m2 type overlay (rw,relatime,lowerdir=m2/ro,upperdir=m2/rw,workdir=
> > m2/w,index=on,nfs_export=on)
> > [root@localhost data]# exportfs -rv
> > exporting *:/mnt/m4
> > exporting *:/mnt/m3
> > exporting *:/mnt/m2
> > exporting *:/mnt/m1
> > [root@localhost data]# ls /mnt/m1
> > this_is_m1
> > [root@localhost data]# ls /mnt/m2
> > this_is_m2
> >
> >
> > on client side:
> >
> > [root@localhost mnt]# mount 192.168.0.1:/mnt/m1 m1
> > [root@localhost mnt]# mount 192.168.0.1:/mnt/m2 m2
> > [root@localhost mnt]# mount |grep 192
> > 192.168.0.1:/mnt/m1 on /mnt/m1 type nfs (rw,relatime,vers=3,rsize=524288,wsize=5
> > 24288,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=192.168.0.
> > 1,mountvers=3,mountport=20048,mountproto=udp,local_lock=none,addr=192.168.0.1)
> > 192.168.0.1:/mnt/m1 on /mnt/m2 type nfs (rw,relatime,vers=3,rsize=524288,wsize=5
> > 24288,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=192.168.0.
> > 1,mountvers=3,mountport=20048,mountproto=udp,local_lock=none,addr=192.168.0.1)
> >
> > [root@localhost mnt]# ls /mnt/m1
> > this_is_m1
> > [root@localhost mnt]# ls /mnt/m2
> > this_is_m1
> > [root@localhost mnt]#
> 
> 
> Please refer to the man page of exports(5), the section about 'fsid' describes
> this problem related to exporting file systems that are not on a block device,
> such as overlayfs.

yes, export different mount point with different fsid= option works as
expected.


> 
> If you are interested to know if there is a way to fix this that does
> not involve manually
> configuring different fsid per export, I will have to consult with the
> NFS experts, so please
> reply to this message with CC to <linux-unionfs@vger.kernel.org> and
> <linux-nfs@vger.kernel.org>

when exporting parent directory with crossmnt option and mount differnet overlayfs
under that directory, we encounter the same problem on client side.. 

> 
> Thanks,
> Amir.

Best regards,
Dai Qizhi

