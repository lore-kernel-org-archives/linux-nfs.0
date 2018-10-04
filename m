Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49990 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727355AbeJDVDv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 Oct 2018 17:03:51 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <153861496327.30373.10501882399296347125.stgit@noble>
References: <153861496327.30373.10501882399296347125.stgit@noble> <153861471803.30373.6184444014227748848.stgit@noble>
To: NeilBrown <neilb@suse.com>
Cc: dhowells@redhat.com, "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Jan Harkes <jaharkes@cs.cmu.edu>, linux-nfs@vger.kernel.org,
        Miklos Szeredi <miklos@szeredi.hu>,
        Jeff Layton <jlayton@kernel.org>, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, coda@cs.cmu.edu,
        linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 1/3] VFS: introduce MAY_ACT_AS_OWNER
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Thu, 04 Oct 2018 15:10:13 +0100
Message-ID: <28763.1538662213@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NeilBrown <neilb@suse.com> wrote:

> diff --git a/fs/afs/security.c b/fs/afs/security.c
> index 81dfedb7879f..ac2e39de8bff 100644
> --- a/fs/afs/security.c
> +++ b/fs/afs/security.c
> @@ -349,6 +349,16 @@ int afs_permission(struct inode *inode, int mask)
>  	if (mask & MAY_NOT_BLOCK)
>  		return -ECHILD;
>  
> +	/* Short-circuit for owner */
> +	if (mask & MAY_ACT_AS_OWNER) {
> +		if (inode_owner_or_capable(inode))

You don't know that inode->i_uid in meaningful.  You may have noticed that
afs_permission() ignores i_uid and i_gid entirely.  It queries the server (if
this information is not otherwise cached) to ask what permits the user is
granted - where the user identity is defined by the key returned from
afs_request_key()[*].

So, NAK for the afs piece.

David

[*] If there's no appropriate key, anonymous permits will be used.
