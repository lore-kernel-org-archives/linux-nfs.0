Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from byte.disi.unige.it ([130.251.61.174]:59807 "EHLO
	byte.disi.unige.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753457AbcHQUx3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Aug 2016 16:53:29 -0400
Received: from byte.disi.unige.it (localhost [127.0.0.1])
	by byte.disi.unige.it (8.15.2/8.15.2) with ESMTP id u7HK8G73001488
	for <linux-nfs@vger.kernel.org>; Wed, 17 Aug 2016 22:08:16 +0200
Received: from localhost (ciaccio@localhost)
	by byte.disi.unige.it (8.15.2/8.15.2/Submit) with ESMTP id u7HK8Gor001484
	for <linux-nfs@vger.kernel.org>; Wed, 17 Aug 2016 22:08:16 +0200
Date: Wed, 17 Aug 2016 22:08:16 +0200 (CEST)
From: Giuseppe Ciaccio <giuseppe.ciaccio@unige.it>
To: linux-nfs@vger.kernel.org
Subject: mismatching defaults between nfs-utils and linux/fs/nfs/nfsroot.c
Message-ID: <alpine.LNX.2.20.1608172154080.1437@byte.disi.unige.it>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

my cluster, made of a front-end server + a number of diskless nodes, was no longer working last week after an upgrade to Slackware 14.2.  The diskless nodes were unable to load the root file system via NFS.  It turned out that the problem was due to a mismatch between the default behaviour of the user-space part of the NFS stack (nfs-utils) and the kernel-space part (linux/fs/nfs/nfsroot.c).  The former, by recently changed default, runs protocols V3 and V4 but no longer V2, whereas the latter still uses V2 as the default.

Solved by changing /etc/dhcpd.conf so as to advice diskless nodes to user V3 instead of the default.

I think it is not a good idea, that the two parts of the NFS stack use incompatible defaults.  So I'd suggest to fix this.

Regards,

Giuseppe Ciaccio                http://www.dibris.unige.it/ciaccio-giuseppe
DIBRIS - Universita' di Genova  via Dodecaneso 35    16146 Genova,    Italy
giuseppe.ciaccio@unige.it       phone +390103536663       fax +390103536699
---------------------------------------------------------------------------
