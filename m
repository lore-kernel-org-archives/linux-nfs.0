From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Tue, 8 Jan 2008 17:02:20 +0000
Message-ID: <20080108170220.GA21401@infradead.org>
References: <4781BB0D.90706@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:43595 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754247AbYAHRCV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jan 2008 12:02:21 -0500
In-Reply-To: <4781BB0D.90706@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 07, 2008 at 12:39:25AM -0500, Wendy Cheng wrote:
> +#define DEBUG 0
> +#define fo_printk(x...) ((void)(DEBUG && printk(x)))

Please don't introduce more debugging helpers but use the existing
ones.

> +extern __u32 in_aton(const char *str);

This is properly declared in <linux/inet.h>

> +	return (nfsd_fo_cmd(where, fo_path, 0));

no braces around the return values please.  (happens multiple times)

> +int
> +nfsd_fo_cmd(int cmd, char *datap, int grace_period)
> +{
> +	struct nameidata nd;
> +	void *objp = (void *)datap;
> +	int rc=0;
> +
> +	if (cmd == NFSD_FO_PATH) { 
> +		rc = path_lookup((const char *)datap, 0, &nd);
> +		if (rc) {
> +			fo_printk("nfsd: nfsd_fo path (%s) not found\n", datap);
> +			return rc;
> +		}
> +		fo_printk("nfsd: nfsd_fo lookup path = (0x%p,0x%p)\n", 
> +			nd.mnt, nd.dentry);
> +		objp = (void *) &nd;
> +	} 
> +	return (nlmsvc_fo_cmd(cmd, objp, grace_period));

this has nothing in common for the two cases except for the final
function call.  Please just inline this function into the caller which
gives you quite a bit of nice cleanup by not passing all the parameters
in odd ways aswell.

And btw, I think this code has quite a bit too much debug printks,
almost more than code.  I'd be better readable by reducing that.

> +static inline int
> +nlmsvc_fo_unlock_match(void *datap, struct nlm_file *file)
> +{
> +	nlm_fo_cmd *fo_cmd = (nlm_fo_cmd *) datap;
> +	int cmd = fo_cmd->cmd;
> +	struct path *f_path;
> +
> +	fo_printk("nlm_fo_unlock_match cmd=%d\n", cmd);
> +
> +	if (cmd == NFSD_FO_VIP) {

Please split this into two separate functions for the NFSD_FO_VIP/
NFSD_FO_PATH cases as there's just about nothing in common for the two.

>  {
> +	/* Cluster failover has timing constraints. There is a slight
> +	 * performance hit if nlm_fo_unlock_match() is implemented as 
> +	 * a match fn (since it will be invoked for each block, share,
> +	 * and lock later when the lists are traversed). Instead, we 
> +	 * add path-matching logic into the following unlikely clause. 
> +	 * If matches, the dummy nlmsvc_fo_match will always return 
> +	 * true. 
> +	 */
> +	dprintk("nlm_inspect_files: file=%p\n", file);
> +	if (unlikely(match == nlmsvc_fo_match)) {
> +		if (!nlmsvc_fo_unlock_match((void *)host, file))
> +			return 0;
> +		fo_printk("nlm_fo find lock file entry (0x%p)\n", file);
> +	}

That's a quite nast hack.  Did you benchmark the the match fn variant
to see if there is actually any mesurable difference?  Also no need
to downcast pointers to void *, it's implicit in C.

> +	/* "if" place holder for NFSD_FO_RESUME */
> +	{

no need for such placeholders.

> +/* cluster failover support */
> +
> +typedef struct {
> +	int     cmd;
> +	int     stat;
> +	int     gp;
> +	void    *datap;
> +} nlm_fo_cmd;

please don't introduce typedefs for struct types.

