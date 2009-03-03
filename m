From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Re: [NFS] nfsd hangs 2.6.28 through 2.6.28.7
Date: Tue, 03 Mar 2009 14:55:19 +0530
Message-ID: <49ACF77F.303@suse.de>
References: <49AC747F.6010001@atmos.washington.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: warren-qmPYOCrcNLLyFCzt5hm0YvZ8FUJU4vz8@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:42652 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752787AbZCCJr3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Mar 2009 04:47:29 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1LeRDd-0004Zu-RH
	for linux-nfs@vger.kernel.org; Tue, 03 Mar 2009 20:47:21 +1100
In-Reply-To: <49AC747F.6010001-qmPYOCrcNLLyFCzt5hm0YvZ8FUJU4vz8@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

David Warren wrote:
> We are seeing nfsd getting stuck in d wait at boot time. The fix seems
> to be stopping in single user mode prior to nfs starting, renaming
> /var/lib/nfs/v4recovery/ and making a new one, then letting the system
> continue. When it boots and hangs, all processes that touch
> /var/lib/nfs/v4recovery/ go into D-wait. However, if you rename it and
(Cc fixed)

Can you get a Sysrq + w output by doing either
    echo w > /proc/sysrq-trigger
   (or)
   Sysrq + w (hold Sysrq key and press 'w')
and capture dmesg output and attach?

It you could not get a shell, you could try to disable NFS during boot
and try to start NFS once the machine boots and then try.
Is the NFS server running inside a Virtual machine?


Thanks,

-- 
Suresh Jayaraman

------------------------------------------------------------------------------
Open Source Business Conference (OSBC), March 24-25, 2009, San Francisco, CA
-OSBC tackles the biggest issue in open source: Open Sourcing the Enterprise
-Strategies to boost innovation and cut costs with open source participation
-Receive a $600 discount off the registration fee with the source code: SFAD
http://p.sf.net/sfu/XcvMzF8H
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

