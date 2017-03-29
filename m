Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55900 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750707AbdC2Bp7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 28 Mar 2017 21:45:59 -0400
Date: Tue, 28 Mar 2017 21:45:57 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@RedHat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: notes on VAULT 2017 NFS BOF
Message-ID: <20170329014557.GE20963@fieldses.org>
References: <20170324145907.GC2722@fieldses.org>
 <b77898fc-830d-6458-fe1e-86159fec92b6@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <b77898fc-830d-6458-fe1e-86159fec92b6@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 25, 2017 at 01:28:42PM -0400, Steve Dickson wrote:
> On 03/24/2017 10:59 AM, J. Bruce Fields wrote:
> > Should the client by default try NFSv4.2 first?  Consensus seems to be
> > yes.  When 4.2 fails, it tries 4.1, then 4.0, etc.  It works
> > transparently.  Steved was worried that those retries might become a
> > problem on clients with lots of NFS mounts.  Trond suggested recording
> > the result of the version negotiation across mounts, so a client doing a
> > lot of mounts to the same server would only need the retries on the
> > first mount.
> I just don't think this scales very well in large NFS mounted
> home directory server. Since the major enterprise  servers
> do not support 4.2 and I don't see them supporting 4.2
> anytime soon. Why try something when you know its going to fail? ;-) 

I'm OK with sticking with 4.1 for now.

That said, the expense of negotiation shouldn't be an issue.  We have
ideas here for cutting that expense (if it really is an issue), and
they'd help in the 4.1->4.0 case too.

> Starting at v4.2 in non-enterprise environments works, 
> at least it has for the last few years... 
> 
> > The retries are driven by userspace which does a mount for a specific
> > version and uses the return from the mount call to decide to negotiate
> > down.  So a new TCP connection happens for each mount attempt.
> Well it could be up to 3 connection (including the successful mount)
> when both the IPv4 and IPv6 address are tried.

Somebody correct me if I'm wrong, but I don't think that contributes to
port exhaustion.  Connections to the IPv4 and IPv6 addresses using the
same ports are distinct, aren't they?

> > Miklos introduced a proposed new mount api at LSF earlier in the week.
> > It would allow some communication with the file system driver to set up
> > parameters before the system call that creates the mountpoint.  If we
> > moved the mount negotiation to that setup phase, that might make the
> > negotiation phase more efficient while still leaving userspace in
> > charge.  (And we prefer leaving userspace in charge to give it maximum
> > control over negotiation policy.)
> Any pointers to this?

I googled around a little and can't find any.  It's still just a
proposal, so there's nothing for us to build on yet.

--b.
