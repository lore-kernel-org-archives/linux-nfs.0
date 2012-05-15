Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout-de.gmx.net ([213.165.64.23]:53387 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932120Ab2EOJDf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 05:03:35 -0400
Content-Type: text/plain; charset="utf-8"
Date: Tue, 15 May 2012 11:03:32 +0200
From: "Johannes Schild" <JSchild@gmx.de>
Message-ID: <20120515090332.182970@gmx.net>
MIME-Version: 1.0
Subject: Questions about Exofs
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

i try to set up the object-based layout with pnfs.
I am using the OSC-OSD as target. It works well and i can login.
Trying the scripts "do-*" from git://git.open-osd.org/open-osd.git the do-osd script works for me. The do-exofs doesnt, here i have some question:

1. Is the UUID in the do-exofs script optional?

2. If no how can i get it for my device?

3. It is mandatory to use raid-driver (raid456) in the script? Why?


The error is: 
mount -t exofs -o osdname=d2683732-c906-4ee1-9dbd-c10c27bb40df,pid=0x10000,_netdev /dev/osd0 /mnt/osd0/
mount: wrong fs type, bad option, bad superblock on /dev/osd0,
       missing codepage or helper program, or other error
       In some cases useful info is found in syslog - try
       dmesg | tail  or so

dmesg says:
exofs: Unable to mount exofs on (null) pid=0x0 err=-22


Thanks for answering my questions.


Regards

Johannes







-- 
NEU: FreePhone 3-fach-Flat mit kostenlosem Smartphone!                                  
Jetzt informieren: http://mobile.1und1.de/?ac=OM.PW.PW003K20328T7073a
