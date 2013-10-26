Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm30-vm9.bullet.mail.sg3.yahoo.com ([106.10.151.184]:35694 "EHLO
	nm30-vm9.bullet.mail.sg3.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754453Ab3JZDnP convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Oct 2013 23:43:15 -0400
References: <1382520968.55729.YahooMailNeo@web193705.mail.sg3.yahoo.com>
Message-ID: <1382758657.1289.YahooMailNeo@web193704.mail.sg3.yahoo.com>
Date: Sat, 26 Oct 2013 11:37:37 +0800 (SGT)
From: siva sankar <siva_sankar43@yahoo.com>
Reply-To: siva sankar <siva_sankar43@yahoo.com>
Subject: Regarding NFSv4 File Open Operation
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <1382520968.55729.YahooMailNeo@web193705.mail.sg3.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Hi,


I am trying out to patch the kernel NFSv4 file_operations open() call.

But, from the logs, i don't see open() call being fired for file(present on shared nfs server) open operartion(cat /mnt/share/abc.txt).

However, in case of NFSv3, i could see open() call being fired for same file(present on shared nfs server) open operation.

Can anybody let me me how to patch open() system call in NFSv4?
Basically, i want my patch function to be fired first which will internally invoke the actual NFSv4's open call.


I am working on RHEL6.4 kernel v2.6.32 64-Bit.


Thanks in advance.

Regards,
Siva
