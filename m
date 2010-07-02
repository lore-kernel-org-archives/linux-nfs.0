Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52025 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752223Ab0GBFac (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Jul 2010 01:30:32 -0400
Received: from int-mx05.intmail.prod.int.phx2.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.18])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o625UVmj032717
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 2 Jul 2010 01:30:31 -0400
Received: from badhat.bos.devel.redhat.com (vpn-227-231.phx2.redhat.com [10.3.227.231])
	by int-mx05.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o625UTBk000922
	for <linux-nfs@vger.kernel.org>; Fri, 2 Jul 2010 01:30:30 -0400
Message-ID: <4C2D7974.6020306@RedHat.com>
Date: Fri, 02 Jul 2010 01:30:28 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Updated pNFS Developmental kernel repository
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,

I've updated the Fedora pNFS development kernels to include 
the latest pNFS tag release: 
    pnfs-all-2.6.34-2010-07-01         (Fedora 13)
    pnfs-all-2.6.35-rc3-2010-06-01     (Fedora devel)

There were no changes to the Fedora 12 kernels or the
pNFS-aware nfs-utils rpms. 

Instructions on how to install and use these kernels are at:
http://wiki.linux-nfs.org/wiki/index.php/Fedora_pNFS_Client_Setup

 
If/when bugs are found with these rpms please enter them
in to the NFS Bugzilla Main Page at:
    https://bugzilla.linux-nfs.org/index.cgi

Please use the "pNFS" keyword.. 

Any question or issues please feel free to contact me... 

steved.
