Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37977 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752846Ab3ABVoC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Jan 2013 16:44:02 -0500
Date: Wed, 2 Jan 2013 16:43:55 -0500
To: Erik Slagter <erik@slagter.name>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: NFS client large rsize/wsize (tcp?) problems
Message-ID: <20130102214355.GB26356@fieldses.org>
References: <50E0393E.7040204@slagter.name>
 <20130102182147.GA25450@fieldses.org>
 <50E47E83.1030208@slagter.name>
 <4FA345DA4F4AE44899BD2B03EEEC2FA91198300A@SACEXCMBX04-PRD.hq.netapp.com>
 <50E488C1.6040901@slagter.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <50E488C1.6040901@slagter.name>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 02, 2013 at 08:21:37PM +0100, Erik Slagter wrote:
> On 02-01-13 19:47, Myklebust, Trond wrote:
> 
> > You probably have a NIC that doesn't support scatter-gather.
> 
> I am not 100% sure, but as it's a satellite set-top-box, with very basic
> ethernet connectivity, I'd say you're right on the spot.
> 
> Is there a way to workaround that?
> 
> >> As a temporary workaround (for "dumb users" that don't know what a mount
> >> option is, yes it's awful!) I'd like to modify the kernel of the clients
> >> to negotiate a smaller buffer size, 32k would probably suffice. I've had
> >> a few shots but have not been successful yet, can you give me a pointer
> >> please?
> 
> > man nfsmount.conf
> 
> Thanks for the hint, I didn't know that! Unfortunately I can't use it,
> because the mount command on the stb is a "busybox" version, so it's
> very basic, and doesn't check this file (checked it using strace...)

You can also configure this server-side by writing to
/proc/fs/nfsd/max_block_size (or your distro may have some config file
where that's set).  But then of course it limits all clients whether
they need the workaround or not.

--b.
