Return-Path: linux-nfs-owner@vger.kernel.org
Received: from lo.gmane.org ([80.91.229.12]:44730 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932696Ab1LEXv2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Dec 2011 18:51:28 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1RXiJf-0006Kr-Sf
	for linux-nfs@vger.kernel.org; Tue, 06 Dec 2011 00:51:26 +0100
Received: from NORTHWEST-R.car1.Denver1.Level3.net ([4.28.99.98])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 06 Dec 2011 00:51:23 +0100
Received: from orion by NORTHWEST-R.car1.Denver1.Level3.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 06 Dec 2011 00:51:23 +0100
To: linux-nfs@vger.kernel.org
From: Orion Poplawski <orion@cora.nwra.com>
Subject: Any update on gss/krb5 =?utf-8?b?bm9fcm9vdF9zcXVhc2g=?= issue
Date: Mon, 5 Dec 2011 23:51:13 +0000 (UTC)
Message-ID: <loom.20111206T004837-282@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The HOWTO mentions:

4.5 A known issue using NFS with kerberos
_________________________________________

Even if "no_root_squash" option is used, while exporting a filesystem at the 
server, root on the client gets a "Permission denied"  error when creating 
files on the mount point.

This is because there is no proper mapping between root and the GSSAuthName.


And indeed, I continue to see this on Fedora 16.  Are there any better
workarounds for this now?  Any hope of this getting fixed?  I need to have root
access to certain directories, mainly for backups.

Thanks!

 - Orion Poplawski

