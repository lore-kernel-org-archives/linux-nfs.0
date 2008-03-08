From: Timo Reimann <mailinglist-d4LLFNs4DFRA7UZ8SB9NFg@public.gmane.org>
Subject: Re: NFS server waking up sleeping disks
Date: Sat, 08 Mar 2008 14:59:30 +0100
Message-ID: <47D29BC2.9000806@foo-lounge.de>
References: <1204969522.11220.680.camel@hurina>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Cc: linux-nfs@vger.kernel.org
To: Timo Sirainen <tss@iki.fi>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from server3.hostprice.de ([213.239.211.250]:35398 "EHLO
	server3.hostprice.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753221AbYCHN7j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 8 Mar 2008 08:59:39 -0500
In-Reply-To: <1204969522.11220.680.camel@hurina>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Timo Sirainen wrote:
> My Linux 2.6.24.1 NFS server has two disks. One of them is rarely used,
> so it's normally sleeping and is not even mounted anywhere. But after
> the NFS mount hasn't been used for a while (some hours?) doing just a
> "ls" on NFS client causes the sleeping disk to wake up and the "ls"
> reply is delayed a few seconds until the wakeup is finished.
> 
> Any ideas why it's waking up the disk that has nothing to do with NFS,
> and how to prevent it from doing this?

Your issue might be related to the same that I have (which is still
unresolved). Basically, my non-mounted backup disk keeps spinning up
after a rough 20-25 minutes of sleeping. Check out my archived thread
for details and hints how to determine disk-accessing processes:

http://marc.info/?l=linux-nfs&m=120354580303104&w=2

However, there is no `ls' or similar call required to wake up my disk.
It just happens.


Regards,

--Timo (too)
