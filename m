From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [PATCH] nfsd: use nfs client rpc callback program
Date: Thu, 18 Sep 2008 16:36:11 -0500
Message-ID: <48D2C9CB.6040306@panasas.com>
References: <48D15DF0.4000406@panasas.com>	<20080917231018.GA5723@fieldses.org>	<48D193EE.2020805@panasas.com>	<48D19C74.8000303@panasas.com> <48D2AAF7.6060808@panasas.com>	<48D2AF61.7030500@redhat.com> <48D2B4A6.9000207@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs mailing list <pnfs@linux-nfs.org>,
	Olga Kornievskaia <aglo@citi.umich.edu>
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:10668 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754235AbYIRVfi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Sep 2008 17:35:38 -0400
In-Reply-To: <48D2B4A6.9000207@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep. 18, 2008, 15:05 -0500, Benny Halevy <bhalevy@panasas.com> wrote:
> On Sep. 18, 2008, 14:43 -0500, Peter Staubach <staubach@redhat.com> wrote:
> [snip]
>>> +	cb_program = kzalloc(sizeof(struct rpc_program) +
>>> +			     sizeof(struct rpc_stat), GFP_KERNEL);
>>>   
>> Ugg.  What about defining a struct which contains an rpc_program
>> followed by an rpc_stat and then allocate and free that?  This
>> seems a little, unclean, to me.
>>
>>        ps
>>
> 
> Sure. No problem.
> Thanks for reviewing this.
> 
> Benny

Here's the diff from the patch I sent.
I'll send the modified patch once I get Bruce's Ack
and possibly other comments.
Tested here in the Austin BAT.

Benny

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 6599b1e..0f13d75 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -342,10 +342,19 @@ static struct rpc_version *	nfs_cb_version[] = {
 	&nfs_cb_version4,
 };
 
-static void free_rpc_program(struct rpc_program *cb_program)
+/* used internally for dynamically allocating the callback rpc_program
+ * and rpc_stat */
+struct __rpc_prog_stats {
+	struct rpc_program	program;
+	struct rpc_stat		stats;
+};
+
+static void free_rpc_program(struct rpc_program *p)
 {
-	dprintk("%s: freeing callback program 0x%p\n", __func__, cb_program);
-	kfree(cb_program);
+	struct __rpc_prog_stats *ps = container_of(p, struct __rpc_prog_stats,
+						   program);
+	dprintk("%s: freeing callback prog_stats 0x%p\n", __func__, ps);
+	kfree(ps);
 }
 
 /* Reference counting, callback cleanup, etc., all look racy as heck.
@@ -362,8 +371,7 @@ static int do_probe_callback(void *data)
 		.to_maxval	= (NFSD_LEASE_TIME/2) * HZ,
 		.to_exponential	= 1,
 	};
-	struct rpc_stat		*cb_stats;
-	struct rpc_program	*cb_program;
+	struct __rpc_prog_stats	*cb_prog_stats;
 	struct rpc_create_args args = {
 		.protocol	= IPPROTO_TCP,
 		.address	= (struct sockaddr *)&addr,
@@ -387,30 +395,28 @@ static int do_probe_callback(void *data)
 	addr.sin_addr.s_addr = htonl(cb->cb_addr);
 
 	/* Initialize rpc_program */
-	cb_program = kzalloc(sizeof(struct rpc_program) +
-			     sizeof(struct rpc_stat), GFP_KERNEL);
-	if (!cb_program) {
+	cb_prog_stats = kzalloc(sizeof(*cb_prog_stats), GFP_KERNEL);
+	if (!cb_prog_stats) {
 		dprintk("NFSD: %s: couldn't allocate callback program\n",
 			__func__);
 		status = -ENOMEM;
 		goto out_err;
 	}
 
-	cb_program->name = "nfs4_cb";
-	cb_program->number = clp->cl_callback.cb_prog;
-	cb_program->nrvers = ARRAY_SIZE(nfs_cb_version);
-	cb_program->version = nfs_cb_version;
-	cb_program->free_rpc_program = free_rpc_program;
-	args.program = cb_program;
+	args.program = &cb_prog_stats->program;
+	args.program->name = "nfs4_cb";
+	args.program->number = clp->cl_callback.cb_prog;
+	args.program->nrvers = ARRAY_SIZE(nfs_cb_version);
+	args.program->version = nfs_cb_version;
+	args.program->free_rpc_program = free_rpc_program;
 
 	dprintk("%s: program %s 0x%x nrvers %u version %u\n",
 		__func__, args.program->name, args.program->number,
 		args.program->nrvers, args.version);
 
 	/* Initialize rpc_stat */
-	cb_stats = (struct rpc_stat *)(cb_program + 1);
-	cb_stats->program = cb_program;
-	cb_program->stats = cb_stats;
+	args.program->stats = &cb_prog_stats->stats;
+	args.program->stats->program = args.program;
 
 	/* Create RPC client */
 	client = rpc_create(&args);
