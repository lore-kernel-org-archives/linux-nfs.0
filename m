Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:39499 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751410AbeF0AP7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jun 2018 20:15:59 -0400
Received: by mail-qt0-f195.google.com with SMTP id c23-v6so214732qtn.6
        for <linux-nfs@vger.kernel.org>; Tue, 26 Jun 2018 17:15:58 -0700 (PDT)
Message-ID: <1530058556.4210.0.camel@redhat.com>
Subject: Re: [RFC PATCH 3/3] sunrpc: Change rpc_print_iostats to
 rpc_clnt_show_stats and handle rpc_clnt clones
From: David Wysochanski <dwysocha@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Tue, 26 Jun 2018 20:15:56 -0400
In-Reply-To: <E7A8E5A1-7EC0-4DF4-9568-C16E834AFAFE@oracle.com>
References: <20180626235623.26898-1-dwysocha@redhat.com>
         <20180626235623.26898-4-dwysocha@redhat.com>
         <E7A8E5A1-7EC0-4DF4-9568-C16E834AFAFE@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2018-06-26 at 20:13 -0400, Chuck Lever wrote:
> > On Jun 26, 2018, at 7:56 PM, Dave Wysochanski <dwysocha@redhat.com> wrote:
> > 
> > The existing rpc_print_iostats has a few shortcomings.  First, the naming
> > is not consistent with other functions in the kernel that display stats.
> > Second, it is really displaying stats for an rpc_clnt structure as it
> > displays both xprt stats and per-op stats.  Third, it does not handle
> > rpc_clnt clones, which is important for the one in-kernel tree caller
> > of this function, the NFS client's nfs_show_stats function.
> > 
> > Fix all of the above by renaming the rpc_print_iostats to
> > rpc_clnt_show_stats and looping through any rpc_clnt clones via
> > cl_parent.
> > 
> > Once this interface is fixed, this addresses a problem with NFSv4.
> > Before this patch, the /proc/self/mountstats always showed incorrect
> > counts for NFSv4 state related opcodes such as SEQUENCE and RENEW.
> > These counts were always 0 even though many ops would go over the
> > wire.  The reason for this is there are multiple rpc_clnt structures
> > allocated for any given NFSv4 mount, and inside nfs_show_stats() we callled
> > into rpc_print_iostats() which only handled one of them, nfs_server->client.
> > Fix these counts by calling sunrpc's new rpc_clnt_show_stats() function,
> > which handles cloned rpc_clnt structs and prints the stats together.
> > 
> > Note that one side-effect of the above is that multiple mounts from
> > the same NFS server will show identical counts in the above ops due
> > to the fact the one rpc_clnt (representing the NFSv4 client state)
> > is shared across mounts.
> > 
> > Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> > ---
> > fs/nfs/super.c                 |  2 +-
> > include/linux/sunrpc/metrics.h |  6 +++---
> > net/sunrpc/stats.c             | 17 ++++++++++++-----
> > 3 files changed, 16 insertions(+), 9 deletions(-)
> > 
> > diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> > index 5e470e233c83..bdf39fa1bfbc 100644
> > --- a/fs/nfs/super.c
> > +++ b/fs/nfs/super.c
> > @@ -884,7 +884,7 @@ int nfs_show_stats(struct seq_file *m, struct dentry *root)
> > #endif
> > 	seq_printf(m, "\n");
> > 
> > -	rpc_print_iostats(m, nfss->client);
> > +	rpc_clnt_show_stats(m, nfss->client);
> > 
> > 	return 0;
> > }
> > diff --git a/include/linux/sunrpc/metrics.h b/include/linux/sunrpc/metrics.h
> > index 9baed7b355b2..3daa5b42d871 100644
> > --- a/include/linux/sunrpc/metrics.h
> > +++ b/include/linux/sunrpc/metrics.h
> > @@ -30,7 +30,7 @@
> > #include <linux/ktime.h>
> > #include <linux/spinlock.h>
> > 
> > -#define RPC_IOSTATS_VERS	"1.0"
> > +#define RPC_IOSTATS_VERS	"1.1"
> 
> A quick browse does not reveal a format change in /proc/self/mountstats.
> Did I miss it? If there's no change, VERS should stay "1.0".
> 

No there is not a format change, so you're right.

Thanks!

> 
> > struct rpc_iostats {
> > 	spinlock_t		om_lock;
> > @@ -82,7 +82,7 @@ void			rpc_count_iostats(const struct rpc_task *,
> > 					  struct rpc_iostats *);
> > void			rpc_count_iostats_metrics(const struct rpc_task *,
> > 					  struct rpc_iostats *);
> > -void			rpc_print_iostats(struct seq_file *, struct rpc_clnt *);
> > +void			rpc_clnt_show_stats(struct seq_file *, struct rpc_clnt *);
> > void			rpc_free_iostats(struct rpc_iostats *);
> > 
> > #else  /*  CONFIG_PROC_FS  */
> > @@ -95,7 +95,7 @@ static inline void rpc_count_iostats_metrics(const struct rpc_task *task,
> > {
> > }
> > 
> > -static inline void rpc_print_iostats(struct seq_file *seq, struct rpc_clnt *clnt) {}
> > +static inline void rpc_clnt_show_stats(struct seq_file *seq, struct rpc_clnt *clnt) {}
> > static inline void rpc_free_iostats(struct rpc_iostats *stats) {}
> > 
> > #endif  /*  CONFIG_PROC_FS  */
> > diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
> > index 32adddd7fb78..2c9453465c78 100644
> > --- a/net/sunrpc/stats.c
> > +++ b/net/sunrpc/stats.c
> > @@ -235,13 +235,12 @@ static void _print_rpc_iostats(struct seq_file *seq, struct rpc_iostats *stats,
> > 		   ktime_to_ms(stats->om_execute));
> > }
> > 
> > -void rpc_print_iostats(struct seq_file *seq, struct rpc_clnt *clnt)
> > +void rpc_clnt_show_stats(struct seq_file *seq, struct rpc_clnt *clnt)
> > {
> > -	struct rpc_iostats *stats = clnt->cl_metrics;
> > 	struct rpc_xprt *xprt;
> > 	unsigned int op, maxproc = clnt->cl_maxproc;
> > 
> > -	if (!stats)
> > +	if (!clnt->cl_metrics)
> > 		return;
> > 
> > 	seq_printf(seq, "\tRPC iostats version: %s  ", RPC_IOSTATS_VERS);
> > @@ -256,10 +255,18 @@ void rpc_print_iostats(struct seq_file *seq, struct rpc_clnt *clnt)
> > 
> > 	seq_printf(seq, "\tper-op statistics\n");
> > 	for (op = 0; op < maxproc; op++) {
> > -		_print_rpc_iostats(seq, &stats[op], op, clnt->cl_procinfo);
> > +		struct rpc_iostats stats = { 0 };
> > +		struct rpc_clnt *next = clnt;
> > +		do {
> > +			_add_rpc_iostats(&stats, &next->cl_metrics[op]);
> > +			if (next == next->cl_parent)
> > +				break;
> > +			next = next->cl_parent;
> > +		} while (next);
> > +		_print_rpc_iostats(seq, &stats, op, clnt->cl_procinfo);
> > 	}
> > }
> > -EXPORT_SYMBOL_GPL(rpc_print_iostats);
> > +EXPORT_SYMBOL_GPL(rpc_clnt_show_stats);
> > 
> > /*
> >  * Register/unregister RPC proc files
> > -- 
> > 2.14.3
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> Chuck Lever
> 
> 
> 
