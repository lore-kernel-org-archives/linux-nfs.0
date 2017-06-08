Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.11]:53644 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750914AbdFHOGu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Jun 2017 10:06:50 -0400
MIME-Version: 1.0
Message-ID: <trinity-7226e167-068f-4dac-bbe6-baecf1666bc3-1496930792511@3capp-webde-bap44>
From: devzero@web.de
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, pf@artcom-gmbh.de, rnews@altium.nl,
        jlayton@redhat.com
Subject: Aw: Re: How to avoid rebooting Linux NFS-client when NFS-server is
 not available?
Content-Type: text/plain; charset=UTF-8
Date: Thu, 8 Jun 2017 16:06:32 +0200
In-Reply-To: <20170608133423.GG26995@fieldses.org>
References: <trinity-f2c19596-3afe-4a3f-ad07-78e6cfda9cb5-1496911790012@3capp-webde-bap34>
 <20170608133423.GG26995@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Ripping out the storage from underneath your applications is a pretty
> drastic step and may lose data,

We did not rip out our storage, it`s still there and reachable without problems. Our hung nfs is NEVER being caused by nfs server reboots or poweroff, it seems to happen on network disruption or whatever.

Maybe the problem is the WAN connection or some firewall session invalidation - or the nfs server itself (freenas, btw) not responding in a way the client expects.

For my curiousity, after switching off the fake ip and do a showmount -e to the original server where we had the hung nfs mount (to show you it`s still there and reachable), the mount suddenly unmounts cleanly, even without -f. 

And i can remount it without any problem.

It looks as if the interim fake nfs server (which did not export any share) made the client work correctly again...

regards
Roland

> Gesendet: Donnerstag, 08. Juni 2017 um 15:34 Uhr
> Von: "J. Bruce Fields" <bfields@fieldses.org>
> An: devzero@web.de
> Cc: linux-nfs@vger.kernel.org, pf@artcom-gmbh.de, rnews@altium.nl, jlayton@redhat.com
> Betreff: Re: How to avoid rebooting Linux NFS-client when NFS-server is not available?
>
> On Thu, Jun 08, 2017 at 10:49:50AM +0200, devzero@web.de wrote:
> > Any hint on how to circumvent rebooting to remount the nfs share or proactively avoid stale NFS mounts would be very appreciated. (disabling NFS by module unload/load is no option, as our XEN servers do have other NFS mounts for shared storage)
> 
> Neil had some recent posts that might be relevant:
> 
> 	http://marc.info/?l=util-linux-ng&m=149662998931157&w=2
> 
> Ripping out the storage from underneath your applications is a pretty
> drastic step and may lose data, so NFS hasn't traditionally tried very
> hard to make it easy.  But it may be possible at this point if you kill
> -9 all the users and umount carefully.
> 
> > I`m not sure if linux-nfs ML will allow anonymous posts (probably
> > not), so maybe someone subscribed be so kind to reply with list cc´ed.
> > I`d like to avoid subscribing to a list because of a single post...
> 
> That's fine.
> 
> --b.
>
