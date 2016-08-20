Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from such.a.cut3.name ([176.9.57.153]:49563 "EHLO such.a.cut3.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751532AbcHTTTG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 20 Aug 2016 15:19:06 -0400
To: linux-nfs@vger.kernel.org
From: Karsten Hohmeier <karsten@hohmatik.de>
Subject: Un-unmountable NFS mountpoints with "Stale NFS file handle" - is this
 normal behavior?
Message-ID: <b0e2b37b-5d90-ea9c-46e9-be577c4da634@hohmatik.de>
Date: Sat, 20 Aug 2016 21:03:36 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dear NFS list members,

I recently contacted a few active NFS devs with an issue i ran into:

We run a XenServer 6.5 (Kernel 3.10) with an older version of nfs-utils
(1.0.9). NFS mountpoints on that machine acting as a client can not be
unmounted (not even forcibly or lazy) after the connection to the NFS
server broke for some reason.

Most commands fail with "Stale NFS file handle".

The Internet tells me this situation is unfixable and requires a reboot
of the client to resolve. This is a pretty bad solution on a heavily
loaded virtualization host.

The response of Bruce Fields was: "Sounds like normal behavior, ..."
(Sorry for not posting to the list in the first place, btw.)

I'm still looking for some explanation why this happens, how it can be
considered "normal behavior" and if it can be fixed/avoided/mitigated
without rebooting.

Best regards

Karsten Hohmeier

