Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:51168 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753277Ab3BUVvY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Feb 2013 16:51:24 -0500
Date: Thu, 21 Feb 2013 21:51:14 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Jeff Layton <jlayton@redhat.com>
Cc: NeilBrown <neilb@suse.de>, trond.myklebust@netapp.com,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v1] vfs: kill FS_REVAL_DOT by adding a d_reval_jumped
 dentry op
Message-ID: <20130221215114.GL4503@ZenIV.linux.org.uk>
References: <1361377145-28094-1-git-send-email-jlayton@redhat.com>
 <20130221093225.5390bb77@notabene.brown>
 <20130221111738.7592bec4@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130221111738.7592bec4@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 21, 2013 at 11:17:38AM -0500, Jeff Layton wrote:

> Also, since this is the last component of the path, I suspect that
> we're almost never going to be in rcu-walk mode here, right?

Take a look at complete_walk(); it starts with leaving RCU mode.  Before
it gets anywhere near that call.
