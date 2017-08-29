Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:51969 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751211AbdH2BX7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 28 Aug 2017 21:23:59 -0400
From: NeilBrown <neilb@suse.com>
To: Jeff Layton <jlayton@redhat.com>, Jeff Layton <jlayton@kernel.org>,
        trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Date: Tue, 29 Aug 2017 11:23:45 +1000
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] nfs: track writeback errors with errseq_t
In-Reply-To: <1503920855.4563.12.camel@redhat.com>
References: <20170720194227.7830-1-jlayton@kernel.org> <1503683981.22608.0.camel@redhat.com> <87h8wsiog4.fsf@notabene.neil.brown.name> <1503920855.4563.12.camel@redhat.com>
Message-ID: <87pobfgo9q.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 28 2017, Jeff Layton wrote:

> On Mon, 2017-08-28 at 09:24 +1000, NeilBrown wrote:
>> On Fri, Aug 25 2017, Jeff Layton wrote:
>>=20
>> > On Thu, 2017-07-20 at 15:42 -0400, Jeff Layton wrote:
>> > > From: Jeff Layton <jlayton@redhat.com>
>> > >=20
>> > > There is some ambiguity in nfs about how writeback errors are
>> > > tracked.
>> > >=20
>> > > For instance, nfs_pageio_add_request calls mapping_set_error when
>> > > the
>> > > add fails, but we track errors that occur after adding the
>> > > request
>> > > with a dedicated int error in the open context.
>> > >=20
>> > > Now that we have better infrastructure for the vfs layer, this
>> > > latter int is now unnecessary. Just have
>> > > nfs_context_set_write_error set
>> > > the error in the mapping when one occurs.
>> > >=20
>> > > Have NFS use file_write_and_wait_range to initiate and wait on
>> > > writeback
>> > > of the data, and then check again after issuing the commit(s).
>> > >=20
>> > > With this, we also don't need to pay attention to the ERROR_WRITE
>> > > flag for reporting, and just clear it to indicate to subsequent
>> > > writers that they should try to go asynchronous again.
>> > >=20
>> > > In nfs_page_async_flush, sample the error before locking and
>> > > joining
>> > > the requests, and check for errors since that point.
>> > >=20
>> > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
>> > > ---
>> > >  fs/nfs/file.c          | 24 +++++++++++-------------
>> > >  fs/nfs/inode.c         |  3 +--
>> > >  fs/nfs/write.c         |  8 ++++++--
>> > >  include/linux/nfs_fs.h |  1 -
>> > >  4 files changed, 18 insertions(+), 18 deletions(-)
>> > >=20
>> > > I have a baling wire and duct tape solution for testing this with
>> > > xfstests (using iptables REJECT targets and soft mounts). This
>> > > seems to
>> > > make nfs do the right thing.
>> > >=20
>> > > diff --git a/fs/nfs/file.c b/fs/nfs/file.c
>> > > index 5713eb32a45e..15d3c6faafd3 100644
>> > > --- a/fs/nfs/file.c
>> > > +++ b/fs/nfs/file.c
>> > > @@ -212,25 +212,23 @@ nfs_file_fsync_commit(struct file *file,
>> > > loff_t start, loff_t end, int datasync)
>> > >  {
>> > >  	struct nfs_open_context *ctx =3D
>> > > nfs_file_open_context(file);
>> > >  	struct inode *inode =3D file_inode(file);
>> > > -	int have_error, do_resend, status;
>> > > -	int ret =3D 0;
>> > > +	int do_resend, status;
>> > > +	int ret;
>> > >=20=20
>> > >  	dprintk("NFS: fsync file(%pD2) datasync %d\n", file,
>> > > datasync);
>> > >=20=20
>> > >  	nfs_inc_stats(inode, NFSIOS_VFSFSYNC);
>> > >  	do_resend =3D
>> > > test_and_clear_bit(NFS_CONTEXT_RESEND_WRITES, &ctx->flags);
>> > > -	have_error =3D test_and_clear_bit(NFS_CONTEXT_ERROR_WRITE,
>> > > &ctx->flags);
>> > > -	status =3D nfs_commit_inode(inode, FLUSH_SYNC);
>> > > -	have_error |=3D test_bit(NFS_CONTEXT_ERROR_WRITE, &ctx-
>> > > >flags);
>> > > -	if (have_error) {
>> > > -		ret =3D xchg(&ctx->error, 0);
>> > > -		if (ret)
>> > > -			goto out;
>> > > -	}
>> > > -	if (status < 0) {
>> > > +	clear_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
>> > > +	ret =3D nfs_commit_inode(inode, FLUSH_SYNC);
>> > > +
>> > > +	/* Recheck and advance after the commit */
>> > > +	status =3D file_check_and_advance_wb_err(file);
>>=20
>> This change makes the code inconsistent with the comment above the
>> function, which still references ctx->error.  The intent of the
>> comment
>> is still correct, but the details have changed.
>>=20
>
> Good catch. I'll fix that up in a respin.
>
>> Also, there is a call to mapping_set_error() in
>> nfs_pageio_add_request().
>> I wonder if that should be changed to
>>   nfs_context_set_write_error(req->wb_context, desc->pg_error)
>> ??
>>=20
>
> Trickier question...
>
> I'm not quite sure what semantics we're looking for with
> NFS_CONTEXT_ERROR_WRITE. I know that it forces writes to be
> synchronous, but I'm not quite sure why it gets cleared the way it
> does. It's set on any error but cleared before issuing a commit.
>
> I added a similar flag to Ceph inodes recently, but only clear it when
> a write succeeds. Wouldn't that make more sense here as well?

It is a bit hard to wrap one's mind around.

In the original code (commit 7b159fc18d417980) it looks like:
 - test-and-clear bit
 - write and sync
 - test-bit

This does, I think, seem safer than "clear on successful write" as the
writes could complete out-of-order and I wouldn't be surprised if the
unsuccessful ones completed with an error before the successful one -
particularly with an error like EDQUOT.

However the current code does the writes before the test-and-clear, and
only does the commit afterwards.  That makes it less clear why the
current sequence is a good idea.

However ... nfs_file_fsync_commit() is only called if
filemap_write_and_wait_range() returned with success, so we only clear
the flag after successful writes(?).

Oh....
This patch from me:

Commit: 2edb6bc3852c ("NFS - fix recent breakage to NFS error handling.")

seems to have been reverted by

Commit: 7b281ee02655 ("NFS: fsync() must exit with an error if page writeba=
ck failed")

which probably isn't good.  It appears that this code is very fragile
and easily broken.
Maybe we need to work out exactly what is required, and document it - so
we can stop breaking it.
Or maybe we need some unit tests.....

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmkwiMACgkQOeye3VZi
gbkjzA//Xu3Wr8fBVNxJylk19+yM6qxhypBQC2R65WLnTrxJOMU5kZj4tRTSG3eA
N8wPq7ExJh16c91nvRZJ3ELChHxdWNRf55USqdKI9p+whyNLf7SEdtQNyvmj6m5G
KLVCunOBl+XfeWWEj0aCDmUDk4dqcIGszEtUcKJzez7uMyua6vOaLVnzXWwMmtdr
qIbYL1PpMw30OskT5jwZ2vZEq/wDk16khSpmH/pUSr74Aa5rEaHAcAqvfZpVKIKk
kPf/nL5crg0RXsnEEi16MMgqjCxZ0dLbv0/1BrZSHvwiyWVymGjzxZah04N8cZGz
yjAi/9ouTg6rF3nqE+mzfC1L363yNpsur4gGmCQKHAF2AlD+DGYDaLzungxd7zfP
NycL6bUva+S5GQMOrJM175AnbnMT6PL6jRr62TTLnwzz6Gj69IRBO1ZG5sqKgqT9
tmCeyf1UPnsgXcJ23tHpGQCN+ym+JmJrkoYJsvwJYmhYeMs1UBuqR3ZIuxk1hPT3
skyZYQr3ru6f/GRrbK+v9iQPKbcWZ2A3xuZXDnuEGbmZVAa64rDpxuM+L4quIf5u
ZI/DDOTboxoda8BpXSnMQMYdyZUmmQ3J6sXUnRYhNXUmZ2FMxRsHmax0NI4HBF7/
LYTEIa4b/xFqq5FRYR67k0q2K1q09Z4nvCN5qVa8hBaHD22Yd8M=
=Nkz/
-----END PGP SIGNATURE-----
--=-=-=--
