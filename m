Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6465 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754779Ab2BCTWT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Feb 2012 14:22:19 -0500
Date: Fri, 3 Feb 2012 14:22:12 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v5 1/5] nfsd: add nfsd4_client_tracking_ops struct and a
 way to set it
Message-ID: <20120203142212.075bf1dd@tlielax.poochiereds.net>
In-Reply-To: <20120202224541.GA28291@fieldses.org>
References: <1328111052-28389-1-git-send-email-jlayton@redhat.com>
	<1328111052-28389-2-git-send-email-jlayton@redhat.com>
	<20120202224541.GA28291@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2 Feb 2012 17:45:41 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> Just nits:
> 
> On Wed, Feb 01, 2012 at 10:44:08AM -0500, Jeff Layton wrote:
> > +static struct nfsd4_client_tracking_ops nfsd4_legacy_tracking_ops = {
> > +	.init		= nfsd4_load_reboot_recovery_data,
> > +	.exit		= nfsd4_shutdown_recdir,
> > +	.create		= nfsd4_create_clid_dir,
> > +	.remove		= nfsd4_remove_clid_dir,
> > +	.check		= nfsd4_check_legacy_client,
> > +	.grace_done	= nfsd4_recdir_purge_old,
> > +};
> > +
> > +int
> > +nfsd4_client_tracking_init(void)
> > +{
> > +	int status;
> > +
> > +	client_tracking_ops = &nfsd4_legacy_tracking_ops;
> > +
> > +	if (!client_tracking_ops->init)
> > +		return 0;
> 
> Is that check necessary?
> 

No, see below...

> > +
> > +	status = client_tracking_ops->init();
> > +	if (status) {
> > +		printk(KERN_WARNING "NFSD: Unable to initialize client "
> > +				    "recovery tracking! (%d)\n", status);
> > +		client_tracking_ops = NULL;
> > +	}
> > +	return status;
> > +}
> > +
> > +void
> > +nfsd4_client_tracking_exit(void)
> > +{
> > +	if (client_tracking_ops && client_tracking_ops->exit)
> 
> In general I don't see the point of handling the case where one of the
> ops is NULL.  If there was some implementation that really wanted that
> we could get the same effect by defining a default no-op implementation
> they could use, but I don't think there actually is?
> 

In an earlier iteration of this patchset, some of these fields were
NULL pointers, but in the current version they're all populated. I
can remove those checks if you'd prefer.

> > +int
> > +nfsd4_client_record_check(struct nfs4_client *clp)
> > +{
> > +	if (client_tracking_ops && client_tracking_ops->check)
> > +		return client_tracking_ops->check(clp);
> > +
> > +	return -EOPNOTSUPP;
> > +}
> > +
> > +void
> > +nfsd4_grace_done(time_t boot_time)
> 
> That name's a bit generic--but I don't have a better suggestion.
> (nfsd4_record_grace_done()?)
> 

Ok, that sounds reasonable. I'll rename it when I respin this patch in
the next week or so.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
