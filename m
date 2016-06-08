Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:33005 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161902AbcFHKgs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jun 2016 06:36:48 -0400
Received: by mail-yw0-f194.google.com with SMTP id y6so424745ywe.0
        for <linux-nfs@vger.kernel.org>; Wed, 08 Jun 2016 03:36:47 -0700 (PDT)
Message-ID: <1465382205.27742.3.camel@poochiereds.net>
Subject: Re: [PATCH 3/3] pnfs: add a new mechanism to select a layout driver
 according to an ordered list
From: Jeff Layton <jlayton@poochiereds.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: anna.schumaker@netapp.com, trondmy@primarydata.com,
        tigran.mkrtchyan@desy.de, thomas.haynes@primarydata.com,
        linux-nfs@vger.kernel.org
Date: Wed, 08 Jun 2016 06:36:45 -0400
In-Reply-To: <20160607214622.GE6653@fieldses.org>
References: <1465295891-4952-1-git-send-email-jlayton@poochiereds.net>
 <1465295891-4952-4-git-send-email-jlayton@poochiereds.net>
	 <20160607214622.GE6653@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2016-06-07 at 17:46 -0400, J. Bruce Fields wrote:
> On Tue, Jun 07, 2016 at 06:38:11AM -0400, Jeff Layton wrote:
> > Currently, the layout driver selection code attempts to divine meaning
> > from the order of the layout driver list sent by the server.
> > Unfortunately, the spec doesn't place any significance on the order
> > and the server is free to send them in any order it likes.
> > 
> > Instead, set a list of preferred driver types in the kernel and have
> > the selection code try them in order until it finds one that can be
> > loaded.
> > 
> > If we go through the whole list of preferred drivers and don't find one,
> > then try any that weren't recognized in the first scan. This should
> > allow the use of 3rd party and experimental drivers without needing to
> > muck with the order of preference.
> > 
> > For now, the order of preference is hardcoded, but it should be possible
> > to make this configurable (via module param perhaps?).
> > 
> > Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> > ---
> >  fs/nfs/pnfs.c | 71 +++++++++++++++++++++++++++++++++++++++++------------------
> >  1 file changed, 50 insertions(+), 21 deletions(-)
> > 
> > diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> > index b02cad9c04bf..3ec5f2b392b6 100644
> > --- a/fs/nfs/pnfs.c
> > +++ b/fs/nfs/pnfs.c
> > @@ -99,6 +99,21 @@ unset_pnfs_layoutdriver(struct nfs_server *nfss)
> >  }
> >  
> >  /*
> > + * When the server sends a list of layout types, we choose one in the order
> > + * given in the list below.
> > + *
> > + * FIXME: should this list be configurable via module_param or something?
> > + */
> > +static const u32 ld_prefs[] = {
> > +	LAYOUT_SCSI,
> > +	LAYOUT_BLOCK_VOLUME,
> > +	LAYOUT_OSD2_OBJECTS,
> > +	LAYOUT_FLEX_FILES,
> > +	LAYOUT_NFSV4_1_FILES,
> > +	0
> > +};
> > +
> > +/*
> >   * Try to set the server's pnfs module to the pnfs layout type specified by id.
> >   * Currently only one pNFS layout driver per filesystem is supported.
> >   *
> > @@ -110,7 +125,7 @@ set_pnfs_layoutdriver(struct nfs_server *server, const struct nfs_fh *mntfh,
> >  {
> >  	struct pnfs_layoutdriver_type *ld_type = NULL;
> >  	u32 id;
> > -	int i;
> > +	int i, j;
> >  
> >  	if (!(server->nfs_client->cl_exchange_flags &
> >  		 (EXCHGID4_FLAG_USE_NON_PNFS | EXCHGID4_FLAG_USE_PNFS_MDS))) {
> > @@ -118,31 +133,45 @@ set_pnfs_layoutdriver(struct nfs_server *server, const struct nfs_fh *mntfh,
> >  			__func__, server->nfs_client->cl_exchange_flags);
> >  		goto out_no_driver;
> >  	}
> > -	/*
> > -	 * If server supports more than one layout types.
> > -	 * By assuming, that server will put 'common default' as the first
> > -	 * entry, try all following entries ibefore and fall back to the default
> > -	 * if we did not found a matching one.
> > -	 */
> > -	for(i = 1; i < NFS_MAX_LAYOUT_TYPES && ids[i] != 0; i++) {
> > -		id = ids[i];
> > -		request_module("%s-%u", LAYOUT_NFSV4_1_MODULE_PREFIX, id);
> > -		ld_type = find_pnfs_driver(id);
> > -		if(ld_type)
> > -			goto found_module;
> >  
> > -		dprintk("%s: No pNFS module found for %u.\n", __func__, id);
> > +	/* scan the list for each layout type in order of preference */
> > +	for (j = 0; ld_prefs[j] != 0; j++) {
> > +		for (i = 0; i < NFS_MAX_LAYOUT_TYPES && ids[i] != 0; i++) {
> > +			id = ids[i];
> > +
> > +			if (ld_prefs[j] == id) {
> > +				request_module("%s-%u", LAYOUT_NFSV4_1_MODULE_PREFIX, id);
> > +				ld_type = find_pnfs_driver(id);
> > +				if (ld_type)
> > +					goto found_module;
> > +			}
> > +		}
> >  	}
> >  
> > -	/*
> > -	 * no other layout types found. Try default one.
> > -	 */
> > -	id = ids[0];
> > -	request_module("%s-%u", LAYOUT_NFSV4_1_MODULE_PREFIX, id);
> > -	ld_type = find_pnfs_driver(id);
> > +	/* didn't find one -- make sure we try any that weren't in ld_prefs */
> > +	for (i = 0; i < NFS_MAX_LAYOUT_TYPES && ids[i] != 0; i++) {
> > +		bool	match = false;
> > +
> > +		id = ids[i];
> > +
> > +		/* Was it in the prefs list? */
> > +		for (j = 0; ld_prefs[j] != 0; j++) {
> > +			if (ld_prefs[j] != id) {
> > +				match = true;
> > +				break;
> > +			}
> > +		}
> 
> This logic feels more complicated than necessary.
> 
> We're going out of our way to support (at this point purely theoretical)
> 3rd-party layout modules.  When new layouts are develop, the chance
> they'll be implementable with *no* changes to kernel code outside that
> module seem small, and once you have to touch other code you may as well
> update ld_prefs.
> 
> But anyway, if we want this, it might be easier to follow with logic
> like:
> 
> 	1. sort the ids[] array so the known layouts are at the top, in
> 	   ld_prefs order.
> 	2. try request_module() and find_pnfs_driver() in order on
> 	   the sorted ids[] array.
> 
> --b.
> 

That's possible, but I'm not sure that will really make the code any
less complicated. I'll see what I can come up with.

> > +
> > +		if (!match) {
> > +			request_module("%s-%u", LAYOUT_NFSV4_1_MODULE_PREFIX, id);
> > +			ld_type = find_pnfs_driver(id);
> > +			if (ld_type)
> > +				goto found_module;
> > +		}
> > +	}
> >  
> >  	if (!ld_type) {
> > -		dprintk("%s: No pNFS module found for %u.\n", __func__, id);
> > +		dprintk("%s: No pNFS module found!\n", __func__);
> >  		goto out_no_driver;
> >  	}
> >  
> > -- 
> > 2.5.5
-- 
Jeff Layton <jlayton@poochiereds.net>
