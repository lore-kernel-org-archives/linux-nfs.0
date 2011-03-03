Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:60049 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758465Ab1CCOtW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Mar 2011 09:49:22 -0500
Subject: Re: mount.nfs libmount support (v2)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1299159822-25190-1-git-send-email-kzak@redhat.com>
Date: Thu, 3 Mar 2011 09:48:00 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <53DAB8EE-E7FD-4081-9227-5C8DB072945B@oracle.com>
References: <1299159822-25190-1-git-send-email-kzak@redhat.com>
To: Karel Zak <kzak@redhat.com>, Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Mar 3, 2011, at 8:43 AM, Karel Zak wrote:

> This is the second version of the mount.nfs with libmount support. The code
> depends on util-linux >= v2.19 (e.g. Fedora 15).
> 
> Chnages:
>  - move nfs_umount_do_umnt() to network.c
>  - use union nfs_sockaddr
>  - add missing GPL address paragraph
>  - use abstract function the storing and retrieval mount options
>  - use "static const" for struct option
>  - use "strncmp() == 0" everywhere
> 
> 
> The locale issue is not fixed. It seems that _() macro from nls.h is used on
> many places in the package, but ENABLE_NLS macro is nowhere defined and 
> setlocale() is not called at all.
> 
> I believe that this issue should be fixed independently on the libmount
> patches.

Thanks for the update.

The overall architecture looks sane to me.  I think we would accelerate adoption by having nfs-utils take this now as an experimental "technology preview" thing, so the new code is widely available in a shared repo.  That would make it easier for people to play with it as libmount becomes available in more distributions.  We can then quickly make any minor adjustments needed.  Steve, thoughts?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




