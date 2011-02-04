Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51932 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750799Ab1BDOrW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Feb 2011 09:47:22 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p14ElMiv000708
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 4 Feb 2011 09:47:22 -0500
Received: from badhat.bos.devel.redhat.com (vpn-11-151.rdu.redhat.com [10.11.11.151])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id p14ElLPG022186
	for <linux-nfs@vger.kernel.org>; Fri, 4 Feb 2011 09:47:21 -0500
Message-ID: <4D4C1178.2020607@RedHat.com>
Date: Fri, 04 Feb 2011 09:47:20 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Updated the pNFS Developmental Repository
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,

I've just updated the kernel rpm in the pNFS development repository to include:
    * The latest pNFS kernel bits (pnfs-all-2.6.38-rc3-2011-02-03)
Which is basically the wave3 code with a few bug fixes.

The nfs-utils release stayed the same (pnfs-nfs-utils-1-2-4-rc5) and
again, the Fedora 13 and 14 repository were NOT updated, just the devel.

Instructions on how to install and use these kernels are at:
http://wiki.linux-nfs.org/wiki/index.php/Fedora_pNFS_Client_Setup

 If/when bugs are found with these rpms please enter them
in to the NFS Bugzilla Main Page at:
    https://bugzilla.linux-nfs.org/index.cgi

Please use the "pNFS" keyword.. 

Any question or issues please feel free to contact me... 

steved.

