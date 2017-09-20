Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:47419 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750888AbdITElW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Sep 2017 00:41:22 -0400
Received: by mail-it0-f52.google.com with SMTP id z8so1434304itc.2
        for <linux-nfs@vger.kernel.org>; Tue, 19 Sep 2017 21:41:22 -0700 (PDT)
MIME-Version: 1.0
From: RAJESH DASARI <raajeshdasari@gmail.com>
Date: Wed, 20 Sep 2017 10:11:21 +0530
Message-ID: <CAPXMrf9YGS65bcz9cQs-hbQrT+6X8N=uc3zjtvkWM=d_xzwVHg@mail.gmail.com>
Subject: Reg:File system corruption after reboot, when rootfs in mounted over nfs
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi ,

Could some one please help me with the below issue.

I have booted a mips based hardware with linux (4.4.36 kernel )image
and rootfs over nfs by passing nfsroot command line option to the
kernel.

rootfs is mounted under / in my hardware environment.

192.168.113.254:/rootfs / type nfs
(rw,relatime,vers=3,rsize=32768,wsize=32768,namlen=255,hard,nolock,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=192.168.113.254,mountvers=3,mountproto=tcp,local_lock=all,addr=192.168.113.254)

I have a hard disk and i am mounting  it on /mnt , this /mnt directory
is part of nfsroot.

e2fsck -f -y /dev/sda1 -> disk is clean with no errors.

mount -t ext2 /dev/sda1 /mnt
touch /mnt/test.log  -> this command is failing.
umount /mnt
reboot

when i was executing the above commands in a loop i see that /dev/sda1
file system is getting corrupted. touch command is failing with
"cannot touch structure needs clearing" error. I am able to reproduce
this issue always when i boot rootfs over nfs , if i boot from hard
disk , i am not noticing the issue .

Is it could be because of during reboot nfs partition was not
unmounted properly ? will kernel internally takes care of unmouting
nfsroot ?
or nfs flush is not happened ?

Could someone please help me on this .

Thanks,
Rajesh Dasari.
