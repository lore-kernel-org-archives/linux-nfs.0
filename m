From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [KJ] [PATCH 03/04]use set_current_state in fs
Date: Sat, 14 Apr 2007 11:39:11 +0200
Message-ID: <4620A13F.6060502@cosmosbay.com>
References: <20070414084956.GD14084@arun.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: kernel-janitors@lists.osdl.org, akpm@linux-foundation.org,
   nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
   trond.myklebust@fys.uio.no
To: Milind Arun Choudhary <milindchoudhary@gmail.com>
Return-path: <kernel-janitors-bounces@lists.linux-foundation.org>
In-Reply-To: <20070414084956.GD14084@arun.site>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/kernel-janitors>
List-Post: <mailto:kernel-janitors@lists.linux-foundation.org>
List-Help: <mailto:kernel-janitors-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.linux-foundation.org?subject=subscribe>
Sender: kernel-janitors-bounces@lists.linux-foundation.org
Errors-To: kernel-janitors-bounces@lists.linux-foundation.org
List-ID: <nfs.lists.sourceforge.net>

Milind Arun Choudhary a =E9crit :
> use set_current_state(TASK_*) instead of current->state =3D TASK_*, in fs=
/nfs
> =

> Signed-off-by: Milind Arun Choudhary <milindchoudhary@gmail.com>
> =

> =

> ---
>  idmap.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> =

> diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
> index 9d4a6b2..054ca15 100644
> --- a/fs/nfs/idmap.c
> +++ b/fs/nfs/idmap.c
> @@ -272,7 +272,7 @@ nfs_idmap_id(struct idmap *idmap, struct idmap_hashta=
ble *h,
>  	set_current_state(TASK_UNINTERRUPTIBLE);
>  	mutex_unlock(&idmap->idmap_im_lock);
>  	schedule();
> -	current->state =3D TASK_RUNNING;
> +	set_current_state(TASK_RUNNING);
>  	remove_wait_queue(&idmap->idmap_wq, &wq);
>  	mutex_lock(&idmap->idmap_im_lock);

Probably a dumb question, so please forgive me.

Why are you  forcing a memory barrier here, (and also on your other patches=
).

Is'nt a  __set_current_state(TASK_RUNNING); appropriate ?
