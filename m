From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd/nfs4acl: Number of used used array elements needs
	to be zeroed.
Date: Thu, 4 Sep 2008 11:01:01 -0400
Message-ID: <20080904150101.GB4536@fieldses.org>
References: <20080904165518.15a02908@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	neilb@suse.de
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:35934 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751013AbYIDPBD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Sep 2008 11:01:03 -0400
In-Reply-To: <20080904165518.15a02908-YzwxZg+R7evSU73v1vjTzyO4YDw3rz4rAInAS/Ez/D0@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 04, 2008 at 04:55:18PM +0200, Jiri Pirko wrote:
> Number of used used array elements needs to be zeroed. It may cause
> problems otherwise, because it's used uninitialized in find_uid().
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> ---
>  fs/nfsd/nfs4acl.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
> index 54b8b41..7dcd90f 100644
> --- a/fs/nfsd/nfs4acl.c
> +++ b/fs/nfsd/nfs4acl.c
> @@ -447,11 +447,13 @@ init_state(struct posix_acl_state *state, int cnt)
>  	state->users = kzalloc(alloc, GFP_KERNEL);
>  	if (!state->users)
>  		return -ENOMEM;
> +	state->users->n = 0;
>  	state->groups = kzalloc(alloc, GFP_KERNEL);
>  	if (!state->groups) {
>  		kfree(state->users);
>  		return -ENOMEM;
>  	}
> +	state->groups->n = 0;
>  	return 0;
>  }

Thanks for the extra eyes on this code, but: surely the kzalloc()'s are
all that's necessary?  Am I missing something?

--b.
