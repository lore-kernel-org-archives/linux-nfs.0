Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:36015 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752629Ab3AUDJp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Jan 2013 22:09:45 -0500
Date: Mon, 21 Jan 2013 03:09:40 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: NeilBrown <neilb@suse.de>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 cannot unmount ESTALE directories (in some cases).
Message-ID: <20130121030940.GS4939@ZenIV.linux.org.uk>
References: <20130121134859.24fbd103@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130121134859.24fbd103@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 21, 2013 at 01:48:59PM +1100, NeilBrown wrote:
> 
> If you use NFSv4 to "mount server:/foo/bar /mnt", then "rm -r" /foo/bar on the
> server, then accesses to /mnt will naturally return ESTALE.
> 
> Unfortunately "umount /mnt" will also return ESTALE and leave the stale
> directory mounted.  Adding "-l" or "-f" to "umount" doesn't help.
> 
> The problem is that nfs_lookup_revalidate fails.  As the mountpoint is never
> not accessed by a lookup (after the initial mount) it seems a bit pointless
> calling d_revalidate in this case ... by maybe not.
> 
> I can make the problem go away by testing for LOOKUP_JUMP and having
> nfs_lookup_revalidate never fail if that flag it set (for a directory).

> However I cannot easily tell if this is an elegant solution of an ugly hack,

The latter.  Definitely.

> and am hoping that someone who understands revalidation and LOOKUP_JUMPED
> better than I (who only discovered the latter today) could provide advice.
> 
> Al?  Trond?  Should  I make this into a formal patch submission, or is there
> a better way?

I really suspect that mountpoint crossing on umount ought to be done
differently.  I'll need to play with possible variants a bit before I can
offer any replacement though...
