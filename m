Return-Path: <trond.myklebust@primarydata.com>
MIME-Version: 1.0
In-Reply-To: <3f289465f9fe9aef49605e1418e6a22c6f3d6118.1443705317.git.bcodding@redhat.com>
References: <3f289465f9fe9aef49605e1418e6a22c6f3d6118.1443705317.git.bcodding@redhat.com>
Date: Fri, 2 Oct 2015 15:54:31 -0400
Message-ID: <CAHQdGtRCDUKmh71YSOvMwEa2-fH7T2=WhNBBAkh__4mY1rAz5g@mail.gmail.com>
Subject: Re: [PATCH] NFSv4: Fix a nograce recovery hang
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 1, 2015 at 9:17 AM, Benjamin Coddington <bcodding@redhat.com> wrote:
> Since commit 5cae02f42793130e1387f4ec09c4d07056ce9fa5 an OPEN_CONFIRM should
> have a privileged sequence in the recovery case to allow nograce recovery to
> proceed for NFSv4.0.
>
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  fs/nfs/nfs4proc.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index f93b9cd..784a649 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -1863,6 +1863,8 @@ static int _nfs4_proc_open_confirm(struct nfs4_opendata *data)
>         data->rpc_done = 0;
>         data->rpc_status = 0;
>         data->timestamp = jiffies;
> +       if (data->is_recover)
> +               nfs4_set_sequence_privileged(&data->c_arg.seq_args);
>         task = rpc_run_task(&task_setup_data);
>         if (IS_ERR(task))
>                 return PTR_ERR(task);
> --

Makes sense. Thanks Ben!
