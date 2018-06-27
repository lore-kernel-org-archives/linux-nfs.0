Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:48594 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752003AbeF0ANo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jun 2018 20:13:44 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.4 \(3445.8.2\))
Subject: Re: [RFC PATCH 3/3] sunrpc: Change rpc_print_iostats to
 rpc_clnt_show_stats and handle rpc_clnt clones
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180626235623.26898-4-dwysocha@redhat.com>
Date: Tue, 26 Jun 2018 20:13:27 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <E7A8E5A1-7EC0-4DF4-9568-C16E834AFAFE@oracle.com>
References: <20180626235623.26898-1-dwysocha@redhat.com>
 <20180626235623.26898-4-dwysocha@redhat.com>
To: Dave Wysochanski <dwysocha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jun 26, 2018, at 7:56 PM, Dave Wysochanski <dwysocha@redhat.com> =
wrote:
>=20
> The existing rpc_print_iostats has a few shortcomings.  First, the =
naming
> is not consistent with other functions in the kernel that display =
stats.
> Second, it is really displaying stats for an rpc_clnt structure as it
> displays both xprt stats and per-op stats.  Third, it does not handle
> rpc_clnt clones, which is important for the one in-kernel tree caller
> of this function, the NFS client's nfs_show_stats function.
>=20
> Fix all of the above by renaming the rpc_print_iostats to
> rpc_clnt_show_stats and looping through any rpc_clnt clones via
> cl_parent.
>=20
> Once this interface is fixed, this addresses a problem with NFSv4.
> Before this patch, the /proc/self/mountstats always showed incorrect
> counts for NFSv4 state related opcodes such as SEQUENCE and RENEW.
> These counts were always 0 even though many ops would go over the
> wire.  The reason for this is there are multiple rpc_clnt structures
> allocated for any given NFSv4 mount, and inside nfs_show_stats() we =
callled
> into rpc_print_iostats() which only handled one of them, =
nfs_server->client.
> Fix these counts by calling sunrpc's new rpc_clnt_show_stats() =
function,
> which handles cloned rpc_clnt structs and prints the stats together.
>=20
> Note that one side-effect of the above is that multiple mounts from
> the same NFS server will show identical counts in the above ops due
> to the fact the one rpc_clnt (representing the NFSv4 client state)
> is shared across mounts.
>=20
> Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> ---
> fs/nfs/super.c                 |  2 +-
> include/linux/sunrpc/metrics.h |  6 +++---
> net/sunrpc/stats.c             | 17 ++++++++++++-----
> 3 files changed, 16 insertions(+), 9 deletions(-)
>=20
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 5e470e233c83..bdf39fa1bfbc 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -884,7 +884,7 @@ int nfs_show_stats(struct seq_file *m, struct =
dentry *root)
> #endif
> 	seq_printf(m, "\n");
>=20
> -	rpc_print_iostats(m, nfss->client);
> +	rpc_clnt_show_stats(m, nfss->client);
>=20
> 	return 0;
> }
> diff --git a/include/linux/sunrpc/metrics.h =
b/include/linux/sunrpc/metrics.h
> index 9baed7b355b2..3daa5b42d871 100644
> --- a/include/linux/sunrpc/metrics.h
> +++ b/include/linux/sunrpc/metrics.h
> @@ -30,7 +30,7 @@
> #include <linux/ktime.h>
> #include <linux/spinlock.h>
>=20
> -#define RPC_IOSTATS_VERS	"1.0"
> +#define RPC_IOSTATS_VERS	"1.1"

A quick browse does not reveal a format change in /proc/self/mountstats.
Did I miss it? If there's no change, VERS should stay "1.0".


> struct rpc_iostats {
> 	spinlock_t		om_lock;
> @@ -82,7 +82,7 @@ void			rpc_count_iostats(const =
struct rpc_task *,
> 					  struct rpc_iostats *);
> void			rpc_count_iostats_metrics(const struct rpc_task =
*,
> 					  struct rpc_iostats *);
> -void			rpc_print_iostats(struct seq_file *, struct =
rpc_clnt *);
> +void			rpc_clnt_show_stats(struct seq_file *, struct =
rpc_clnt *);
> void			rpc_free_iostats(struct rpc_iostats *);
>=20
> #else  /*  CONFIG_PROC_FS  */
> @@ -95,7 +95,7 @@ static inline void rpc_count_iostats_metrics(const =
struct rpc_task *task,
> {
> }
>=20
> -static inline void rpc_print_iostats(struct seq_file *seq, struct =
rpc_clnt *clnt) {}
> +static inline void rpc_clnt_show_stats(struct seq_file *seq, struct =
rpc_clnt *clnt) {}
> static inline void rpc_free_iostats(struct rpc_iostats *stats) {}
>=20
> #endif  /*  CONFIG_PROC_FS  */
> diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
> index 32adddd7fb78..2c9453465c78 100644
> --- a/net/sunrpc/stats.c
> +++ b/net/sunrpc/stats.c
> @@ -235,13 +235,12 @@ static void _print_rpc_iostats(struct seq_file =
*seq, struct rpc_iostats *stats,
> 		   ktime_to_ms(stats->om_execute));
> }
>=20
> -void rpc_print_iostats(struct seq_file *seq, struct rpc_clnt *clnt)
> +void rpc_clnt_show_stats(struct seq_file *seq, struct rpc_clnt *clnt)
> {
> -	struct rpc_iostats *stats =3D clnt->cl_metrics;
> 	struct rpc_xprt *xprt;
> 	unsigned int op, maxproc =3D clnt->cl_maxproc;
>=20
> -	if (!stats)
> +	if (!clnt->cl_metrics)
> 		return;
>=20
> 	seq_printf(seq, "\tRPC iostats version: %s  ", =
RPC_IOSTATS_VERS);
> @@ -256,10 +255,18 @@ void rpc_print_iostats(struct seq_file *seq, =
struct rpc_clnt *clnt)
>=20
> 	seq_printf(seq, "\tper-op statistics\n");
> 	for (op =3D 0; op < maxproc; op++) {
> -		_print_rpc_iostats(seq, &stats[op], op, =
clnt->cl_procinfo);
> +		struct rpc_iostats stats =3D { 0 };
> +		struct rpc_clnt *next =3D clnt;
> +		do {
> +			_add_rpc_iostats(&stats, &next->cl_metrics[op]);
> +			if (next =3D=3D next->cl_parent)
> +				break;
> +			next =3D next->cl_parent;
> +		} while (next);
> +		_print_rpc_iostats(seq, &stats, op, clnt->cl_procinfo);
> 	}
> }
> -EXPORT_SYMBOL_GPL(rpc_print_iostats);
> +EXPORT_SYMBOL_GPL(rpc_clnt_show_stats);
>=20
> /*
>  * Register/unregister RPC proc files
> --=20
> 2.14.3
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



