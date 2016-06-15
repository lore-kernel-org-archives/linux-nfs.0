Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:57760 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932121AbcFOPSu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jun 2016 11:18:50 -0400
Date: Wed, 15 Jun 2016 11:18:48 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: anna.schumaker@netapp.com, trondmy@primarydata.com,
        tigran.mkrtchyan@desy.de, thomas.haynes@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 3/3] pnfs: add a new mechanism to select a layout
 driver according to an ordered list
Message-ID: <20160615151848.GA2303@fieldses.org>
References: <1465474865-15285-1-git-send-email-jlayton@poochiereds.net>
 <1465474865-15285-4-git-send-email-jlayton@poochiereds.net>
 <20160613200525.GD19825@fieldses.org>
 <1465868807.12825.7.camel@poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1465868807.12825.7.camel@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 13, 2016 at 09:46:47PM -0400, Jeff Layton wrote:
> On Mon, 2016-06-13 at 16:05 -0400, J. Bruce Fields wrote:
> > On Thu, Jun 09, 2016 at 08:21:05AM -0400, Jeff Layton wrote:
> > > Currently, the layout driver selection code always chooses the first one
> > > from the list. That's not really ideal however, as the server can send
> > > the list of layout types in any order that it likes. It's up to the
> > > client to select the best one for its needs.
> > > 
> > > This patch adds an ordered list of preferred driver types and has the
> > > selection code sort the list of avaiable layout drivers according to it.
> > > Any unrecognized layout type is sorted to the end of the list.
> > > 
> > > For now, the order of preference is hardcoded, but it should be possible
> > > to make this configurable in the future.
> > > 
> > > Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> > > ---
> > >  fs/nfs/pnfs.c | 57 ++++++++++++++++++++++++++++++++++++++++++++++++++-------
> > >  1 file changed, 50 insertions(+), 7 deletions(-)
> > > 
> > > diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> > > index 2fc1b9354345..c31d30f1e5f2 100644
> > > --- a/fs/nfs/pnfs.c
> > > +++ b/fs/nfs/pnfs.c
> > > @@ -99,6 +99,21 @@ unset_pnfs_layoutdriver(struct nfs_server *nfss)
> > >  }
> > >  
> > >  /*
> > > + * When the server sends a list of layout types, we choose one in the order
> > > + * given in the list below.
> > > + *
> > > + * FIXME: should this list be configurable via module_param or mount option?
> > > + */
> > > +static const u32 ld_prefs[] = {
> > > +	LAYOUT_SCSI,
> > > +	LAYOUT_BLOCK_VOLUME,
> > > +	LAYOUT_OSD2_OBJECTS,
> > > +	LAYOUT_FLEX_FILES,
> > > +	LAYOUT_NFSV4_1_FILES,
> > > +	0
> > > +};
> > > +
> > > +/*
> > >   * Try to set the server's pnfs module to the pnfs layout type specified by id.
> > >   * Currently only one pNFS layout driver per filesystem is supported.
> > >   *
> > > @@ -110,6 +125,8 @@ set_pnfs_layoutdriver(struct nfs_server *server, const struct nfs_fh *mntfh,
> > >  {
> > >  	struct pnfs_layoutdriver_type *ld_type = NULL;
> > >  	u32 id;
> > > +	int i, j;
> > > +	bool swapped;
> > >  
> > >  	if (!(server->nfs_client->cl_exchange_flags &
> > >  		 (EXCHGID4_FLAG_USE_NON_PNFS | EXCHGID4_FLAG_USE_PNFS_MDS))) {
> > > @@ -118,18 +135,44 @@ set_pnfs_layoutdriver(struct nfs_server *server, const struct nfs_fh *mntfh,
> > >  		goto out_no_driver;
> > >  	}
> > >  
> > > -	id = ids[0];
> > > -	if (!id)
> > > -		goto out_no_driver;
> > > +	/* bubble sort into ld_prefs order */
> > > +	do {
> > > +		swapped = false;
> > > +		for (i = 0; i < (NFS_MAX_LAYOUT_TYPES - 1); i++) {
> > >  
> > > -	ld_type = find_pnfs_driver(id);
> > > -	if (!ld_type) {
> > > -		request_module("%s-%u", LAYOUT_NFSV4_1_MODULE_PREFIX, id);
> > > +			/* If either is zero then we're done with this pass */
> > > +			if (ids[i] == 0 || ids[i + 1] == 0)
> > > +				break;
> > > +
> > > +			for (j = 0; ld_prefs[j] != 0; j++) {
> > > +				/* If we match left entry first, no swap */
> > > +				if (ids[i] == ld_prefs[j])
> > > +					break;
> > > +
> > > +				/* if we match the right, we need to swap */
> > > +				if (ids[i + 1] == ld_prefs[j]) {
> > > +					swap(ids[i], ids[i + 1]);
> > > +					swapped = true;
> > > +					break;
> > > +				}
> > > +			}
> > > +		}
> > > +	} while (swapped);
> > 
> > Maybe I'm strange, but, yes, to me this is easier to read as on a first
> > pass I can just take your word that the above is doing a sort and see
> > much more quickly what's happening....
> > 
> 
> Yeah, it is for me too, actually. Good call on asking for it. ;)
> 
> That said, I did notice the code in lib/sort.c after I sent this
> series. It might be better to use that instead of this hand-rolled
> bubble sort (if only for conciseness -- I doubt it matters for
> efficiency).

Makes sense.  I'll expect a resend of these some day either way, then
I'll probably take the nfsd part if there's no objections....

--b.
