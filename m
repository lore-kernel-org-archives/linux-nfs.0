Return-Path: <BATV+7d580da61648ed217d10+4488+infradead.org+hch@bombadil.srs.infradead.org>
Date: Mon, 7 Dec 2015 10:40:36 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, hch@infradead.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 02/10] NFS: Move the flock open mode check into
 nfs_flock()
Message-ID: <20151207184036.GA28959@infradead.org>
References: <cover.1449503713.git.bcodding@redhat.com>
 <cc80e246ee323a21f3f318248bf38eda668e8eb9.1449503713.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cc80e246ee323a21f3f318248bf38eda668e8eb9.1449503713.git.bcodding@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 07, 2015 at 11:26:01AM -0500, Benjamin Coddington wrote:
> We only need to check lock exclusive/shared types against open mode when
> flock() is used on NFS, so move it into the flock-specific path instead of
> checking it for all locks.
> 
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  fs/nfs/file.c     |   15 +++++++++++++++
>  fs/nfs/nfs4proc.c |   13 -------------
>  2 files changed, 15 insertions(+), 13 deletions(-)
> 
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index 93e2364..ec16abc 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -893,6 +893,21 @@ int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
>  	/* We're simulating flock() locks using posix locks on the server */
>  	if (fl->fl_type == F_UNLCK)
>  		return do_unlk(filp, cmd, fl, is_local);
> +
> +	/*
> +	 * Don't rely on the VFS having checked the file open mode,
> +	 * since it won't do this for flock() locks.
> +	 */

As this is only called for flock the comment doesn't make sense.  And
maybe it's also time to ask why the VFS doesn't do this, as I'd expect
it to perform this instead of every file system.
