Return-Path: <trond.myklebust@primarydata.com>
MIME-Version: 1.0
In-Reply-To: <79adfc63f33887475f6a0f0eeaacd8b52b2ed12c.1458119750.git.bcodding@redhat.com>
References: <79adfc63f33887475f6a0f0eeaacd8b52b2ed12c.1458119750.git.bcodding@redhat.com>
Date: Wed, 16 Mar 2016 09:14:24 -0400
Message-ID: <CAHQdGtS4pViRyWc+K+CLhmGrt1ar5PRcMpURap2_x2B5QpU2Fw@mail.gmail.com>
Subject: Re: [PATCH] NFS: Retry a zero-length short read
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 16, 2016 at 5:17 AM, Benjamin Coddington
<bcodding@redhat.com> wrote:
>
> A zero-length short read without eof should be retried rather than sending
> an error to the application.


In what situation would returning a 0 length read not be a bug? If the
server intended that we back off and retry, it has the alternative of
sending a JUKEBOX/DELAY error.


> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  fs/nfs/read.c |    5 -----
>  1 files changed, 0 insertions(+), 5 deletions(-)
>
> diff --git a/fs/nfs/read.c b/fs/nfs/read.c
> index eb31e23..7269d42 100644
> --- a/fs/nfs/read.c
> +++ b/fs/nfs/read.c
> @@ -244,11 +244,6 @@ static void nfs_readpage_retry(struct rpc_task *task,
>
>         /* This is a short read! */
>         nfs_inc_stats(hdr->inode, NFSIOS_SHORTREAD);
> -       /* Has the server at least made some progress? */
> -       if (resp->count == 0) {
> -               nfs_set_pgio_error(hdr, -EIO, argp->offset);
> -               return;
> -       }
>
>         /* For non rpc-based layout drivers, retry-through-MDS */
>         if (!task->tk_ops) {
> --
> 1.7.1
>
