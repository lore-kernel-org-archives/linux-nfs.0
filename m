Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:50303 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751674Ab0FBFEA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Jun 2010 01:04:00 -0400
Date: Wed, 2 Jun 2010 15:03:51 +1000
From: Neil Brown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: linux-btrfs@vger.kernel.org, linux-nfs@vger.kernel.org, jeffm@suse.com
Subject: Re: NFS exporting btrfs subvolumes.
Message-ID: <20100602150351.592e36a8@notabene.brown>
In-Reply-To: <1275450980.4509.13.camel@heimdal.trondhjem.org>
References: <20100602134145.0d523a75@notabene.brown>
	<1275450980.4509.13.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 01 Jun 2010 23:56:20 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Wed, 2010-06-02 at 13:41 +1000, Neil Brown wrote:
> > NFS needs a unique identifier for a filesystem to be able to export it.
> <snip>
> > Can anyone suggest a better way to get a good uuid for a btrfs filesystem?
> 
> How about just adding the btrfs subvolid to the filehandle and using
> that to remove the ambiguity?

The filehandle has two parts - one part identifies the filesystem
(i.e. vfsmnt), the other identifies the file (the dentry).
We would need to get the btrfs subvolid into the filesystem part,
and that is set (and looked-up) by mountd in user-space.

I think you are suggesting getting the btrfs kernel module to put the
subvolid in the filehandle, but that would only go in the 'file' part
of the handle, so it would not be sufficient.

We need a user-space program - preferably without too much
filesystem-specific info - to be able to differentiate subvolumes.

Thanks,
NeilBrown

