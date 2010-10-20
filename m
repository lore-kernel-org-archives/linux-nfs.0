Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:40100 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753121Ab0JTO3Z convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Oct 2010 10:29:25 -0400
Subject: Re: NFSv4 mounts take longer the fail from ENETUNREACH than NFSv3 mounts.
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@ORACLE.COM>
In-Reply-To: <20101020181701.232dbeea@notabene>
Date: Wed, 20 Oct 2010 10:29:05 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <C56CFB9A-FCA4-41DA-971F-49B9C9EE7F03@oracle.com>
References: <20101020181701.232dbeea@notabene>
To: Neil Brown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Oct 20, 2010, at 3:17 AM, Neil Brown wrote:

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

ECONNREFUSED should already fail immediately in this case.  If it's not failing immediately, that's a bug.

I agree that ENETUNREACH seems appropriate for quick failure if RPC_TASK_SOFTCONN is set.  (I thought it already worked this way, but maybe I'm mistaken).

> This affects people who upgrade from openSUSE11.2 (which didn't support v4
> mounts) to openSUSE11.3 (which defaults to v4) and who use network-manager
> (which configures networks late) and have NFS mounts in /etc/fstab with
> either explicit IP addresses or host names that can be resolved without the
> network.
> This config will work because when the network comes up, network-manager will
> re-run the 'init.d/nfs' script.  However since 11.3 there is an unpleasant
> pause before boot completes.


-- 
chuck[dot]lever[at]oracle[dot]com




