From: thomas62186218-YDxpq3io04c@public.gmane.org
Subject: NFS and LVM2 issues
Date: Mon, 13 Apr 2009 22:39:25 -0400
Message-ID: <8CB8AC15C09B9C4-F68-1088@webmail-dh39.sysops.aol.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from imo-m13.mx.aol.com ([64.12.143.101]:16143 "EHLO
	imo-m13.mail.aol.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751195AbZDNCs1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Apr 2009 22:48:27 -0400
Received: from thomas62186218-YDxpq3io04c@public.gmane.org
	by imo-da03.mx.aol.com  (mail_out_v40_r1.5.) id x.ccf.4e810425 (37166)
	 for <linux-nfs@vger.kernel.org>; Mon, 13 Apr 2009 22:39:29 -0400 (EDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi All,

I am running into two issues with nfs-kernel-server in Ubuntu Hardy 
8.0.4 x64. I am running Ubuntu on a quad-core 3.0 GHz server with 8 GB 
RAM and 12 x SATA 500GB drives.

1) I create a 100 GB LVM2 volume and format it with XFS. I create a 
directory and export it as an NFS share assigned to a VMware ESX 3.5 
server. I connect successfully from VMware ESX to the NFS share and 
create an NFS datastore. VMware reports the LVM2 volume capacity as the 
capacity of the NFS datastore (100 GB). I then resize the LVM2 volume 
to 200 GB. However, in VMware, it still reports the NFS datastore as 
100 GB. If I delete the NFS datastore in VMware, and then reestablish 
it, it still reports the NFS datastore as 100 GB. I have even tried 
rebooting my Ubuntu server but VMware still reports it as 100 GB. Any 
ideas?

2) If I continue the above example, I next try to delete my 100 GB LVM2 
volume. I first delete the NFS directory and remove the NFS export. 
However, I can never delete the LVM2 volume afterwards. It seems like 
NFS maintains a lock of some sort on the volume. The only workaround is 
to reboot the Ubuntu Server altogether, and then I can delete the LVM2 
volume.

Any insight would be greatly appreciated. Thanks!!

Sincerely,
-Thomas

