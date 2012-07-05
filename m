Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48854 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755576Ab2GEV4u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jul 2012 17:56:50 -0400
Date: Thu, 5 Jul 2012 17:56:49 -0400
To: Song Gao <song.gao.beta@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Possible bug in NFSv4 server regarding to looking for right
 path for clients to mount
Message-ID: <20120705215649.GD3051@fieldses.org>
References: <CAKeNtnQK5QEgRZKXHnmMQK6R+L1nXQNX0M4y1ZWuKo7GbEingA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAKeNtnQK5QEgRZKXHnmMQK6R+L1nXQNX0M4y1ZWuKo7GbEingA@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 02, 2012 at 01:11:39AM -0500, Song Gao wrote:
> Hello,
> 
> There's possibly a bug related NFSv4 server's behavior on looking for
> path on /export .
> 
> I have a 32 nodes KVM cluster. NFS, host filesystem, KVM storage pool,
> are all placed on SSD. KVM guests are connected to host through virtio
> drived GB ethernet.
> 
> I followed this guide to configure NFS:
> https://help.ubuntu.com/community/SettingUpNFSHowTo
> 
> The problem was that, when I execute a program simultaneously (through
> cssh) on 32 nodes, there were always a number of nodes that
> encountered "input/output error". The /var/log/messages on client
> shows "state manager failed on NFSv4 server with error 10022".

That's NFS4ERR_STALE_CLIENTID.

That's an odd thing to happen.  I'd be curious to know which operation
exactly the server was returning that error to.  Normally that should
only happen if the server rebooted.

> I tried different options in client /etc/fstab as well as export
> settings in server but nothing helps. Interestingly, by changing the
> item in /etc/fstab from:
>     some-host:/tigers  nfs    rw,bg,hard,intr    0    0
> into:
>     some-host:/export/tigers    /nfs    nfs    rw,bg,hard,intr    0    0
> fixed the problem.

The advice to use "fsid=0" in the ubuntu howto is out of date.  With a
recent server you should just export and mount /export/tigers as you
would with NFSv3.

If you do as you've done above (and as is sugested in that howto), then
clients see different paths depending on whether they're using v3 or v4.

When you changed the client to mount /export/tigers, it probably
couldn't find that path, so tried v3 instead.  That works around the v4
bug.

If you change the exports to remove fsid=0, then you'll probably want to
mount with nfsvers=3 to continue working around the v4 bug.

> I'm not familiar with it but I guess that it's probably caused by some
> problem in NFS server when it tries to find the right path when all 32
> clients are trying to mount NFS at the same time.
> 
> Here's some more information:
> client: debian "squeeze", 2.6.32-5-amd64
> server: Ubuntu Server 12.04, 3.2.0-23-generic

Might be worth trying more recent versions.  The client especially has
seen a lot of v4 changes since 2.6.32.

--b.

> nfs version: NFSv4
> no security option
> results of `exports -v`:
>     /export 192.168.100.0/24(rw,wdelay,insecure,root_squash,no_subtree_check,fsid=0)
>     /export/tigers
> 192.168.100.0/24(rw,wdelay,nohide,insecure,root_squash,no_subtree_check)
> 
> Please let me know if there's any other information I need to provide.
> 
> Thanks!
> 
> 
> Kind regards,
> -- 
> Song Gao
> https://profiles.google.com/song.gao.beta/about
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
