Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:56289 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753303Ab1DMLuH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Apr 2011 07:50:07 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1Q9yaD-0001pl-67
	for linux-nfs@vger.kernel.org; Wed, 13 Apr 2011 13:50:05 +0200
Received: from bg-1.or.uni-bonn.de ([131.220.141.100])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 13 Apr 2011 13:50:05 +0200
Received: from bartoschek by bg-1.or.uni-bonn.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 13 Apr 2011 13:50:05 +0200
To: linux-nfs@vger.kernel.org
From: Christoph Bartoschek <bartoschek@gmx.de>
Subject: Performance of older clients (RedHat 4.4) with newer Servers (Ubuntu 10.04 LTS)
Date: Wed, 13 Apr 2011 12:23:24 +0200
Message-ID: <t5ag78-bvg.ln1@barney.bruehl.pontohonk.de>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

are there known performance issues of older clients with newer servers? 

We have an Ubuntu 10.04 LTS server exporting two directories.

/a - An ext4 filesystem over a RAID 6 partition.
/b - An ext4 filesystem over LVM over DRBD over a RAID 6 partition.

The underlaying partitions have the same size and number of disks on the 
same controller.

When we put the same data on both partitions and mount them on a Opensuse 
11.3 box we see no difference between both mount points. It does not matter 
whether one uses /a or /b.  Our reference benchmark is a compile job, where 
all headers are located on the NFS server. The speed is very good and as 
expected.

However if we mount both exports on a RedHat 4.4 box we see that

1. the job is 3 times slower using /a
2. the job is 9 times slower using /b

The network connection and cpu of the RedHat machine are very similar to the 
opensuse machine.

Is there any reason why the RedHat machine is so much slower than the 
opensuse machine? Is there a reason why the /b export is three times slower 
than the /a export on the redhat machine?

Christoph

