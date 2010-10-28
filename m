From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] nfs4: The difference of 2 pointers is size_t
Date: Thu, 28 Oct 2010 14:17:14 -0400
Message-ID: <1288289834.14221.12.camel@heimdal.trondhjem.org>
References: <alpine.DEB.2.00.1010282004390.31018@ayla.of.borg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Benny Halevy <bhalevy@panasas.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-nfs@vger.kernel.org,
	Linux Kernel Development <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1706 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755321Ab0J1SSK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Oct 2010 14:18:10 -0400
In-Reply-To: <alpine.DEB.2.00.1010282004390.31018-97SZ98TBZzA1xEWliksxXw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-10-28 at 20:06 +0200, Geert Uytterhoeven wrote:
> On m68k, which is 32-bit:
>=20
> fs/nfs/nfs4proc.c: In function =E2=80=98nfs41_sequence_done=E2=80=99:
> fs/nfs/nfs4proc.c:432: warning: format =E2=80=98%ld=E2=80=99 expects =
type =E2=80=98long int=E2=80=99, but argument 3 has type =E2=80=98int=E2=
=80=99
> fs/nfs/nfs4proc.c: In function =E2=80=98nfs4_setup_sequence=E2=80=99:
> fs/nfs/nfs4proc.c:576: warning: format =E2=80=98%ld=E2=80=99 expects =
type =E2=80=98long int=E2=80=99, but argument 5 has type =E2=80=98int=E2=
=80=99
>=20
> On 32-bit, size_t is int; on 64-bit, size_t is long.
>=20
> Introduced by commit dfb4f309830359352539919f23accc59a20a3758 ("NFSv4=
=2E1: keep
> seq_res.sr_slot as pointer rather than an index")
>=20
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> ---
>  fs/nfs/nfs4proc.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 32c8758..80229dc 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -429,7 +429,7 @@ static int nfs41_sequence_done(struct rpc_task *t=
ask, struct nfs4_sequence_res *
>  		 * returned NFS4ERR_DELAY as per Section 2.10.6.2
>  		 * of RFC5661.
>  		 */
> -		dprintk("%s: slot=3D%ld seq=3D%d: Operation in progress\n",
> +		dprintk("%s: slot=3D%zd seq=3D%d: Operation in progress\n",
>  			__func__,
>  			res->sr_slot - res->sr_session->fc_slot_table.slots,
>  			res->sr_slot->seq_nr);
> @@ -573,7 +573,7 @@ int nfs4_setup_sequence(const struct nfs_server *=
server,
>  		goto out;
>  	}
> =20
> -	dprintk("--> %s clp %p session %p sr_slot %ld\n",
> +	dprintk("--> %s clp %p session %p sr_slot %zd\n",
>  		__func__, session->clp, session, res->sr_slot ?
>  			res->sr_slot - session->fc_slot_table.slots : -1);
> =20

Thanks! Applied.

Trond
