Return-Path: linux-nfs-owner@vger.kernel.org
Received: from szxga03-in.huawei.com ([119.145.14.66]:4133 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755454Ab3JNBUg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Oct 2013 21:20:36 -0400
From: Wangminlan <wangminlan@huawei.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: Wangminlan <wangminlan@huawei.com>
Subject: Different sequence of "exportfs" produce different effects on nfs
 client mounts
Date: Mon, 14 Oct 2013 01:20:26 +0000
Message-ID: <3962238FD7EA0F41B1810E7ABEAFBC314CEF9AA6@szxema505-mbs.china.huawei.com>
References: <1381522554-22243-1-git-send-email-geyslan@gmail.com>
In-Reply-To: <1381522554-22243-1-git-send-email-geyslan@gmail.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,
         I've got a problem on the nfs export operation. I'm not sure if this is the right place to ask this, if not, can you please tell me where?

         Here's what I need:
1.      I have a folder named /mnt/fs1 to be exported.
2.      All the host in subnetwork 192.168.0.0/16 should be able access this folder, but their root should be squashed.
3.      Some specified host in the same subnetwork can gain the root permission on the folder, for example: 192.168.0.21, 192.168.0.22.

I've got a SLES11SP1 box as the nfs server, the nfs clients are SLES11SP1, too. And the test uses nfsv3.
Here are the commands I used to do the export:
#exportfs -o rw,root_squash 192.168.0.0/16:/mnt/fs1 #exportfs -o rw,no_root_squash 192.168.0.21:/mnt/fs1 #exportfs -o rw,no_root_squash 192.168.0.22:/mnt/fs1

After this, everything works as expected.
But, after the following operations:
#exportfs -u 192.168.0.0/16:/mnt/fs1              /* Delete this export */
# exportfs -o rw,root_squash 192.168.0.0/16:/mnt/fs1          /* And add it again */

Hosts on 192.168.0.21 and 192.168.0.22 doesn't get root permission any more. when I tried to write a file, it complains about "Permission denied".

So, does the order of exportfs command has something to do the final result? Or am I doing something wrong?

B.R
Minlan Wang
