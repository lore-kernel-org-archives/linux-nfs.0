Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41210 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752472Ab1D0SJ4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Apr 2011 14:09:56 -0400
Date: Wed, 27 Apr 2011 14:09:39 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: don't lose MS_SYNCHRONOUS on remount of noac mount
Message-ID: <20110427140939.69ea0d9a@tlielax.poochiereds.net>
In-Reply-To: <1303927307.13195.20.camel@lade.trondhjem.org>
References: <1303919349-30207-1-git-send-email-jlayton@redhat.com>
	<1303927307.13195.20.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 27 Apr 2011 14:01:47 -0400
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> On Wed, 2011-04-27 at 11:49 -0400, Jeff Layton wrote:
> > On a remount, the VFS layer will clear the MS_SYNCHRONOUS bit on the
> > assumption that the flags on the mount syscall will have it set if the
> > remounted fs is supposed to keep it.
> > 
> > In the case of "noac" though, MS_SYNCHRONOUS is implied. A remount of
> > such a mount will lose the MS_SYNCHRONOUS flag since "sync" isn't part
> > of the mount options.
> > 
> > Reported-by: Max Matveev <makc@redhat.com>
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> 
> Should this be 'Cc: stable@kernel.org'?

Yes, it wouldn't hurt. Not an extremely critical bug, but it's a
fairly straightforward fix. Can you add that, or would you rather I
resend?

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
