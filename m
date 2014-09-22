Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:53545 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752274AbaIVBhT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 21 Sep 2014 21:37:19 -0400
Date: Mon, 22 Sep 2014 11:37:07 +1000
From: NeilBrown <neilb@suse.de>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/4] NFS: avoid deadlocks with loop-back mounted NFS
 filesystems.
Message-ID: <20140922113707.3d0cfc8e@notabene.brown>
In-Reply-To: <20140918080107.77bb52c5@tlielax.poochiereds.net>
References: <20140918055907.23854.32118.stgit@notabene.brown>
	<20140918060317.23854.40603.stgit@notabene.brown>
	<20140918080107.77bb52c5@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/6hCXUT6h1yoFthp32fBk+Ma"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/6hCXUT6h1yoFthp32fBk+Ma
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 18 Sep 2014 08:01:07 -0400 Jeff Layton <jeff.layton@primarydata.com>
wrote:

> On Thu, 18 Sep 2014 16:03:17 +1000
> NeilBrown <neilb@suse.de> wrote:
>=20
> > Support for loop-back mounted NFS filesystems is useful when NFS is
> > used to access shared storage in a high-availability cluster.
> >=20
> > If the node running the NFS server fails, some other node can mount the
> > filesystem and start providing NFS service.  If that node already had
> > the filesystem NFS mounted, it will now have it loop-back mounted.
> >=20
> > nfsd can suffer a deadlock when allocating memory and entering direct
> > reclaim.
> > While direct reclaim does not write to the NFS filesystem it can send
> > and wait for a COMMIT through nfs_release_page().
> >=20
> > This patch modifies nfs_release_page() to wait a limited time for the
> > commit to complete - one second.  If the commit doesn't complete
> > in this time, nfs_release_page() will fail.  This means it might now
> > fail in some cases where it wouldn't before.  These cases are only
> > when 'gfp' includes '__GFP_WAIT'.
> >=20
> > nfs_release_page() is only called by try_to_release_page(), and that
> > can only be called on an NFS page with required 'gfp' flags from
> >  - page_cache_pipe_buf_steal() in splice.c
> >  - shrink_page_list() in vmscan.c
> >  - invalidate_inode_pages2_range() in truncate.c
> >=20
> > The first two handle failure quite safely.  The last is only called
> > after ->launder_page() has been called, and that will have waited
> > for the commit to finish already.
> >=20
> > So aborting if the commit takes longer than 1 second is perfectly safe.
> >=20
> > If nfs_release_page() is called on a sequence of pages which are all
> > in the same file which is blocked on COMMIT, each page could
> > contribute a 1 second delay which could be come excessive.  I have
> > seen delays of as much as 208 seconds.
> >=20
> > To keep the delay to one second, the bdi is marked as write-congested
> > if the commit didn't finished.  Once it does finish, the
> > write-congested flag will be cleared.
> >=20
> > With this, the longest total delay in try_to_free_pages that I have
> > seen in under 3 seconds.  With no waiting in nfs_release_page at all
> > I have seen delays of nearly 1.5 seconds.
> >=20
> > Signed-off-by: NeilBrown <neilb@suse.de>
> > ---
> >  fs/nfs/file.c  |   30 ++++++++++++++++++++----------
> >  fs/nfs/write.c |    7 +++++++
> >  2 files changed, 27 insertions(+), 10 deletions(-)
> >=20
> > diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> > index 524dd80d1898..febba950d8a6 100644
> > --- a/fs/nfs/file.c
> > +++ b/fs/nfs/file.c
> > @@ -468,17 +468,27 @@ static int nfs_release_page(struct page *page, gf=
p_t gfp)
> > =20
> >  	dfprintk(PAGECACHE, "NFS: release_page(%p)\n", page);
> > =20
> > -	/* Only do I/O if gfp is a superset of GFP_KERNEL, and we're not
> > -	 * doing this memory reclaim for a fs-related allocation.
> > +	/* Always try to initiate a 'commit' if relevant, but only
> > +	 * wait for it if __GFP_WAIT is set and the calling process is
> > +	 * allowed to block.  Even then, only wait 1 second and only
> > +	 * if the 'bdi' is not congested.
> > +	 * Waiting indefinitely can cause deadlocks when the NFS
> > +	 * server is on this machine, and there is no particular need
> > +	 * to wait extensively here.  A short wait has the benefit
> > +	 * that someone else can worry about the freezer.
> >  	 */
> > -	if (mapping && (gfp & GFP_KERNEL) =3D=3D GFP_KERNEL &&
> > -	    !(current->flags & PF_FSTRANS)) {
> > -		int how =3D FLUSH_SYNC;
> > -
> > -		/* Don't let kswapd deadlock waiting for OOM RPC calls */
> > -		if (current_is_kswapd())
> > -			how =3D 0;
> > -		nfs_commit_inode(mapping->host, how);
> > +	if (mapping) {
> > +		struct nfs_server *nfss =3D NFS_SERVER(mapping->host);
> > +		nfs_commit_inode(mapping->host, 0);
> > +		if ((gfp & __GFP_WAIT) &&
> > +		    !current_is_kswapd() &&
> > +		    !(current->flags & PF_FSTRANS) &&
> > +		    !bdi_write_congested(&nfss->backing_dev_info))
> > +			wait_on_page_bit_killable_timeout(page, PG_private,
> > +							  HZ);
> > +		if (PagePrivate(page))
> > +			set_bdi_congested(&nfss->backing_dev_info,
> > +					  BLK_RW_ASYNC);
>=20
> I've never had a great feel for the BDI congestion stuff, but won't
> this have some unintended effects?
>=20
> For instance, suppose the VM decides to try to free this page and
> passes in a gfp mask that doesn't contain __GFP_WAIT. We issue the
> COMMIT, but don't wait for it. The COMMIT is actually going to go
> reasonably fast, but we now set the BDI congested because we didn't
> wait for it to occur.
>=20
> That in turn causes writeout for other inodes on this BDI to get
> throttled even though there really is no congestion. It just looks that
> way due to how releasepage got called.
>=20
> Am I making mountains out of molehills here?

Excellent molehill - thanks :-)

I was being lazy.  The 'if (PagePrivate())' should really be inside the
other if statement with the wait_on_page_bit...().  I've moved it there.
Once I get an Ack for the mm bits I'll report it all.

Thanks,
NeilBrown

(Molehills are worse for your suspension than mountains!)


>=20
> >  	}
> >  	/* If PagePrivate() is set, then the page is not freeable */
> >  	if (PagePrivate(page))
> > diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> > index 175d5d073ccf..3066c7fcb565 100644
> > --- a/fs/nfs/write.c
> > +++ b/fs/nfs/write.c
> > @@ -731,6 +731,8 @@ static void nfs_inode_remove_request(struct nfs_pag=
e *req)
> >  		if (likely(!PageSwapCache(head->wb_page))) {
> >  			set_page_private(head->wb_page, 0);
> >  			ClearPagePrivate(head->wb_page);
> > +			smp_mb__after_atomic();
> > +			wake_up_page(head->wb_page, PG_private);
> >  			clear_bit(PG_MAPPED, &head->wb_flags);
> >  		}
> >  		nfsi->npages--;
> > @@ -1636,6 +1638,7 @@ static void nfs_commit_release_pages(struct nfs_c=
ommit_data *data)
> >  	struct nfs_page	*req;
> >  	int status =3D data->task.tk_status;
> >  	struct nfs_commit_info cinfo;
> > +	struct nfs_server *nfss;
> > =20
> >  	while (!list_empty(&data->pages)) {
> >  		req =3D nfs_list_entry(data->pages.next);
> > @@ -1669,6 +1672,10 @@ static void nfs_commit_release_pages(struct nfs_=
commit_data *data)
> >  	next:
> >  		nfs_unlock_and_release_request(req);
> >  	}
> > +	nfss =3D NFS_SERVER(data->inode);
> > +	if (atomic_long_read(&nfss->writeback) < NFS_CONGESTION_OFF_THRESH)
> > +		clear_bdi_congested(&nfss->backing_dev_info, BLK_RW_ASYNC);
> > +
> >  	nfs_init_cinfo(&cinfo, data->inode, data->dreq);
> >  	if (atomic_dec_and_test(&cinfo.mds->rpcs_out))
> >  		nfs_commit_clear_lock(NFS_I(data->inode));
> >=20
> >=20
>=20
>=20


