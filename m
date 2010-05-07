Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8498 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756532Ab0EGQMK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 May 2010 12:12:10 -0400
Received: from int-mx08.intmail.prod.int.phx2.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o47GC9wM019010
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 7 May 2010 12:12:09 -0400
Received: from badhat.bos.devel.redhat.com (vpn-225-76.phx2.redhat.com [10.3.225.76])
	by int-mx08.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o47GC8St030843
	for <linux-nfs@vger.kernel.org>; Fri, 7 May 2010 12:12:09 -0400
Message-ID: <4BE43BD8.5000201@RedHat.com>
Date: Fri, 07 May 2010 12:12:08 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [pnfs] Updated pNFS Developmental kernel repository
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,

I've updated the Fedora pNFS development kernels to include 
the latest pNFS tag release: 
    pnfs-all-2.6.33-2010-05-06     (Fedora 13)
    pnfs-all-2.6.34-rc6-2010-05-06 (Fedora devel)

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
