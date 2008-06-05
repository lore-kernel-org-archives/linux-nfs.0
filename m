From: Steve Gaarder <gaarder-O+4OpAMI7mIibAbXQ5Tkjg@public.gmane.org>
Subject: File locking quits
Date: Thu, 5 Jun 2008 17:06:06 -0400 (EDT)
Message-ID: <alpine.LRH.1.00.0806051040070.4860@baltic.math.cornell.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from math.cornell.edu ([128.84.234.110]:58999 "EHLO math.cornell.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752502AbYFEVmi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jun 2008 17:42:38 -0400
Received: from baltic.math.cornell.edu ([128.84.234.231])
	by math.cornell.edu with esmtp (Exim 4.43)
	id 1K4Mes-0000cD-DH
	for linux-nfs@vger.kernel.org; Thu, 05 Jun 2008 17:06:06 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by baltic.math.cornell.edu (8.13.1/8.13.1) with ESMTP id m55L66Qq013761
	for <linux-nfs@vger.kernel.org>; Thu, 5 Jun 2008 17:06:06 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I am running an NFS (version 3 and 4) server on Red Hat Enterprise 5, 
upgraded to kernel version 2.6.18-92.el5 a couple weeks ago.  A couple 
days ago NFS file locking quit completely.  Any program that tried to lock 
a file would hang, including this piece of Python code:

import fcntl
fp = open("lock-test4", "a")
fcntl.lockf(fp.fileno(), fcntl.LOCK_EX|fcntl.LOCK_NB)

A packet sniff showed periodic retransmissions of requests to the lock 
manager port, and no replies.  I am running iptables with that port (among 
others) allowed through.  Restarting iptables did not help.  The only 
thing that did help was a reboot.  The next day the problem happened 
again; this time, when I rebooted, I reverted to the older kernel, 
2.6.18-53.1.4.el5.  So far, it's run a bit more than 24 hours without 
incident.

- any idea what might be going on?
- am I correct that this locking is handled in the kernel?
- is there a way of restarting locking short of rebooting?
- how would I go about debugging this further?

thanks,

Steve Gaarder
System Administrator, Dept of Mathematics
Cornell University, Ithaca, NY, USA
gaarder-O+4OpAMI7mIibAbXQ5Tkjg@public.gmane.org
