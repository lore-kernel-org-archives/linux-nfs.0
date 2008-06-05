From: Jeff Layton <jlayton@redhat.com>
Subject: Re: File locking quits
Date: Thu, 5 Jun 2008 19:37:11 -0400
Message-ID: <20080605193711.670dd88d@tleilax.poochiereds.net>
References: <alpine.LRH.1.00.0806051040070.4860@baltic.math.cornell.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Steve Gaarder <gaarder-O+4OpAMI7mIibAbXQ5Tkjg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:47107 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753281AbYFEXhS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jun 2008 19:37:18 -0400
In-Reply-To: <alpine.LRH.1.00.0806051040070.4860-Sx1j/aq4mu3k0HFLh5Ah4O1KJvuKJAac@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 5 Jun 2008 17:06:06 -0400 (EDT)
Steve Gaarder <gaarder-O+4OpAMI7mIibAbXQ5Tkjg@public.gmane.org> wrote:

> I am running an NFS (version 3 and 4) server on Red Hat Enterprise 5, 
> upgraded to kernel version 2.6.18-92.el5 a couple weeks ago.  A couple 
> days ago NFS file locking quit completely.  Any program that tried to lock 
> a file would hang, including this piece of Python code:
> 
> import fcntl
> fp = open("lock-test4", "a")
> fcntl.lockf(fp.fileno(), fcntl.LOCK_EX|fcntl.LOCK_NB)
> 
> A packet sniff showed periodic retransmissions of requests to the lock 
> manager port, and no replies.  I am running iptables with that port (among 
> others) allowed through.  Restarting iptables did not help.  The only 
> thing that did help was a reboot.  The next day the problem happened 
> again; this time, when I rebooted, I reverted to the older kernel, 
> 2.6.18-53.1.4.el5.  So far, it's run a bit more than 24 hours without 
> incident.
> 
> - any idea what might be going on?

Not right offhand, I don't believe we saw this in testing. Sounds like
a race of some sort. I'm going to assume, since you mention packets
going to the NLM port that the problem seems to be with NFSv3. Is this
correct?

> - am I correct that this locking is handled in the kernel?

Yes.

> - is there a way of restarting locking short of rebooting?

Not really. You can unmount and try to make sure that lockd
goes down, but without knowing what the problem is that may
not fix it anyway.

> - how would I go about debugging this further?
> 

It would be interesting to know what lockd is actually doing. Getting
some sysrq-t info might be a good place to start. I'd definitely
recommend opening a support case for this so we can track it formally
within Red Hat (and possibly can get you a supported fix if it turns
out to be a bug).

-- 
Jeff Layton <jlayton@redhat.com>
