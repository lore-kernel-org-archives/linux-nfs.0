Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:38728 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750752Ab1BIFZp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Feb 2011 00:25:45 -0500
Date: Wed, 9 Feb 2011 16:25:33 +1100
From: NeilBrown <neilb@suse.de>
To: Karel Zak <kzak@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: mount.nfs libmount support
Message-ID: <20110209162533.7c9d6450@notabene.brown>
In-Reply-To: <1297172717-26431-1-git-send-email-kzak@redhat.com>
References: <1297172717-26431-1-git-send-email-kzak@redhat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue,  8 Feb 2011 14:45:15 +0100 Karel Zak <kzak@redhat.com> wrote:

> Hi Chuck,
> 
> this is the first version of the mount.nfs with libmount support. The code
> depends on the latest util-linux code from upstream git tree, or you can 
> wait few days for official 2.19 util-linux tarballs (and Fedora binary rpms).
> 
> I have tested:
> 
> 	mount.nfs server://path /mountpoint
> 	mount.nfs server://path /mountpoint -o remount,ro
> 	mount.nfs server://path /mountpoint -o user

Probably a small point but.... you do know that isn't the standard syntax for
NFS mounts, don't you?  NFS uses a single slash.

        mount.nfs server:/path /mountpoint ...

NeilBrown


> 
> 	umount.nfs server://path
> 	umount.nfs /mountpoint
> 
> .. works for me. For more information see the second patch.
> 
> 	Karel
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

