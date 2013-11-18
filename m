Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:38119 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167Ab3KRNA1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Nov 2013 08:00:27 -0500
Date: Mon, 18 Nov 2013 05:00:26 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Albert Fluegel <af@muc.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Bugs / Patch in nfsd
Message-ID: <20131118130026.GA4153@infradead.org>
References: <20131118124406.GA46678@colin.muc.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131118124406.GA46678@colin.muc.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 18, 2013 at 01:44:06PM +0100, Albert Fluegel wrote:
> directly or indirectly.
> One change:
> diff -r kernel-2.6.18-308/linux-2.6.18-308.11.1.el5.i386/fs/nfsd/vfs.c kernel-2.6.18-348/linux-2.6.18-348.3.1.el5.i386/fs/nfsd/vfs.c
> 725a727,733
> > 	else {
> > 		if (may_flags & NFSD_MAY_64BIT_COOKIE)
> > 			(*filp)->f_mode |= FMODE_64BITHASH;
> > 		else
> > 			(*filp)->f_mode |= FMODE_32BITHASH;
> > 	}
> > 
> 
> makes bits set in the mode field of the
> RPC reply, that are used internally by the kernel.
>
> They should really not go into the RPC reply.
> imo these internally used bits should be set in an own component of
> the struct and not in f_mode (like the f_type, which is separate).
> Probably for NFSv4 this must be fixed, too.

I can't see how NFSD ever exports f_mode.  This is a kernel-internal
field that doesn't make a whole lot of sense over the wire.  What gets
sent in nfsd GETATTR operations is the mode field from the stat (or more
specificly the kstat) structure, which contain entirely different
constants.

I have to admit that I still don't quite understand how the f_mode
access in nfsd_open() is supposed to work race-free, though.

> The other problem is, that the nfsd_readdir seems not to find cookies
> or at least does not position the read pointer correctly and starts
> reading the directory anew, causing the (Solaris) client to be in an
> endless loop. The cookie returned in a "Read Directory" reply is actually
> 32 bit and with the next query issued with this (identical) cookie
> the Linux NFS server replies with the directories started anew.
> I don't know, in how far the cookies depend on the client. However,
> with a Solaris client i consider it worth noting, that in the reply
> to the directory read the upper 32 bits are either all 0 or all 1
> (0xffffffff). With a Linux client, they are either 0 or have some
> random value, but not constantly 0xffffffff .

Just curious, do you see the same issues if not using ext3/ext4 which
have a the 64-bit directory cookie issue but XFS instead?

>  	*p++ = htonl(nfs3_ftypes[(stat->mode & S_IFMT) >> 12]);
> -	*p++ = htonl((u32) stat->mode);
> +	*p++ = htonl((u32) (stat->mode & (S_IRWXU | S_IRWXG | S_IRWXO | S_ISUID | S_ISGID | S_ISVTX)));

Should be S_IALLUGO instead of manually repeating the flags.  While this
is a good practice and I'm in favour of it, I'd love to know what other
value you see in the mode field.  Do you have a wireshark dump or a
trace?