--Sig_/6hCXUT6h1yoFthp32fBk+Ma
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBVB99Qznsnt1WYoG5AQJlfxAAsTxNHXl4GHlXQw0qSRwqnPu6OY456INo
B/yoQCkOqVk/Za6tdO9DWzczaR+ux9/m4HtdvB5r12Baiw0YlD6+7y7Ue9OL8yvD
zs47kt5/MqU6AfaSt03utj1XSXUanHCZK9r3J14QO0+QL6WpI27haPdoS4ABhSFC
0vzI78R6dD8GRY8TikZQeJphNevNwEqzQzCAxV4NYMEaaKf/2uMZ0tzI+8GV3tld
hE5WOrpzxTEnNrAvuIYxGeNPQtpKLP4AMusHrpxsR9YE98BA+93ryyh4d3VjXdVu
oDUvhZXDRrwE/Y1l1ROj4KZdRAn8FZTy6eC3OsMKUeiD870oOwQ+UPsFFJz5AzXD
92BMFaud/vsy+XyLijPQdHKzxUEQpRrqZsQIuAfrtgMm3O1WCwFzcJZtGhoFkNZN
n4RfTfRvez4gUww97QU+nNAbfMbDxzIivmsmGyFcKo3gU4lrm0EoZ8fThjR8YFV1
BkicIBpL5+12wmJd1XsR4i9QbigB1Tm1wsgPPPzzOQhQLjb/XS+e62z+Rbd/iuuI
H9lsO/ST2dxCwnjENiRg9WZOAkY0EZk7zfGhWTW/QVFTUSYtqYfaAIIBEMZ5Il8F
g1iDR4kQ2pPJmLrYfiZXdbBOL6KXrI2V3d9X3+scBogktLhGkdjS4domB9kKOBeC
B3Soe6TocPI=
=hnI2
-----END PGP SIGNATURE-----

--Sig_/6hCXUT6h1yoFthp32fBk+Ma--
