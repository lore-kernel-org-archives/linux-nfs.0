Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.simelon.net ([212.80.82.234]:39984 "EHLO mail.simelon.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759644Ab0FJTJS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jun 2010 15:09:18 -0400
Received: from localhost (unknown [127.0.0.1])
	by mail.simelon.net (Postfix) with ESMTP id EB632F00224
	for <linux-nfs@vger.kernel.org>; Thu, 10 Jun 2010 19:09:11 +0000 (UTC)
Received: from mail.simelon.net ([127.0.0.1])
	by localhost (mail.simelon.net [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id J38iQOG5yCtj for <linux-nfs@vger.kernel.org>;
	Thu, 10 Jun 2010 21:09:10 +0200 (CEST)
Received: from [192.168.1.151] (sumix.simelon [10.53.61.14])
	by mail.simelon.net (Postfix) with ESMTP id 04E8CF00223
	for <linux-nfs@vger.kernel.org>; Thu, 10 Jun 2010 21:09:09 +0200 (CEST)
Message-ID: <4C113855.2080806@atlas.cz>
Date: Thu, 10 Jun 2010 21:09:09 +0200
From: Jiri Kortus <sumix@atlas.cz>
To: linux-nfs@vger.kernel.org
Subject: Delay when writing to a file through pNFS
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I'm running a three-machine pNFS setup (MDS, DS and client on different 
virtual machines). When copying a file a mounted pNFS export or writing 
to a new file (with dd, for example), the write is delayed by 
approximately 15 seconds. When I write to a file that already exists, it 
works OK (there's no delay).

The NFS debug messages in kernel log (on the client) are showing that 
the client tries to write to the file, gets error -11 EAGAIN, waits 15 
seconds, then tries again successfully. I put a part of the kernel log 
concerning copying a small file to a pNFS export at 
http://charon.styxx.cz/tmp/pnfs/pnfs_write_log.txt

I have no idea what is the cause of the delays, so I hope someone could 
give me some advice concerning that. Thanks in advance.

Best regards,

Jiri Kortus
