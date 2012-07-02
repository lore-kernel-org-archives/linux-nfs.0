Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout-de.gmx.net ([213.165.64.22]:57609 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754482Ab2GBJnv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jul 2012 05:43:51 -0400
Message-ID: <4FF16D54.6090200@gmx.com>
Date: Mon, 02 Jul 2012 11:43:48 +0200
From: Andreas Heinlein <aheinlein@gmx.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Kernel NFSd CPU hog?
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

we have a strange NFS problem with a newly setup Linux server, and I 
hope someone here can help.

The symptom is that, slowly over time (speaking of several days up to 2 
weeks), the kernel nfsd processes/threads consume more and more CPU 
until the system finally becomes unresponsive. We recorded system 
activity with sar, which shows that CPU (system) usage slowly rises 
after reboot from about 1% to nearly 100% over the course of several 
days. Load averages stay around 0.1-0.3 until 100% are reached, up to 
this point the problem is almost not noticable from the clients. Then 
load averages climb up to 30.0; at this point the system becomes more or 
less unusable and has to be restarted. 'top' output shows the CPU usage 
evenly distributed across all nfsd threads.

The system is a fairly recent, though entry level server with a Core i3 
and 4G RAM, hosting the home directories for about 15-20 clients. CPU 
activity does not drop at night, when no clients are connected. It is 
running Debian 6.0 with linux 3.2.0 (from the backports repository), 
with nfs-utils 1.2.5 (also from the backports repository). I suspect 
that these backports might be the culprit, but since we need this kernel 
for other purposes, and I cannot reboot that machine during office 
hours, I'd rather not try going back to the official Debian kernel 
without good reasons. If there are known problems, I'd give it a try.

Can anyone help me?

Thanks,
Andreas
