From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: server locks up at boot
Date: Wed, 22 Jul 2009 12:32:16 -0400
Message-ID: <20090722163216.GA4491@fieldses.org>
References: <4A5F9110.4050208@atmos.washington.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: David Warren <warren-qmPYOCrcNLLyFCzt5hm0YvZ8FUJU4vz8@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40597 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753255AbZGVQcQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jul 2009 12:32:16 -0400
In-Reply-To: <4A5F9110.4050208-qmPYOCrcNLLyFCzt5hm0YvZ8FUJU4vz8@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 16, 2009 at 01:44:00PM -0700, David Warren wrote:
> We have been having a problem for a while now with kernels ranging from  
> 2.6.26 through 30. When a boots and starts the nfs server, it reads the  
> /var/lib/nfs/v4recovery directory. If this directory is empty everything  
> is fine. If it is not, all nfs related processes go into D wait and  
> never return. Any other attempt to read the directory results in that  
> process getting stuck in D wait as well. This happens on a variety of  
> systems, all running Debian Lenny (happened with etch also) with kernels  
> ranging from 2.6.26 - 2.6.31-rc2 serving disks via nfs4. if you boot  
> single user and clear out the directory, everything is fine. Also, there  
> is never any problem logged anywhere.

What filesystem(s) is that directory on?  When the processes get stuck
in D state, could you "echo w >/proc/sysrq-trigger" and see what's
dumped to the system logs?  Also, when you boot with a nonempty
/var/lib/nfs/v4recovery directory, what do the contents of that
directory look like?  Is SELinux (or something else that could make them
difficult to delete) enabled?

> So, my questions are:
>
> What is this directory really used for? It doesn't seem to need it to  
> reestablish connections
> Anyone have any idea what is going on or suggestions for finding out?

It's essentially storing a list of clients that held some kind of state
on the previous boot.  Clients on that list are permitted to reclaim
state (like locks) on the next boot.

So if you ever reboot while an application on a client holds a lock,
the client will not be allowed to reclaim that lock.  In the case of
linux clients I think the application will be allowed to continue
without being told of the situation, with the risk that another client
may get a conflicting lock without the application knowing.

That v4recovery directory has been problematic, I've been promising for
a while to replace it with a different mechanism, and am pretty
embarrassed that I haven't yet....

--b.
