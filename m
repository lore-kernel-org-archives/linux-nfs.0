Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:39230 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751033AbdLDPvL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 4 Dec 2017 10:51:11 -0500
Date: Mon, 4 Dec 2017 10:51:11 -0500
To: Emil Flink <emil.flink@bublar.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Client locks up with nfs4_reclaim_open_state: Lock reclaim
 failed!
Message-ID: <20171204155111.GC4405@fieldses.org>
References: <CAELMAQQGxK=2CgfqLnajhvt-ParO6WoX-gBY19Z4pN9DRaArtQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAELMAQQGxK=2CgfqLnajhvt-ParO6WoX-gBY19Z4pN9DRaArtQ@mail.gmail.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 30, 2017 at 03:49:15PM +0100, Emil Flink wrote:
> Hi,
> 
> I'm not sure where to go with this issue so please free to point me to
> a more suitable forum if necessary.
> 
> My issue is that a client mounting a NFS share frequently locks up
> with massive amounts of "nfs4_reclaim_open_state: Lock reclaim
> failed!" in the kernel logs. Meanwhile the NFS server does not log any
> errors as far as I can tell.
> 
> I only encounter this when the client is doing a lot of I/O against
> the NFS share.
> 
> To recover from this I have to kill all processes on the client using
> the NFS share, unmount the NFS share and remount it.
> 
> The NFS export is mounted with:
> 10.0.1.203:/nfs/lxc-office on /var/lib/lxc type nfs4
> (rw,noatime,vers=4.2,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=10.0.1.231,local_lock=none,addr=10.0.1.203)
> 
> Both the server and the client is running up-to-date installations of
> Debian 9 ("stretch"), meaning kernel 4.9.0-4 and nfs-common /
> nfs-kernel-server 1.3.4-2.1.

It's not a very satisfying answer, I know, but unless someone else
recognizes the issue off the top of their heads, best is probably to
install the latest upstream kernel and see if that resolves the problem,
and if so that would help narrow down where it was fixed.

Any bug is almost certainly in the kernel, so you don't need to upgrade
anything but the kernel (you can leave nfs-common/nfs-kernel-server
alone).
