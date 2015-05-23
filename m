Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailsrv.ikr.uni-stuttgart.de ([129.69.170.2]:38869 "EHLO
	mailsrv.ikr.uni-stuttgart.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754116AbbEWSDo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 23 May 2015 14:03:44 -0400
Received: from netsrv1.ikr.uni-stuttgart.de (netsrv1-c [10.11.12.12])
	by mailsrv.ikr.uni-stuttgart.de (Postfix) with ESMTP id C000D600C4
	for <linux-nfs@vger.kernel.org>; Sat, 23 May 2015 19:58:27 +0200 (CEST)
Received: from vpn-2-cl144 (vpn-2-cl144 [10.41.21.144])
	by netsrv1.ikr.uni-stuttgart.de (Postfix) with ESMTP id AC5BA600C1
	for <linux-nfs@vger.kernel.org>; Sat, 23 May 2015 19:58:27 +0200 (CEST)
From: Ulrich Gemkow <ulrich.gemkow@ikr.uni-stuttgart.de>
To: linux-nfs@vger.kernel.org
Subject: NFSv3-mounting of BTRFS-FS fails, gives ESTALE
Date: Sat, 23 May 2015 19:58:11 +0200
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Message-Id: <201505231958.13619.ulrich.gemkow@ikr.uni-stuttgart.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

[sent this to linux-btrfs mailing list but got no answer,
maybe this is the better list].

we export a BTRFS-filesystem via NFSv3 and tried to mount
this share on a client (also NFSv3). The mount program on the
client hangs and the mount fails.

Server and client use vanilla Linux kernel 4.0.3, the distro
is Ubuntu 14.04.02, btrfs-progs are version 4.0.

Exporting of other filesystems (ext4) and mounting them in
the exactly same setup works, so this seems to be BTRFS-related.

strace-ing the mount-call on the client shows that the mount
syscall returns ESTALE errors and mount enters a loop which
leads to the hang of the mount-program in user land.

I applied the patch of Neil Brown (which should help with
NFS v2) in [1]. The behaviour without and with this patch
is the same.

This seems to be a regression because from the lists I
saw that NFS-exporting of BTRFS is supposed to work
(but NFSv3 is not explicitely mentioned there).

Is this a bug? I am more than willing to help with more
diagnosis.

Thank you and best regards

Ulrich



[1] https://lkml.org/lkml/2015/5/7/1013

-- 
|-----------------------------------------------------------------------
| Ulrich Gemkow
| University of Stuttgart
| Institute of Communication Networks and Computer Engineering (IKR)
|-----------------------------------------------------------------------
