From: Billy Hass <billdh16@gmail.com>
Subject: Unable to Compile Latest Kernel from Git
Date: Fri, 5 Aug 2011 21:58:54 -0400
Message-ID: <CALPVbefsY4Ddw6QOZu9BckCx+Q0YJg8tgbjK6xN5sQxbpdD16w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:65351 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346Ab1HFB64 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Aug 2011 21:58:56 -0400
Received: by fxh19 with SMTP id 19so3371906fxh.19
        for <linux-nfs@vger.kernel.org>; Fri, 05 Aug 2011 18:58:55 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey all,

I am unable to compile the latest kernel from the git tree.

git clone git://git.linux-nfs.org/projects/bhalevy/linux-pnfs.git
cd linux-pnfs
make oldconfig
make -j5 -s
=A0=A0=A0=A0 [ ... ]
=A0=A0=A0=A0 [A lot of warnings, but no errors]
=A0=A0=A0=A0 [ ... ]
make install
=A0=A0=A0=A0 sh /usr/src/kernels/3.0.0/linux-
     pnfs/arch/x86/boot/install.sh 3.0.0-pnfs arch/x86/boot/bzImage \
=A0=A0 =A0 =A0 =A0 System.map "/boot"
=A0 =A0 =A0 *** Missing file: arch/x86/boot/bzImage
=A0=A0=A0=A0=A0 *** You need to run "make" before "make install".
=A0=A0=A0=A0 make[1]: *** [install] Error 1
=A0=A0=A0=A0 make: *** [install] Error 2

When I try to do the make again, here is the output
make -j5 -s
=A0=A0=A0=A0 fs/nfsd/built-in.o: In function `pnfs_roc':
=A0=A0=A0=A0 (.text+0x226d1): multiple definition of `pnfs_roc'
=A0=A0=A0=A0 fs/nfs/built-in.o:(.text+0x304ee): first defined here
=A0=A0=A0=A0 make[1]: *** [fs/built-in.o] Error 1
=A0=A0=A0=A0 make: *** [fs] Error 2
=A0=A0=A0=A0 make: *** Waiting for unfinished jobs....

Thanks for any help!

Bill

--
Bill D. Hass
Major | Electrical Engineering BSE
Minor | Mathematics
University of Michigan '13
College of Engineering
(715) 923-8382
