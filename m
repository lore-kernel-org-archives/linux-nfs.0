Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f183.google.com ([209.85.221.183]:50170 "EHLO
	mail-qy0-f183.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753954Ab0EJJUL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 May 2010 05:20:11 -0400
Received: by qyk13 with SMTP id 13so5792580qyk.1
        for <linux-nfs@vger.kernel.org>; Mon, 10 May 2010 02:20:10 -0700 (PDT)
Date: Mon, 10 May 2010 02:20:10 -0700
Message-ID: <AANLkTinyu2l0ykkWfqjHQV2HW9g5rPvWIj-DX6dnDBbI@mail.gmail.com>
Subject: NFS hang when writing to loopback file from VMWare ESX (kernel
	2.6.30)
From: Beast in Black <beast.in.black@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Greetings.

Every so often, when i'm writing via NFS to a loopback-mounted file, i
find that about 10-15 nfsd threads (out of a total of 64) go into D
state, along with the loop file, and never recover from the D state.
My setup is as follows:

1. sparse file is created via dd and loopback-mounted onto a
/dev/loopX device (where 0<= X <= 100)
2. sparse file is mke2fs'd and mounted on mount point "/volumes/localvol"
3. "/volumes/localvol" is exported with options
*(rw,no_root_squash,no_subtree_check,async,insecure,nohide,no_wdelay).
4. /volumes/localvol is set as a network datastore (NFS mount) in ESX
5. Virtual machine files for an ESX VM are copied into the NFS mount on ESX
6. Virtual machine is powered on and I do some activity in it...write files etc.

At this point, the VM is running fine in ESX. After a while, however,
I notice that the VM freezes and that ESX reports the NFS mounted
datastore as unreachable. When I check the NFS server machine, I find
that 10-15 NFS threads are in D state, along with the associated
loopback-mounted file. The D states are never recovered from, and the
only way out is to reboot the NFS server machine.

I have also tried with specifying the export as "sync" instead of
"async" (and removing no_wdelay) but I still see the same behavior.

The NFS server is running the vanilla 2.6.30 kernel on Ubuntu 8.10.
The NFS exports are all NFSv3.

Does anyone have an idea of why this may be occurring? I would be glad
to provide any additional info required.

Regards.



--
Time flies like an arrow
Fruit flies like a banana
