Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12772 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753956Ab0JTRza (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Oct 2010 13:55:30 -0400
Date: Wed, 20 Oct 2010 13:55:25 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Neil Brown <neilb@suse.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 mounts take longer the fail from ENETUNREACH than NFSv3
 mounts.
Message-ID: <20101020135525.22977d8d@tlielax.poochiereds.net>
In-Reply-To: <20101020181701.232dbeea@notabene>
References: <20101020181701.232dbeea@notabene>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 20 Oct 2010 18:17:01 +1100
Neil Brown <neilb@suse.de> wrote:

> 
> 
> If I don't have any network configured (except loop-back), and try an NFSv3
> mount, then it fails quickly:
> 
> 
> ....
> mount.nfs: portmap query failed: RPC: Remote system error - Network is unreachable
> mount.nfs: Network is unreachable
> 
> 
> If I try the same thing with a NFSv4 mount, it times out before it fails,
> making a much longer delay.
> 
> This is because mount.nfs doesn't do a portmap lookup but just leaves
> everything to the kernel.
> The kernel does an 'rpc_ping()' which sets RPC_TASK_SOFTCONN.
> So at least it doesn't retry after the timeout.  But given that we have a
> clear error, we shouldn't timeout at all.
> 
> Unfortunately I cannot see an easy way to fix this.
> 
> The place where ENETUNREACH is in xs_tcp_setup_socket.  The comment there
> says "Retry with the same socket after a delay".  The "delay" bit is correct,
> the "retry" isn't.
> 
> It would seem that we should just add a 'goto out' there if RPC_TASK_SOFTCONN
> was set.  However we cannot see the task at this point - in fact it seems
> that there could be a queue of tasks waiting on this connection.  I guess
> some could be soft, and some not. ???
> 
> So: An suggestions how to get a ENETUNREACH (or ECONNREFUSED or similar) to
> fail immediately when  RPC_TASK_SOFTCONN is set ???
> 
> 
> This affects people who upgrade from openSUSE11.2 (which didn't support v4
> mounts) to openSUSE11.3 (which defaults to v4) and who use network-manager
> (which configures networks late) and have NFS mounts in /etc/fstab with
> either explicit IP addresses or host names that can be resolved without the
> network.
> This config will work because when the network comes up, network-manager will
> re-run the 'init.d/nfs' script.  However since 11.3 there is an unpleasant
> pause before boot completes.
> 

Took me a few tries to get an ENETUNREACH error but I see the same hang
you do. For the record I was able to get one by not configuring an IPv6
addr on the box and attempting to mount an IPv6 address.

Interestingly while I was trying to reproduce it, I ended up
reproducing an EHOSTUNREACH error by trying to mount a IPv6 host to
which I didn't have a route. That error returns quickly from the
kernel. Maybe we can solve this simply by treating ENETUNREACH the same
as EHOSTUNREACH in this situation?

I'm not quite sure exactly how to make that happen, but it seems like
reasonable behavior.

-- 
Jeff Layton <jlayton@redhat.com>
