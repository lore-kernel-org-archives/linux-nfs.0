Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:59350 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755106Ab3GOKnB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Jul 2013 06:43:01 -0400
Date: Mon, 15 Jul 2013 06:43:15 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, bfields@fieldses.org
Subject: Re: [PATCH v2] rpc_pipe: set dentry operations at d_alloc time
Message-ID: <20130715064315.1adc9543@corrin.poochiereds.net>
In-Reply-To: <20130714140011.GI4165@ZenIV.linux.org.uk>
References: <1372122340-28982-1-git-send-email-jlayton@redhat.com>
	<1372784452-2403-1-git-send-email-jlayton@redhat.com>
	<20130714140011.GI4165@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 14 Jul 2013 15:00:11 +0100
Al Viro <viro@ZenIV.linux.org.uk> wrote:

> On Tue, Jul 02, 2013 at 01:00:52PM -0400, Jeff Layton wrote:
> > Currently the way these get set is a little convoluted. If the dentry is
> > allocated via lookup from userland, then it gets set by simple_lookup.
> > If it gets allocated when the kernel is populating the directory, then
> > it gets set via __rpc_lookup_create_exclusive, which has to check
> > whether they might already be set. Between both of these, this ensures
> > that all dentries have their d_op pointer set.
> > 
> > Instead of doing that, just have them set at d_alloc time by pointing
> > sb->s_d_op at them. With that change, we no longer want the lookup op
> > to set them, so we must move to using our own lookup routine.
> 
> There's a better solution - just make simple_lookup() skip d_set_d_op()
> if superblock already has ->s_d_op (and thus d_alloc() has already
> set the damn thing).  Voila - we can just set ->s_d_op and leave
> inode_operations as is.

Yeah, that is a better solution and the code now in mainline looks
reasonable. Trond already merged this patch however, so I'll spin up
another patch on top of mainline to convert this back to
simple_dir_inode_operations.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
