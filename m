Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:44329 "EHLO mout.perfora.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726888AbeHQVHh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Aug 2018 17:07:37 -0400
Received: from null ([10.72.76.58]) by mrelay.perfora.net (mreueus003
 [74.208.5.2]) with ESMTPSA (Nemesis) id 0MCrWX-1fh8ce22k7-009eNL for
 <linux-nfs@vger.kernel.org>; Fri, 17 Aug 2018 19:58:15 +0200
Date: Fri, 17 Aug 2018 12:58:15 -0500 (CDT)
From: Ryan Covietz <ryan.covietz@metakrypt.com>
Reply-To: Ryan Covietz <ryan.covietz@metakrypt.com>
To: linux-nfs@vger.kernel.org
Message-ID: <1377475602.793145.1534528695060@email.1and1.com>
Subject: Linux NFS Client and NFS v4.1 Session Trunking
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Greetings all,

Apologies in advance if this mailing list is not the correct forum for my
inquiry.

Background:
I've successfully tested NFS session trunking on the server side with Debian
Stretch and the v4.17.8-1~bpo9+1 backports kernel, nfs-kernel-server v1:1.3.4-2.1, and using VMware ESXi 6.7.0 as a client (session trunking even works with bonded interfaces on the server side!).
Unfortunately, I've had no luck with getting session trunking to work
with the Linux NFS client (nfs-common version 1:1.3.4-2.1 on Debian) both on
Debian Stretch and on Fedora 28 using the "mount -t nfs4 -o minorversion=1"
options to mount an export multiple times over different interfaces / IPs.

Documentation on the NFS session trunking feature seems to be sparse to non-existent, and the only tested client configuration I found was by Martin Houry a couple of years ago:

https://marc.info/?l=linux-nfs&m=145570512215071&w=2

...not clear if the patches he tested were ever integrated into the Linux kernel though? I just wanted to inquire if the NFS v4.1 session trunking functionality has been integrated into the Linux NFS client yet?

Any clarification or direction would be greatly appreciated.

Thank you in advance and best regards,

Ryan
