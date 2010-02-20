From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] nfs-utils: add and use nfs_authsys_create
Date: Fri, 19 Feb 2010 20:11:25 -0800
Message-ID: <20100219201125.2a1a99d2@tupile.poochiereds.net>
References: <1266620728-14574-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9485 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755842Ab0BTELQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Feb 2010 23:11:16 -0500
In-Reply-To: <1266620728-14574-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 19 Feb 2010 18:05:28 -0500
Jeff Layton <jlayton@redhat.com> wrote:

> The current mount, umount and showmount code uses
> authunix_create_default to get an auth handle. The one provided by glibc
> returned a truncated list of groups when there were more than 16 groups.
> libtirpc however currently does an abort() in this case, which causes
> the program to crash and dump core.
> 
> nfs-utils just uses these auth handles for the MNT protocol, so the
> group list doesn't make a lot of difference here. Add a new function
> that creates an auth handle with a supplemental gids list that consists
> only of the primary gid. Have nfs-utils use that function anywhere that
> it currently uses authunix_create_default. Also, have the caller
> properly check for a NULL return from that function.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

My apologies -- I mistakenly sent out an earlier version of this patch
instead of the latest. I just sent the right version of this patch as
"try #2".

-- 
Jeff Layton <jlayton@redhat.com>
