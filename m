Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45935 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753601Ab1JRRnu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Oct 2011 13:43:50 -0400
Date: Tue, 18 Oct 2011 13:43:49 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] NFSD: Added fault injection
Message-ID: <20111018174349.GA23138@fieldses.org>
References: <1318009468-19893-1-git-send-email-bjschuma@netapp.com>
 <20111017221810.GG13368@fieldses.org>
 <4E9CB2CE.8080201@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E9CB2CE.8080201@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 17, 2011 at 06:57:18PM -0400, Bryan Schumaker wrote:
> On 10/17/2011 06:18 PM, J. Bruce Fields wrote:
> > On Fri, Oct 07, 2011 at 01:44:26PM -0400, bjschuma@netapp.com wrote:
> >> +#define INJECTION_OP(op_action, op_item, op_func)	\
> >> +{							\
> >> +	.action = op_action,				\
> >> +	.item   = op_item,				\
> >> +	.file   = op_action"_"op_item,			\
> >> +	.func   = op_func,				\
> >> +}
> >> +
> >> +static struct nfsd_fault_inject_op inject_ops[] = {
> >> +	INJECTION_OP("forget", "clients",     nfsd_forget_clients),
> >> +	INJECTION_OP("forget", "locks",       nfsd_forget_locks),
> >> +	INJECTION_OP("forget", "openowners",  nfsd_forget_openowners),
> >> +	INJECTION_OP("forget", "delegations", nfsd_forget_delegations),
> >> +	INJECTION_OP("recall", "delegations", nfsd_recall_delegations),
> > 
> > This is a little clever for my taste....  Could we just do
> > 
> > 	static struct nfsd_fault_inject_op inject_ops[] = {
> > 		{
> > 			.file = "forget_client",
> > 			.op = nfsd_forget_clients,
> > 		},
> > 		...
> > 	}
> > 
> > and do away with the separate item and action fields?
> > 
> > I'd rather be sort of obvious and boring even if it's slightly less
> > compact.
> > 
> I was going for compact when I initially wrote this, but I can change it.  I have them as separate fields so I can print out slightly different messages based on what is going on.  Such as:  "NFSD: Server forgetting all clients" or "NFSD: Server recalling at most 4 delegations".

Even

	{ .file = "forget_client", .op=nfsd_forget_clients },
	{ ... }

would be fine by me and still pretty compact.

And log messages are probably a good idea but I don't think they have to
be beautiful--"NFSD: recall_delegations(4)" would do fine.

--b.


> 
> >> +};
> >> +
> >> +static long int NUM_INJECT_OPS = sizeof(inject_ops) / sizeof(struct nfsd_fault_inject_op);
> >> +static struct dentry *debug_dir;
> >> +
> >> +static int nfsd_inject_set(void *data, u64 val)
> >> +{
> >> +	int i;
> >> +	struct nfsd_fault_inject_op *op;
> >> +
> >> +	for (i = 0; i < NUM_INJECT_OPS; i++) {
> >> +		op = &inject_ops[i];
> >> +		if (&op->file_data == data) {
> > 
> > Huh, OK, so if I understand right, the contents of file_data doesn't
> > matter, you're just using a pointer to that field as a way to identify
> > the op array.
> > 
> > But then couldn't you just pass in a pointer to the op itself:
> > 
> >> +	for (i = 0; i < NUM_INJECT_OPS; i++) {
> >> +		op = &inject_ops[i];
> >> +		debugfs_create_file(op->file, mode, debug_dir, &op->file_data, &fops_nfsd);
> > 
> > like:
> > 
> > 		debugfs_create_file(op->file, mode, debug_dir, op, &fops_nfsd);
> > 
> > and eliminate the file_data field?
> 
> I've never thought about trying it that way, but it seems fairly straightforward.  I'll try it that way and see if it works!
> > 
> > Patches look OK otherwise on a quick skim, thanks.
> > 
> > --b.
> > 
> > 
> >> +	}
> >> +	return 0;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
