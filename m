Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:41330 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752436AbaAXSyh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Jan 2014 13:54:37 -0500
Date: Fri, 24 Jan 2014 13:54:34 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Weston Andros Adamson <dros@netapp.com>,
        linuxnfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] nfs: don't attempt auth methods that require upcall
 unless we know that gssd is running
Message-ID: <20140124135434.5286c7b8@tlielax.poochiereds.net>
In-Reply-To: <3A1E80DF-2F73-4A74-AE2C-E121DC7BEAD2@primarydata.com>
References: <1390567564-19241-1-git-send-email-jlayton@redhat.com>
	<3A1E80DF-2F73-4A74-AE2C-E121DC7BEAD2@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 24 Jan 2014 10:02:38 -0700
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> 
> On Jan 24, 2014, at 5:46, Jeff Layton <jlayton@redhat.com> wrote:
> 
> > Currently, if the server lists krb5 as an allowed auth method, but gssd isn't
> > running, you'll get the infamous "AUTH_GSS upcall failed" message, even if
> > you didn't request sec=krb5.
> > 
> > This is because nfs4_find_root_sec() establishes a default list of auth
> > methods to try when the admin didn't supply one, and that list contains
> > AUTH_GSS methods first. Skip those methods if gssd isn't running since
> > they won't succeed anyway.
> > 
> > Cc: Weston Andros Adamson <dros@netapp.com>
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> > fs/nfs/nfs4proc.c | 8 ++++++++
> > 1 file changed, 8 insertions(+)
> > 
> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > index 15052b8..937a05a 100644
> > --- a/fs/nfs/nfs4proc.c
> > +++ b/fs/nfs/nfs4proc.c
> > @@ -2900,6 +2900,14 @@ static int nfs4_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
> > 	} else {
> > 		/* no flavors specified by user, try default list */
> > 		for (i = 0; i < ARRAY_SIZE(flav_array); i++) {
> > +			/*
> > +			 * Don't attempt to upcall with the default list
> > +			 * unless we know that gssd is running.
> > +			 */
> > +			if (flav_array[i] > RPC_AUTH_MAXFLAVOR &&
> > +			    !gssd_running(server->nfs_client->cl_net))
> > +				continue;
> 
> Big effing NACK.
> 
> This is exactly the kind of layering violation creep whereby the NFS layer ends up tracking more and more of the implementation details in the RPC authentication which made me hesitant about allowing gssd_running to be exported in the first place.
> 

I'm not happy with the layering violations either. In this case the
problem is not serious -- just a spurious error message, but these sorts
of error messages tend to drive admins mad and cause them to call their
support vendors. Having to run gssd just to get rid of an error message
seems rather lame.

I guess the only semi-clean way to clean up the layering violation is
to somehow pass a "user intent" flag down to the lower layers. Then if
gssd isn't running, we'd just suppress the warning message. That's an
awful lot of code churn though, since the place where the log messages
occur is currently a long way away from the place where we actually
know what the intent was.

-- 
Jeff Layton <jlayton@redhat.com>
