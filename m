Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29488 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751278Ab1A1VWr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Jan 2011 16:22:47 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id p0SLMlOL025169
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 28 Jan 2011 16:22:47 -0500
Received: from badhat.bos.devel.redhat.com (vpn-9-223.rdu.redhat.com [10.11.9.223])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p0SLMkNk001759
	for <linux-nfs@vger.kernel.org>; Fri, 28 Jan 2011 16:22:46 -0500
Message-ID: <4D4333A6.70304@RedHat.com>
Date: Fri, 28 Jan 2011 16:22:46 -0500
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
    * The latest pNFS kernel bits (pnfs-all-2.6.38-rc2-2011-01-27)

The Fedora 13 and 14 repository were NOT updated, just the devel.

Instructions on how to install and use these kernels are at:
http://wiki.linux-nfs.org/wiki/index.php/Fedora_pNFS_Client_Setup

 If/when bugs are found with these rpms please enter them
in to the NFS Bugzilla Main Page at:
    https://bugzilla.linux-nfs.org/index.cgi

Please use the "pNFS" keyword.. 

Any question or issues please feel free to contact me... 

steved.

