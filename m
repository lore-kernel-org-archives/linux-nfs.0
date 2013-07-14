Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:43029 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491Ab3GNOAQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Jul 2013 10:00:16 -0400
Date: Sun, 14 Jul 2013 15:00:11 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Jeff Layton <jlayton@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, bfields@fieldses.org
Subject: Re: [PATCH v2] rpc_pipe: set dentry operations at d_alloc time
Message-ID: <20130714140011.GI4165@ZenIV.linux.org.uk>
References: <1372122340-28982-1-git-send-email-jlayton@redhat.com>
 <1372784452-2403-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1372784452-2403-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 02, 2013 at 01:00:52PM -0400, Jeff Layton wrote:
> Currently the way these get set is a little convoluted. If the dentry is
> allocated via lookup from userland, then it gets set by simple_lookup.
> If it gets allocated when the kernel is populating the directory, then
> it gets set via __rpc_lookup_create_exclusive, which has to check
> whether they might already be set. Between both of these, this ensures
> that all dentries have their d_op pointer set.
> 
> Instead of doing that, just have them set at d_alloc time by pointing
> sb->s_d_op at them. With that change, we no longer want the lookup op
> to set them, so we must move to using our own lookup routine.

There's a better solution - just make simple_lookup() skip d_set_d_op()
if superblock already has ->s_d_op (and thus d_alloc() has already
set the damn thing).  Voila - we can just set ->s_d_op and leave
inode_operations as is.
