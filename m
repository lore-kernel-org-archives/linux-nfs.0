Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f180.google.com ([209.85.161.180]:35099 "EHLO
        mail-yw0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932760AbdCMBoJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Mar 2017 21:44:09 -0400
MIME-Version: 1.0
From: Matt Turner <mattst88@gmail.com>
Date: Sun, 12 Mar 2017 18:43:47 -0700
Message-ID: <CAEdQ38HcOgAT6wJWWKY3P0hzYwkBGSQkRSQ2a=eaGmD6c6rwXA@mail.gmail.com>
Subject: NFS corruption, fixed by echo 1 > /proc/sys/vm/drop_caches -- next
 debugging steps?
To: "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>,
        linux-nfs@vger.kernel.org
Cc: Manuel Lauss <manuel.lauss@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On a Broadcom BCM91250a MIPS system I can reliably trigger NFS
corruption on the first file read.

To demonstrate, I downloaded five identical copies of the gcc-5.4.0
source tarball. On the NFS server, they hash to the same value:

server distfiles # md5sum gcc-5.4.0.tar.bz2*
4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2
4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.1
4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.2
4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.3
4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.4

On the MIPS system (the NFS client):

bcm91250a-le distfiles # md5sum gcc-5.4.0.tar.bz2.2
35346975989954df8a8db2b034da610d  gcc-5.4.0.tar.bz2.2
bcm91250a-le distfiles # md5sum gcc-5.4.0.tar.bz2*
4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2
4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.1
35346975989954df8a8db2b034da610d  gcc-5.4.0.tar.bz2.2
4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.3
4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.4

The first file read will contain some corruption, and it is persistent until...

bcm91250a-le distfiles # echo 1 > /proc/sys/vm/drop_caches
bcm91250a-le distfiles # md5sum gcc-5.4.0.tar.bz2*
4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2
4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.1
4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.2
4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.3
4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.4

the caches are dropped, at which point it reads back properly.

Note that the corruption is different across reboots, both in the size
of the corruption and the location. I saw 1900~ and 1400~ byte
sequences corrupted on separate occasions, which don't correspond to
the system's 16kB page size.

I've tested kernels from v3.19 to 4.11-rc1+ (master branch from
today). All exhibit this behavior with differing frequencies. Earlier
kernels seem to reproduce the issue less often, while more recent
kernels reliably exhibit the problem every boot.

How can I further debug this?
