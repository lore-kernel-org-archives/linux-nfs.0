Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from blade3.isti.cnr.it ([194.119.192.19]:57425 "EHLO
	BLADE3.ISTI.CNR.IT" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822Ab1BJBsD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Feb 2011 20:48:03 -0500
Received: from SCRIPT-SPFWL-DAEMON.mx.isti.cnr.it by mx.isti.cnr.it
 (PMDF V6.5-x5 #31825) id <01NXN9APIV2OPHQGUJ@mx.isti.cnr.it> for
 linux-nfs@vger.kernel.org; Thu, 10 Feb 2011 02:47:04 +0100 (MET)
Received: from conversionlocal.isti.cnr.it by mx.isti.cnr.it
 (PMDF V6.5-x5 #31825) id <01NXN9AOXY5SPHQGUI@mx.isti.cnr.it> for
 linux-nfs@vger.kernel.org; Thu, 10 Feb 2011 02:47:02 +0100 (MET)
Received: from [151.82.102.54] by mx.isti.cnr.it (PMDF V6.5-x5 #31826)
 with ESMTPSA id <01NXN9AN46H4PGHRNH@mx.isti.cnr.it> for
 linux-nfs@vger.kernel.org; Thu, 10 Feb 2011 02:47:01 +0100 (MET)
Date: Thu, 10 Feb 2011 02:47:00 +0100
From: Asdo <asdo@shiftmail.org>
Subject: How to separate mount rights in nfsv4
To: linux-nfs@vger.kernel.org
Message-id: <4D534394.2050404@shiftmail.org>
Content-type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,
it's not clear to me how I can allow different access to different
machines in NFSv4.
Because nfsv4 needs a root export with fsid=0, and all other mounts
should be below that.

However, if the line with fsid=0 is not mountable to all nodes, also the
mounts below it will fail.
And if the line with fsid=0 is mountable to all nodes, all further lines
can provide no additional security!

Example; this is my current export:

/virtual_machines/kvm/export   
10.48.0.0/24(rw,no_root_squash,async,subtree_check,fsid=0)
/virtual_machines/kvm/export/hwnode1  
10.48.0.10(rw,no_root_squash,async,subtree_check)
/virtual_machines/kvm/export/hwnode2  
10.48.0.11(rw,no_root_squash,async,subtree_check)

I have two hardware nodes for virtual machines. Ideally each one of them
should be able to mount only its subdirectory, but the export shown
above is the only working one I could create.
However with the above export file the root user on hwnode1 can directly
mount /virtual_machines/kvm/export and see everything, even the files
that were for hwnode2 only.
OTOH if I set my fsid=0 line so that it's not mountable (e.g. changing
the IP or netmask), all lines below it stop working.

How should I do?

Thanks for your help

