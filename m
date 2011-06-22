Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:42616 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758544Ab1FVTbT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2011 15:31:19 -0400
Date: Wed, 22 Jun 2011 20:31:18 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: linux-nfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [nfs, rpc] crap with refcounting and rmmod races
Message-ID: <20110622193118.GE11521@ZenIV.linux.org.uk>
References: <20110622191239.GD11521@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110622191239.GD11521@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jun 22, 2011 at 08:12:40PM +0100, Al Viro wrote:

> 	Note that extra references to vfsmount do not prevent umount from
> removing the sucker from the tree and dropping the preexisting reference
> to it.  umount -l will do that just fine.
> 
> 	This thing is called as ->rpc_release(); do we have anything
> protecting the issuer of rpc_run_task() from being rmmod'ed before (or
> during) the call of ->rpc_release()?

While we are at it, is ->rpc_release() allowed to trigger rpc_shutdown_client()
on out ->tk_client?
