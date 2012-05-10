Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:51566 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756549Ab2EJUZE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 May 2012 16:25:04 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1SSZv3-00011i-DI
	for linux-nfs@vger.kernel.org; Thu, 10 May 2012 22:25:01 +0200
Received: from NORTHWEST-R.edge3.Denver1.Level3.net ([4.28.99.98])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 10 May 2012 22:25:01 +0200
Received: from orion by NORTHWEST-R.edge3.Denver1.Level3.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 10 May 2012 22:25:01 +0200
To: linux-nfs@vger.kernel.org
From: Orion Poplawski <orion@cora.nwra.com>
Subject: Cannot unmount nfs4 sec=krb5 mount if network is down
Date: Thu, 10 May 2012 20:24:53 +0000 (UTC)
Message-ID: <loom.20120510T222025-23@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

See https://bugzilla.redhat.com/show_bug.cgi?id=820707

We're using nfs4/krb5 mounts via autofs (although I get the same result without
autofs and mounting the directory directly):

earth:/export/home/orion on /home/orion type nfs4
(rw,noatime,vers=4,rsize=32768,wsize=32768,namlen=255,acregmin=1,acregmax=1,
acdirmin=1,acdirmax=1,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=krb5,
clientaddr=10.10.30.4,minorversion=0,local_lock=none,addr=10.10.10.1)

If the network is disconnected it is impossible to unmount, even if no
processes are accessing the mount.  umount -f and umount -l both hang on
readlink("/home/orion").  At this point it is impossible to shutdown cleanly
and you must hold the power button down until the machine powers off.

I can unmount non-krb5 nfs4/nfs3 mounts just fine.

I tried running rpc.gssd and nfsidmap with -vvv but nothing else showed up in
the log.

Sometimes get:

May 10 12:00:10 makani kernel: [ 2018.272071] nfs: server earth not responding,
still trying

but that's it.  I can exit umount -l with ctrl-c.

Version-Release number of selected component (if applicable):
nfs-utils-1.2.5-15.fc17.x86_64
3.3.4-5.fc17.x86_64

How reproducible:
Every time

Steps to Reproduce:
1. mount nfs4 sec=krb5 mount
2. pull network
3. umount -l <mount>

Actual results:
umount -l hangs

Expected results:
umount succeeds, perhaps with delay.


