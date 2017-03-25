Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43592 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751464AbdCYRfS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 25 Mar 2017 13:35:18 -0400
Subject: Re: notes on VAULT 2017 NFS BOF
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
References: <20170324145907.GC2722@fieldses.org>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <b77898fc-830d-6458-fe1e-86159fec92b6@RedHat.com>
Date: Sat, 25 Mar 2017 13:28:42 -0400
MIME-Version: 1.0
In-Reply-To: <20170324145907.GC2722@fieldses.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/24/2017 10:59 AM, J. Bruce Fields wrote:
> Steve Dickson lead a quick NFS meeting Wednesday night at Boston during
> vault.  I thought it might be worth posting my notes:
Thank you for doing this... 

> 
> Flex file server: it's just there for testing.  If someone wants to
> build on it, they can.  It has no practical use, and should be
> configured out of distro kernels to avoid confusing users.
+1... not really clear what the point was in even posting it.

> 
> NFSv4-only server: some users want to minimize open ports, so we should
> support this configuration.  But distros probably shouldn't be
> NFSv4-only by default.  (And: a show of hands at Steve & Chuck's talk
> the next day confirmed that people still depend on NFSv3.)
I did try hard... but there was definitely push back. :-) 

> 
> What about turning off UDP?  This looks more doable.  Note client still
> needs to listen for lockd UDP.  But we can keep that while turning off
> nfsd UDP.  (Kernel lockd is currently hard-coded to listen on both UDP
> and TCP regardless of server configuration.)
Jeff's RFC patches are definitely on the my TODO list. 
My question is do we turn off UDP between services 
on the same host... I'm thinking not. 

> 
> Should the client by default try NFSv4.2 first?  Consensus seems to be
> yes.  When 4.2 fails, it tries 4.1, then 4.0, etc.  It works
> transparently.  Steved was worried that those retries might become a
> problem on clients with lots of NFS mounts.  Trond suggested recording
> the result of the version negotiation across mounts, so a client doing a
> lot of mounts to the same server would only need the retries on the
> first mount.
I just don't think this scales very well in large NFS mounted
home directory server. Since the major enterprise  servers
do not support 4.2 and I don't see them supporting 4.2
anytime soon. Why try something when you know its going to fail? ;-) 

Starting at v4.2 in non-enterprise environments works, 
at least it has for the last few years... 

> 
> The retries are driven by userspace which does a mount for a specific
> version and uses the return from the mount call to decide to negotiate
> down.  So a new TCP connection happens for each mount attempt.
Well it could be up to 3 connection (including the successful mount)
when both the IPv4 and IPv6 address are tried. 

> 
> Miklos introduced a proposed new mount api at LSF earlier in the week.
> It would allow some communication with the file system driver to set up
> parameters before the system call that creates the mountpoint.  If we
> moved the mount negotiation to that setup phase, that might make the
> negotiation phase more efficient while still leaving userspace in
> charge.  (And we prefer leaving userspace in charge to give it maximum
> control over negotiation policy.)
Any pointers to this?

steved.

> 
> Somebody asked about inotify implementation.  Currently inotify only
> reports changes made on the same client.  There is unimplemented
> protocol in RFC 5661 that would allow the client to get notifications of
> other changes from the server.  Trond says it would be difficult and
> risks flooding the network with notifications, though the protocol does
> have some provision for batching them.
> 
> There were questions about NFS's uses of RDMA writes which I didn't
> follow, and my notes stopped there.
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
