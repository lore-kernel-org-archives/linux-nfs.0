Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:60237 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932268Ab1EFVIV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 May 2011 17:08:21 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1QISG3-0006pX-GX
	for linux-nfs@vger.kernel.org; Fri, 06 May 2011 23:08:19 +0200
Received: from inferno.cora.nwra.com ([65.44.101.162])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 06 May 2011 23:08:19 +0200
Received: from orion by inferno.cora.nwra.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 06 May 2011 23:08:19 +0200
To: linux-nfs@vger.kernel.org
From: Orion Poplawski <orion@cora.nwra.com>
Subject: Trouble with krb5 mounts with multiple hostnames/networks
Date: Fri, 6 May 2011 21:08:09 +0000 (UTC)
Message-ID: <loom.20110506T230745-58@post.gmane.org>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We have a setup where some machines have two network connections, one of which
is dedicated for nfs traffic.  The nfs network interface will have a hostname
with a "g" suffix.  e.g. saga's interface on the nfs network is called "sagag".

This has worked fine for years with nfs3, and am now testing out nfs4/krb5.  I
can connect fine with the normal hostname, but trying with the nfs network name
fails:

# mount -t nfs4 -o sec=krb5  alexandriag:/cora2 /mnt
mount.nfs4: Permission denied

I've added krb5 nfs principals for both hostnames in each machine's
/etc/krb5.keytab.

I'm running centos 5.6 with nfs-utils-1.0.9-50.el5.

Is there any hope of this working with nfs4/krb5?  Or is this just not going to
fly because of hostname authentication issues?



