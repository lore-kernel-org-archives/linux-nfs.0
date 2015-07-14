Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mta3.iii.org.tw ([219.87.66.42]:13673 "EHLO mta3.iii.org.tw"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752183AbbGNHBh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jul 2015 03:01:37 -0400
From: "Paul" <paulwu@iii.org.tw>
To: <linux-nfs@vger.kernel.org>
Subject: pnfs MDS mount point clinet cannot mount
Date: Tue, 14 Jul 2015 15:01:29 +0800
Message-ID: <001401d0be02$e8a3b800$b9eb2800$@org.tw>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,
I am glad to use your nfs-utils for pnfs server.
Then I have a question when I build pnfs environment.
I use nfs-utils-3-3-rc5 and linux-4.1.1 as MDS. Other five DS use two disk
respectively iSCSI target.
My client have no upgrade nfs-utils and linux, just Fedora 22.
The problem is when my client mounts the pnfs MDS by command:
# mount -t nfs -o vers=4.1 MDS:/export /pnfs/
The system appears message:
# mount.nfs: mounting MDS:/export failed, reason given by server: No such
file or directory
But is successfully with mount MDS:/
# mount -t nfs -o vers=4.1 MDS:/ /pnfs/
It means that I cannot mount any mount point but the slash of MDS.
I see google seldom people meet the question and no one answer that.
Therefore, I ask to nfs-utils developer.
Sorry to bother you and thank you read the mail.

Regards,
Paul


