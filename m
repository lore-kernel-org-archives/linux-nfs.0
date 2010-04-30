Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13204 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756467Ab0D3Upt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Apr 2010 16:45:49 -0400
Received: from int-mx08.intmail.prod.int.phx2.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o3UKjnBH025008
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 30 Apr 2010 16:45:49 -0400
Received: from badhat.bos.devel.redhat.com (vpn-240-64.phx2.redhat.com [10.3.240.64])
	by int-mx08.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o3UKjmLL030098
	for <linux-nfs@vger.kernel.org>; Fri, 30 Apr 2010 16:45:49 -0400
Message-ID: <4BDB417C.2090505@RedHat.com>
Date: Fri, 30 Apr 2010 16:45:48 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [pnfs] Updated pNFS Developmental kernel rpms
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,

I've updated the Fedora pNFS development kernels to include 
the latest pNFS tag release and added new kernel repository. 

The Fedora 13 kernels (kernel-2.6.33) were updated to
the pnfs-all-2.6.33-2010-04-29 git tag. I realize that F-13
distro is not yet fully released, but its close and with a little
a bit of persuasion ;-) and F-13 kernel can be used on a F-12 box. 

I also added a Fedora devel (or rawhide) repository. This repository
will contain the Fedora Rawhide kernel (kernel-2.6.34) which
closely mirrors the mainstream kernel. This kernel was updated
to the pnfs-all-2.6.34-rc5-2010-04-29 git tag.

There were no changes to the Fedora 12 (kernel-2.6.32) repository.

Instructions on how to install and use these kernels are at:

http://wiki.linux-nfs.org/wiki/index.php/Fedora_pNFS_Client_Setup
(Thank you Mark Uddin, from EMC, for your initial input on this,
the input was very helpful!)
 
If/when bugs are found with these rpms please enter them
in to the NFS Bugzilla Main Page at:
    https://bugzilla.linux-nfs.org/index.cgi

Please use the "pNFS" keyword.. 

Any question or issues please feel free to contact me... 

steved.
