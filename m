Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21492 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754055Ab0KIUQ2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Nov 2010 15:16:28 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id oA9KGRPs027758
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 9 Nov 2010 15:16:28 -0500
Received: from badhat.bos.devel.redhat.com (badhat.boston.devel.redhat.com [10.16.60.49])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id oA9KGRHF009951
	for <linux-nfs@vger.kernel.org>; Tue, 9 Nov 2010 15:16:27 -0500
Message-ID: <4CD9AC1A.707@RedHat.com>
Date: Tue, 09 Nov 2010 15:16:26 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Updated the pNFS Developmental Repository
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,

I've just updated the kernel and nfs-utils rpms in the pNFS development 
repository to include:
    * The latest nfs-utils release (pnfs-utils-1-2-4-rc1)
    * The latest pNFS kernel bits (pnfs-all-2.6.36-2010-11-03)

Note: In this update there is only one kernel type (fc15)
due to the fact both Fedora 13 and 14 are still on 2.6.35
kernels which means the pnfs-all-2.6.36 patch will not apply 
cleaning. I have booted this new kernel on both Fedora 13
and 14 without issue... 

These nfs-utils rpms will now install the blkmapd init script
and the /etc/modprobe.d/nfsv41.conf file which hopeful 
get the correct modules installed on the client.

Instructions on how to install and use these kernels are at:
http://wiki.linux-nfs.org/wiki/index.php/Fedora_pNFS_Client_Setup

 If/when bugs are found with these rpms please enter them
in to the NFS Bugzilla Main Page at:
    https://bugzilla.linux-nfs.org/index.cgi

Please use the "pNFS" keyword.. 

Any question or issues please feel free to contact me... 

steved.
