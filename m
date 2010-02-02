From: Jon Forrest <jlforrest-TVLZxgkOlNX2fBVCVOL8/A@public.gmane.org>
Subject: umount_autofs_indirect: ask umount returned busy CentOS 5.3
Date: Tue, 02 Feb 2010 13:51:09 -0800
Message-ID: <hka6o2$h2o$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:33024 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756824Ab0BBVv2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Feb 2010 16:51:28 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1NcQec-0007Fw-Gr
	for linux-nfs@vger.kernel.org; Tue, 02 Feb 2010 22:51:26 +0100
Received: from nobozo.cchem.berkeley.edu ([128.32.50.5])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 02 Feb 2010 22:51:26 +0100
Received: from jlforrest by nobozo.cchem.berkeley.edu with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 02 Feb 2010 22:51:26 +0100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have a new cluster running CentOS 5.3.
The cluster uses a Sun 7310 storage server
that provides NFS service over a private
1Gb/s ethernet with 9K jumbo frames to the
cluster.

We've noticed that a number of the compute
nodes sometimes generate the

automount[15023]: umount_autofs_indirect: ask umount returned busy /home

message. When this happens the program running on the
node dies. This has happened between 10 and 20 times.
We're not sure what's going on on a node when this
happens. Most of the time everything is fine and
the home directories are automounted without problem.

I've googled for this problem and I see that other people
have seen it too, but I've never seen a resolution,
especially not for RHEL5

The auto.master line for this mount is

/home  /etc/auto.home  --timeout=1200 
noatime,nodiratime,rw,noacl,rsize=32768,wsize=32768

The network interface configuration is

eth0      Link encap:Ethernet  HWaddr 00:30:48:B9:F6:52
           inet addr:10.1.255.233  Bcast:10.1.255.255  Mask:255.255.0.0
           inet6 addr: fe80::230:48ff:feb9:f652/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:9000  Metric:1
           RX packets:32999308 errors:0 dropped:0 overruns:0 frame:0
           TX packets:27468315 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:24225053296 (22.5 GiB)  TX bytes:73313582546 (68.2 GiB)
           Interrupt:74 Base address:0x2000

Any advice on what to do?

Cordially,
-- 
Jon Forrest
Research Computing Support
College of Chemistry
173 Tan Hall
University of California Berkeley
Berkeley, CA
94720-1460
510-643-1032
jlforrest-TVLZxgkOlNX2fBVCVOL8/A@public.gmane.org

