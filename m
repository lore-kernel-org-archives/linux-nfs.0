Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38221 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751964Ab1CZSIR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 26 Mar 2011 14:08:17 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p2QI8H4H023182
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Sat, 26 Mar 2011 14:08:17 -0400
Received: from badhat.bos.devel.redhat.com (vpn-8-247.rdu.redhat.com [10.11.8.247])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id p2QI8Gd7032674
	for <linux-nfs@vger.kernel.org>; Sat, 26 Mar 2011 14:08:16 -0400
Message-ID: <4D8E2B90.4030100@RedHat.com>
Date: Sat, 26 Mar 2011 14:08:16 -0400
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
    * The latest nfs-utils release (pnfs-nfs-utils-1-2-4-rc5)
    * The latest pNFS kernel bits (pnfs-all-2.6.38-2011-03-25)

These latest bits are *only* in the Fedora 15 repo. The Fedora 13, 14 
repos remained the same and the devel (or rawhide) repo was removed.

Instructions on how to install and use these kernels are at:
http://wiki.linux-nfs.org/wiki/index.php/Fedora_pNFS_Client_Setup

 If/when bugs are found with these rpms please enter them
in to the NFS Bugzilla Main Page at:
    https://bugzilla.linux-nfs.org/index.cgi

Please use the "pNFS" keyword.. 

Any question or issues please feel free to contact me... 

steved.
