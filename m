Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34024 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754860Ab3BVM3D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Feb 2013 07:29:03 -0500
Date: Fri, 22 Feb 2013 07:28:18 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: NeilBrown <neilb@suse.de>, trond.myklebust@netapp.com,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v1] vfs: kill FS_REVAL_DOT by adding a d_reval_jumped
 dentry op
Message-ID: <20130222072818.215d16ee@tlielax.poochiereds.net>
In-Reply-To: <20130221215114.GL4503@ZenIV.linux.org.uk>
References: <1361377145-28094-1-git-send-email-jlayton@redhat.com>
	<20130221093225.5390bb77@notabene.brown>
	<20130221111738.7592bec4@tlielax.poochiereds.net>
	<20130221215114.GL4503@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 21 Feb 2013 21:51:14 +0000
Al Viro <viro@ZenIV.linux.org.uk> wrote:

> On Thu, Feb 21, 2013 at 11:17:38AM -0500, Jeff Layton wrote:
> 
> > Also, since this is the last component of the path, I suspect that
> > we're almost never going to be in rcu-walk mode here, right?
> 
> Take a look at complete_walk(); it starts with leaving RCU mode.  Before
> it gets anywhere near that call.

Ahh good point...so that check is unnecessary with the current caller.

Should we remove it and fix vfs.txt to mention that this should never
be called in RCU mode, or leave it in as a defensive coding measure in
case we add other callers in the future?

I do sort of wonder whether we might eventually change some of the
other places that call d_revalidate now to call to call this instead
when LOOKUP_JUMPED is set.

-- 
Jeff Layton <jlayton@redhat.com>
