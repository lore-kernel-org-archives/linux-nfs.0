From: Chris Vine <chris-TF6qbakwsgc2epGFuHBODCp2UmYkHbXO@public.gmane.org>
Subject: Re: [PATCH] nfsd: just keep single lockd reference for nfsd
Date: Fri, 18 Jun 2010 15:18:08 +0100
Message-ID: <20100618151808.6e40a0ca@boulder.homenet>
References: <1276858940-15499-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp5.freeserve.com ([193.252.22.128]:27902 "EHLO
	smtp5.freeserve.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933413Ab0FROS1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jun 2010 10:18:27 -0400
In-Reply-To: <1276858940-15499-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 18 Jun 2010 07:02:20 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> 
> This patch should replace the other patches that I proposed to make
> sure that each sv_permsock entry holds a lockd refrence.
> 
> Right now, nfsd keeps a lockd reference for each socket that it has
> open. This is unnecessary and complicates the error handling on
> startup and shutdown. Change it to just do a lockd_up when creating
> the nfsd_serv and just do a single lockd_down when taking down the
> last nfsd thread.
> 
> This patch also changes the error handling in nfsd_create_serv a
> bit too. There doesn't seem to be any need to reset the nfssvc_boot
> time if the nfsd startup failed.
> 
> Note though that this does change the user-visible behavior slightly.
> Today when someone writes a text socktype and port to the portlist
> file prior to starting nfsd, lockd is not started when nfsd threads
> are brought up. With this change, it will be started any time that
> the nfsd_serv is created. I'm making the assumption that that's not a
> problem. If it is then we'll need to take a different approach to
> fixing this.

[snip]

With this (and all the other patches in nfsd-error) applied, this
eliminates the kernel bug/oops.

However, on my netbook nfsd now always hangs when starting up, no matter
how much in advance I start portmap.  (The race condition has been
traded for a hang in very case.)

dmesg reports this:

NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
NFSD: starting 90-second grace period
[... hang here... ]
[... continuing after killall rpc.nfsd ...]
svc: failed to register lockdv1 RPC service (errno 512).
lockd_up: makesock failed, error=-512

portmap is definitely running.  'ps axc | grep rpc' gives:

 1767 ?        Ss     0:00 rpc.portmap
 1771 ?        Ss     0:00 rpc.statd
 2412 ?        S      0:00 rpciod/0
 2413 ?        S      0:00 rpciod/1
 3075 ?        Ss     0:00 rpc.rquotad

Chris


