Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.pronto.com.au ([202.9.18.113]:47838 "EHLO
	melbsmtp.pronto.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753035Ab1FFN6F convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jun 2011 09:58:05 -0400
From: Tristan Ball <tristanb@pronto.com.au>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: NFS Sync with External Journal
Date: Mon, 6 Jun 2011 13:42:39 +0000
Message-ID: <3FA034197108F04082D2AE1401CE0F3832A9B34E@VICMAILBOX.pronto.com.au>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I've been experimenting with using an external ext3 journal as a way to bring the write performance of an NFS share exported with the the 'sync' option closer to that of one exported with 'async'.
I've mounted the ext3 filesystem with data=journal, and the journal itself is on SSD.  I've seen various references on the net saying that this should improve performance, as the nfs process can respond to write requests as soon as the data is in journal, rather than flushed all the way to the filesystem

However, in my tests is seems that when the filesystem is shared as 'sync', then writes are written to the filesystem at the same time as they are written to the journal, and performance isn't significantly different to a plain ext3 filesystem with an internal journal and data=ordered. To me this implies that the NFS layer isn't returning from writes until they're flushed to the filesystem disk?

So, my question really is - should I be expecting this to work as a performance enhancer?

I realise that the server is doing more work with data=journal, however given how much faster than the HD the SSD is, and the fact that the journal is large enough to contain all the data I'm writing in this test, I was hoping to see the nfs writes occur at closer to wirespeed.

Server is Oracle Linux, Kernel 2.6.32-100.28.5.el6.x86_64.
Client was Ubuntu, 2.6.32-32-server x86_64.

/etc/exports:
/plain          *(rw,async,no_subtree_check,no_root_squash)
/split          *(rw,async,no_subtree_check,no_root_squash) # (FS with external Journal)

Client mounts were done simply with -o 'rw,rsize=32768,wsize=32768'

Benchmark results:
Plain Ext3, data=ordered export=sync, write speed 56-62MB/sec
Split Ext3, data=journal export=sync, write speed = 46-50MB/sec

For reference:
Plain Ext3, data=ordered export=async, write speed 111MB/sec
Split Ext3, data=journal export=async, write speed 110MB/sec

Thanks for your time.

Tristan


Tristan Ball - Hosted Services Manager VIC
Pronto Hosted Services
20 Lakeside Drive, Burwood East, VIC 3151
Phone: +61 3 9887 7770 | Email: tristanb@pronto.com.au
Mobile: +61 408 397 473


For PHS helpdesk support, please email phs@pronto.com.au
For urgent after hours support phone: 1800 622 556

---Legal Notice---
The email message and any attachments are confidential and subject to copyright. If you are not the intended recipient, any use, interference with, disclosure or copying of this material is unauthorised and prohibited. No part may be reproduced, adapted or transmitted without the written permission of the copyright owner. If you have received this email in error, please immediately advise the sender by return email and delete the message from your system. Before opening or using attachments, check for viruses and defects. Our liability is limited to re-supplying any affected attachments.

