Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:48238 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750975AbdILVrM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Sep 2017 17:47:12 -0400
From: NeilBrown <neilb@suse.com>
To: Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        "anna.schumaker\@netapp.com" <anna.schumaker@netapp.com>,
        "jlayton\@kernel.org" <jlayton@kernel.org>
Date: Wed, 13 Sep 2017 07:47:02 +1000
Cc: "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH] nfs: track writeback errors with errseq_t
In-Reply-To: <1505229616.28831.26.camel@redhat.com>
References: <20170720194227.7830-1-jlayton@kernel.org> <1503683981.22608.0.camel@redhat.com> <87h8wsiog4.fsf@notabene.neil.brown.name> <1503920855.4563.12.camel@redhat.com> <87pobfgo9q.fsf@notabene.neil.brown.name> <1504004058.4679.7.camel@redhat.com> <87efrjb2mn.fsf@notabene.neil.brown.name> <1504784132.4954.12.camel@redhat.com> <1504796087.3561.7.camel@primarydata.com> <874ls9diij.fsf@notabene.neil.brown.name> <1505126785.4916.7.camel@redhat.com> <87poawc390.fsf@notabene.neil.brown.name> <1505229616.28831.26.camel@redhat.com>
Message-ID: <87efrbbne1.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 12 2017, Jeff Layton wrote:

> On Tue, 2017-09-12 at 07:52 +1000, NeilBrown wrote:
>> > On Mon, 2017-09-11 at 13:24 +1000, NeilBrown wrote:
>> > > On Thu, Sep 07 2017, Trond Myklebust wrote:
>> > >=20
>> > > > On Thu, 2017-09-07 at 07:35 -0400, Jeff Layton wrote:
>> > > > > On Thu, 2017-09-07 at 13:37 +1000, NeilBrown wrote:
>> > > > > > On Tue, Aug 29 2017, Jeff Layton wrote:
>> > > > > >=20
>> > > > > > > On Tue, 2017-08-29 at 11:23 +1000, NeilBrown wrote:
>> > > > > > > > On Mon, Aug 28 2017, Jeff Layton wrote:
>> > > > > > > >=20
>> > > > > > > > > On Mon, 2017-08-28 at 09:24 +1000, NeilBrown wrote:
>> > > > > > > > > > On Fri, Aug 25 2017, Jeff Layton wrote:
>> > > > > > > > > >=20
>> > > > > > > > > > > On Thu, 2017-07-20 at 15:42 -0400, Jeff Layton wrote:
>> > > > > > > > > > > > From: Jeff Layton <jlayton@redhat.com>
>> > > > > > > > > > > >=20
>> > > > > > > > > > > > There is some ambiguity in nfs about how writeback
>> > > > > > > > > > > > errors are
>> > > > > > > > > > > > tracked.
>> > > > > > > > > > > >=20
>> > > > > > > > > > > > For instance, nfs_pageio_add_request calls
>> > > > > > > > > > > > mapping_set_error when
>> > > > > > > > > > > > the
>> > > > > > > > > > > > add fails, but we track errors that occur after ad=
ding
>> > > > > > > > > > > > the
>> > > > > > > > > > > > request
>> > > > > > > > > > > > with a dedicated int error in the open context.
>> > > > > > > > > > > >=20
>> > > > > > > > > > > > Now that we have better infrastructure for the vfs
>> > > > > > > > > > > > layer, this
>> > > > > > > > > > > > latter int is now unnecessary. Just have
>> > > > > > > > > > > > nfs_context_set_write_error set
>> > > > > > > > > > > > the error in the mapping when one occurs.
>> > > > > > > > > > > >=20
>> > > > > > > > > > > > Have NFS use file_write_and_wait_range to initiate=
 and
>> > > > > > > > > > > > wait on
>> > > > > > > > > > > > writeback
>> > > > > > > > > > > > of the data, and then check again after issuing the
>> > > > > > > > > > > > commit(s).
>> > > > > > > > > > > >=20
>> > > > > > > > > > > > With this, we also don't need to pay attention to =
the
>> > > > > > > > > > > > ERROR_WRITE
>> > > > > > > > > > > > flag for reporting, and just clear it to indicate =
to
>> > > > > > > > > > > > subsequent
>> > > > > > > > > > > > writers that they should try to go asynchronous ag=
ain.
>> > > > > > > > > > > >=20
>> > > > > > > > > > > > In nfs_page_async_flush, sample the error before
>> > > > > > > > > > > > locking and
>> > > > > > > > > > > > joining
>> > > > > > > > > > > > the requests, and check for errors since that poin=
t.
>> > > > > > > > > > > >=20
>> > > > > > > > > > > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
>> > > > > > > > > > > > ---
>> > > > > > > > > > > >  fs/nfs/file.c          | 24 +++++++++++----------=
---
>> > > > > > > > > > > >  fs/nfs/inode.c         |  3 +--
>> > > > > > > > > > > >  fs/nfs/write.c         |  8 ++++++--
>> > > > > > > > > > > >  include/linux/nfs_fs.h |  1 -
>> > > > > > > > > > > >  4 files changed, 18 insertions(+), 18 deletions(-)
>> > > > > > > > > > > >=20
>> > > > > > > > > > > > I have a baling wire and duct tape solution for te=
sting
>> > > > > > > > > > > > this with
>> > > > > > > > > > > > xfstests (using iptables REJECT targets and soft
>> > > > > > > > > > > > mounts). This
>> > > > > > > > > > > > seems to
>> > > > > > > > > > > > make nfs do the right thing.
>> > > > > > > > > > > >=20
>> > > > > > > > > > > > diff --git a/fs/nfs/file.c b/fs/nfs/file.c
>> > > > > > > > > > > > index 5713eb32a45e..15d3c6faafd3 100644
>> > > > > > > > > > > > --- a/fs/nfs/file.c
>> > > > > > > > > > > > +++ b/fs/nfs/file.c
>> > > > > > > > > > > > @@ -212,25 +212,23 @@ nfs_file_fsync_commit(struct=
 file
>> > > > > > > > > > > > *file,
>> > > > > > > > > > > > loff_t start, loff_t end, int datasync)
>> > > > > > > > > > > >  {
>> > > > > > > > > > > >  	struct nfs_open_context *ctx =3D
>> > > > > > > > > > > > nfs_file_open_context(file);
>> > > > > > > > > > > >  	struct inode *inode =3D file_inode(file);
>> > > > > > > > > > > > -	int have_error, do_resend, status;
>> > > > > > > > > > > > -	int ret =3D 0;
>> > > > > > > > > > > > +	int do_resend, status;
>> > > > > > > > > > > > +	int ret;
>> > > > > > > > > > > >=20=20
>> > > > > > > > > > > >  	dprintk("NFS: fsync file(%pD2) datasync %d\n",
>> > > > > > > > > > > > file,
>> > > > > > > > > > > > datasync);
>> > > > > > > > > > > >=20=20
>> > > > > > > > > > > >  	nfs_inc_stats(inode, NFSIOS_VFSFSYNC);
>> > > > > > > > > > > >  	do_resend =3D
>> > > > > > > > > > > > test_and_clear_bit(NFS_CONTEXT_RESEND_WRITES, &ctx-
>> > > > > > > > > > > > > flags);
>> > > > > > > > > > > >=20
>> > > > > > > > > > > > -	have_error =3D
>> > > > > > > > > > > > test_and_clear_bit(NFS_CONTEXT_ERROR_WRITE,
>> > > > > > > > > > > > &ctx->flags);
>> > > > > > > > > > > > -	status =3D nfs_commit_inode(inode, FLUSH_SYNC);
>> > > > > > > > > > > > -	have_error |=3D
>> > > > > > > > > > > > test_bit(NFS_CONTEXT_ERROR_WRITE, &ctx-
>> > > > > > > > > > > > > flags);
>> > > > > > > > > > > >=20
>> > > > > > > > > > > > -	if (have_error) {
>> > > > > > > > > > > > -		ret =3D xchg(&ctx->error, 0);
>> > > > > > > > > > > > -		if (ret)
>> > > > > > > > > > > > -			goto out;
>> > > > > > > > > > > > -	}
>> > > > > > > > > > > > -	if (status < 0) {
>> > > > > > > > > > > > +	clear_bit(NFS_CONTEXT_ERROR_WRITE, &ctx-
>> > > > > > > > > > > > > flags);
>> > > > > > > > > > > >=20
>> > > > > > > > > > > > +	ret =3D nfs_commit_inode(inode, FLUSH_SYNC);
>> > > > > > > > > > > > +
>> > > > > > > > > > > > +	/* Recheck and advance after the commit */
>> > > > > > > > > > > > +	status =3D file_check_and_advance_wb_err(file);
>> > > > > > > > > >=20
>> > > > > > > > > > This change makes the code inconsistent with the comme=
nt
>> > > > > > > > > > above the
>> > > > > > > > > > function, which still references ctx->error.  The inte=
nt of
>> > > > > > > > > > the
>> > > > > > > > > > comment
>> > > > > > > > > > is still correct, but the details have changed.
>> > > > > > > > > >=20
>> > > > > > > > >=20
>> > > > > > > > > Good catch. I'll fix that up in a respin.
>> > > > > > > > >=20
>> > > > > > > > > > Also, there is a call to mapping_set_error() in
>> > > > > > > > > > nfs_pageio_add_request().
>> > > > > > > > > > I wonder if that should be changed to
>> > > > > > > > > >   nfs_context_set_write_error(req->wb_context, desc-
>> > > > > > > > > > > pg_error)
>> > > > > > > > > >=20
>> > > > > > > > > > ??
>> > > > > > > > > >=20
>> > > > > > > > >=20
>> > > > > > > > > Trickier question...
>> > > > > > > > >=20
>> > > > > > > > > I'm not quite sure what semantics we're looking for with
>> > > > > > > > > NFS_CONTEXT_ERROR_WRITE. I know that it forces writes to=
 be
>> > > > > > > > > synchronous, but I'm not quite sure why it gets cleared =
the
>> > > > > > > > > way it
>> > > > > > > > > does. It's set on any error but cleared before issuing a
>> > > > > > > > > commit.
>> > > > > > > > >=20
>> > > > > > > > > I added a similar flag to Ceph inodes recently, but only
>> > > > > > > > > clear it when
>> > > > > > > > > a write succeeds. Wouldn't that make more sense here as =
well?
>> > > > > > > >=20
>> > > > > > > > It is a bit hard to wrap one's mind around.
>> > > > > > > >=20
>> > > > > > > > In the original code (commit 7b159fc18d417980) it looks li=
ke:
>> > > > > > > >  - test-and-clear bit
>> > > > > > > >  - write and sync
>> > > > > > > >  - test-bit
>> > > > > > > >=20
>> > > > > > > > This does, I think, seem safer than "clear on successful w=
rite"
>> > > > > > > > as the
>> > > > > > > > writes could complete out-of-order and I wouldn't be surpr=
ised
>> > > > > > > > if the
>> > > > > > > > unsuccessful ones completed with an error before the succe=
ssful
>> > > > > > > > one -
>> > > > > > > > particularly with an error like EDQUOT.
>> > > > > > > >=20
>> > > > > > > > However the current code does the writes before the test-a=
nd-
>> > > > > > > > clear, and
>> > > > > > > > only does the commit afterwards.  That makes it less clear=
 why
>> > > > > > > > the
>> > > > > > > > current sequence is a good idea.
>> > > > > > > >=20
>> > > > > > > > However ... nfs_file_fsync_commit() is only called if
>> > > > > > > > filemap_write_and_wait_range() returned with success, so we
>> > > > > > > > only clear
>> > > > > > > > the flag after successful writes(?).
>> > > > > > > >=20
>> > > > > > > > Oh....
>> > > > > > > > This patch from me:
>> > > > > > > >=20
>> > > > > > > > Commit: 2edb6bc3852c ("NFS - fix recent breakage to NFS er=
ror
>> > > > > > > > handling.")
>> > > > > > > >=20
>> > > > > > > > seems to have been reverted by
>> > > > > > > >=20
>> > > > > > > > Commit: 7b281ee02655 ("NFS: fsync() must exit with an erro=
r if
>> > > > > > > > page writeback failed")
>> > > > > > > >=20
>> > > > > > > > which probably isn't good.  It appears that this code is v=
ery
>> > > > > > > > fragile
>> > > > > > > > and easily broken.
>> > > > > >=20
>> > > > > > On further investigation, I think the problem that I fixed and=
 then
>> > > > > > we
>> > > > > > reintroduced will be fixed again - more permanently - by your
>> > > > > > patch.
>> > > > > > The root problem is that nfs keeps error codes in a different =
way
>> > > > > > to the
>> > > > > > MM core.  By unifying those, the problem goes.
>> > > > > > (The specific problem is that writes which hit EDQUOT on the s=
erver
>> > > > > > can
>> > > > > >  report EIO on the client).
>> > > > > >=20
>> > > > > >=20
>> > > > > > > > Maybe we need to work out exactly what is required, and
>> > > > > > > > document it - so
>> > > > > > > > we can stop breaking it.
>> > > > > > > > Or maybe we need some unit tests.....
>> > > > > > > >=20
>> > > > > > >=20
>> > > > > > > Yes, laying out what's necessary for this would be very help=
ful.
>> > > > > > > We
>> > > > > > > clearly want to set the flag when an error occurs. Under what
>> > > > > > > circumstances should we be clearing it?
>> > > > > >=20
>> > > > > > Well.... looking back at  7b159fc18d417980f57ae which introduc=
ed
>> > > > > > the
>> > > > > > flag, prior to that write errors (ctx->error) were only report=
ed by
>> > > > > > nfs_file_flush and nfs_fsync, so only one close() and fsync().
>> > > > > >=20
>> > > > > > After that commit, setting the flag would mean that errors cou=
ld be
>> > > > > > returned by 'write'.  So clearing as part of returning the err=
or
>> > > > > > makes
>> > > > > > perfect sense.
>> > > > > >=20
>> > > > > > As long as the error gets recorded, and gets returned when it =
is
>> > > > > > recorded, it doesn't much matter when the flag is cleared.  Wi=
th
>> > > > > > your
>> > > > > > patches we don't need to flag any more to get errors reliably
>> > > > > > reported.
>> > > > > >=20
>> > > > > > Leaving the flag set means that writes go more slowly - we don=
't
>> > > > > > get
>> > > > > > large queue of background rights building up but destined for
>> > > > > > failure.
>> > > > > > This is the main point made in the comment message when the fl=
ag
>> > > > > > was
>> > > > > > introduced.
>> > > > > > Of course, by the time we first get an error there could alrea=
dy
>> > > > > > by a large queue, so we probably want that to drain completely
>> > > > > > before
>> > > > > > allowing async writes again.
>> > > >=20
>> > > > We already have this functionality implemented in the existing cod=
e.
>> > > >=20
>> > > > > >=20
>> > > > > > It might make sense to have 2 flags.  One which says "writes s=
hould
>> > > > > > be
>> > > > > > synchronous", another that says "There was an error recently".
>> > > > > > We clear the error flag before calling nfs_fsync, and if it is
>> > > > > > still
>> > > > > > clear afterwards, we clear the sync-writes flag.  Maybe that is
>> > > > > > more
>> > > > > > complex than needed though.
>> > > > > >=20
>> > > >=20
>> > > > We also need to preserve the NFS_CONTEXT_RESEND_WRITES flag. I don=
't
>> > > > see any global mechanism that will replace that.
>> > > >=20
>> > > > > > I'm leaning towards your suggestion that it doesn't matter very
>> > > > > > much
>> > > > > > when it gets cleared, and clearing it on any successful write =
is
>> > > > > > simplest.
>> > > > > >=20
>> > > > > > So I'm still in favor of using nfs_context_set_write_error() in
>> > > > > > nfs_pageio_add_request(), primarily because it is most consist=
ent -
>> > > > > > we
>> > > > > > don't need exceptions.
>> > > > >=20
>> > > > > Thanks for taking a closer look. I can easily make the change ab=
ove,
>> > > > > and
>> > > > > I do think that keeping this mechanism as simple as possible will
>> > > > > make
>> > > > > it easier to prevent bitrot.
>> > > > >=20
>> > > > > That said... NFS_CONTEXT_ERROR_WRITE is a per ctx flag, and the =
ctx
>> > > > > is a
>> > > > > per open file description object.
>> > > > >=20
>> > > > > Is that the correct way to track this? All of the ctx's will sha=
re
>> > > > > the
>> > > > > same inode. If we're getting writeback errors for one context, i=
t's
>> > > > > quite likely that we'll be seeing them via others.
>> > > > >=20
>> > > > > I suppose the counterargument is when we have things like expiri=
ng
>> > > > > krb5
>> > > > > tickets. Write failures via an expiring set of creds may have no
>> > > > > effect
>> > > > > on writeback via other creds.
>> > > > >=20
>> > > > > Still, I think a per-inode flag might make more sense here.
>> > > > >=20
>> > > > > Thoughts?
>> > > >=20
>> > > > As far as I'm concerned, that would be a regression. The most comm=
on
>> > > > problem when flushing writeback data to the server aside from ENOS=
PC
>> > > > (and possibly ESTALE) is EACCES, which is particular to the file
>> > > > descriptor that opened the file.
>> > > >=20
>> > > > File contexts, and NFS_CONTEXT_ERROR_WRITE solve that problem by b=
eing
>> > > > private to the file descriptor.
>> > >=20
>> > > Thanks for the reminder that errors are per-context and this patch d=
rops
>> > > this.  The per-context nature of errors in NFS was the reason that I
>> > > nagged Jeff to make errseq_t a stand-alone type rather than just a p=
art
>> > > of address_space.  I had envisaged that it would be embedded in the
>> > > open_context as well.
>> > > We still could do that, but as there is precisely one open-file for =
each
>> > > open_context, the gains are not great.
>> > >=20
>> > > However, while looking over the code to make sure I really understoo=
d it
>> > > and all the possible consequences of changing to errseq_t I found a =
few
>> > > anomalies.  The patch below addresses them all.
>> > >=20
>> > > Would you see if they may sense to you?
>> > >=20
>> > > Thanks,
>> > > NeilBrown
>> > >=20
>> > >=20
>> > > From: NeilBrown <neilb@suse.com>
>> > > Date: Mon, 11 Sep 2017 13:15:50 +1000
>> > > Subject: [PATCH] NFS: various changes relating to reporting IO error=
s.
>> > >=20
>> > > 1/ remove 'start' and 'end' args from nfs_file_fsync_commit().
>> > >    They aren't used.
>> > >=20
>> > > 2/ Make nfs_context_set_write_error() a "static inline" in internal.h
>> > >    so we can...
>> > >=20
>> > > 3/ Use nfs_context_set_write_error() instead of mapping_set_error()
>> > >    if nfs_pageio_add_request() fails before sending any request.
>> > >    NFS generally keeps errors in the open_context, not the mapping,
>> > >    so this is more consistent.
>> > >=20
>> > > 4/ If filemap_write_and_write_range() reports any error, still
>> > >    check ctx->error.  The value in ctx->error is likely to be
>> > >    more useful.  As part of this, NFS_CONTEXT_ERROR_WRITE is
>> > >    cleared slightly earlier, before nfs_file_fsync_commit() is calle=
d,
>> > >    rather than at the start of that function.
>> > >=20
>> > > Signed-off-by: NeilBrown <neilb@suse.com>
>> > > ---
>> > >  fs/nfs/file.c     | 16 ++++++++++------
>> > >  fs/nfs/internal.h |  7 +++++++
>> > >  fs/nfs/pagelist.c |  4 ++--
>> > >  fs/nfs/write.c    |  7 -------
>> > >  4 files changed, 19 insertions(+), 15 deletions(-)
>> > >=20
>> > > diff --git a/fs/nfs/file.c b/fs/nfs/file.c
>> > > index af330c31f627..ab324f14081f 100644
>> > > --- a/fs/nfs/file.c
>> > > +++ b/fs/nfs/file.c
>> > > @@ -208,21 +208,19 @@ EXPORT_SYMBOL_GPL(nfs_file_mmap);
>> > >   * fall back to doing a synchronous write.
>> > >   */
>> > >  static int
>> > > -nfs_file_fsync_commit(struct file *file, loff_t start, loff_t end, =
int datasync)
>> > > +nfs_file_fsync_commit(struct file *file, int datasync)
>> > >  {
>> > >  	struct nfs_open_context *ctx =3D nfs_file_open_context(file);
>> > >  	struct inode *inode =3D file_inode(file);
>> > > -	int have_error, do_resend, status;
>> > > +	int do_resend, status;
>> > >  	int ret =3D 0;
>> > >=20=20
>> > >  	dprintk("NFS: fsync file(%pD2) datasync %d\n", file, datasync);
>> > >=20=20
>> > >  	nfs_inc_stats(inode, NFSIOS_VFSFSYNC);
>> > >  	do_resend =3D test_and_clear_bit(NFS_CONTEXT_RESEND_WRITES, &ctx->=
flags);
>> > > -	have_error =3D test_and_clear_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->f=
lags);
>> > >  	status =3D nfs_commit_inode(inode, FLUSH_SYNC);
>> > > -	have_error |=3D test_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
>> > > -	if (have_error) {
>> > > +	if (test_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags)) {
>> > >  		ret =3D xchg(&ctx->error, 0);
>> > >  		if (ret)
>> > >  			goto out;
>> > > @@ -247,10 +245,16 @@ nfs_file_fsync(struct file *file, loff_t start=
, loff_t end, int datasync)
>> > >  	trace_nfs_fsync_enter(inode);
>> > >=20=20
>> > >  	do {
>> > > +		struct nfs_open_context *ctx =3D nfs_file_open_context(file);
>> > >  		ret =3D filemap_write_and_wait_range(inode->i_mapping, start, end=
);
>> > > +		if (test_and_clear_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags)) {
>> > > +			int ret2 =3D xchg(&ctx->error, 0);
>> > > +			if (ret2)
>> > > +				ret =3D ret2;
>> > > +		}
>> > >  		if (ret !=3D 0)
>> > >  			break;
>> > > -		ret =3D nfs_file_fsync_commit(file, start, end, datasync);
>> > > +		ret =3D nfs_file_fsync_commit(file, datasync);
>> > >  		if (!ret)
>> > >  			ret =3D pnfs_sync_inode(inode, !!datasync);
>> > >  		/*
>> > > diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
>> > > index dc456416d2be..44c8962fec91 100644
>> > > --- a/fs/nfs/internal.h
>> > > +++ b/fs/nfs/internal.h
>> > > @@ -769,3 +769,10 @@ static inline bool nfs_error_is_fatal(int err)
>> > >  		return false;
>> > >  	}
>> > >  }
>> > > +
>> > > +static inline void nfs_context_set_write_error(struct nfs_open_cont=
ext *ctx, int error)
>> > > +{
>> > > +	ctx->error =3D error;
>> > > +	smp_wmb();
>> > > +	set_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
>> > > +}
>> > > diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
>> > > index de9066a92c0d..0ebd26b9a6bd 100644
>> > > --- a/fs/nfs/pagelist.c
>> > > +++ b/fs/nfs/pagelist.c
>> > > @@ -1198,8 +1198,8 @@ out_failed:
>> > >=20=20
>> > >  		/* remember fatal errors */
>> > >  		if (nfs_error_is_fatal(desc->pg_error))
>> > > -			mapping_set_error(desc->pg_inode->i_mapping,
>> > > -					  desc->pg_error);
>> > > +			nfs_context_set_write_error(req->wb_context,
>> > > +						    desc->pg_error);
>> > >=20=20
>> > >  		func =3D desc->pg_completion_ops->error_cleanup;
>> > >  		for (midx =3D 0; midx < desc->pg_mirror_count; midx++) {
>> > > diff --git a/fs/nfs/write.c b/fs/nfs/write.c
>> > > index b1af5dee5e0a..f702bf2def79 100644
>> > > --- a/fs/nfs/write.c
>> > > +++ b/fs/nfs/write.c
>> > > @@ -147,13 +147,6 @@ static void nfs_io_completion_put(struct nfs_io=
_completion *ioc)
>> > >  		kref_put(&ioc->refcount, nfs_io_completion_release);
>> > >  }
>> > >=20=20
>> > > -static void nfs_context_set_write_error(struct nfs_open_context *ct=
x, int error)
>> > > -{
>> > > -	ctx->error =3D error;
>> > > -	smp_wmb();
>> > > -	set_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
>> > > -}
>> > > -
>> > >  /*
>> > >   * nfs_page_find_head_request_locked - find head request associated=
 with @page
>> > >   *
>> >=20
>> > This should probably be broken out into at least a 2-3 different
>> > patches.
>> >=20
>> > Ok, so to make sure I understand:
>> >=20
>> > All writeback is done under the aegis of an open context, and writes
>> > from different open contexts are not mergeable. We also flush to the
>> > server in the case that a dirty page is written via an incompatible op=
en
>> > context. So with that we can always tie
>>=20
>> Not quite.  Writes from different open contexts are sometimes mergeable,
>> providing the credential is the same and there are no locks that might
>> get in the way. (nfs_flush_incompatible() gets rid of conflicts writes
>> to the same page as part of nfs_write_begin().
>> When writes are merged, all contexts remain reachable from the request
>> through an 'nfs_page'. nfs_write_completion() iterates over all the
>> nfs_pages attached to the nfs_pgio_header, and sets the context
>> write_error from the hdr->error.
>>=20
>
> Ok, by this account, NFS should already have "correct" error reporting
> semantics on fsync. i.e. when the file is written via multiple fds, you
> should get back an error on all fds if those writebacks failed.
>
> I have a test for nfs for the new-style error reporting:
>
>     https://git.kernel.org/pub/scm/linux/kernel/git/jlayton/xfstests-dev.=
git/log/?h=3Dwberr
>
> The nfs test is still pretty rickety, using soft mounts and iptables to
> cause requests to fail. With the patch I originally proposed, this test
> would pass. When I run this test on normal mainline kernels, it fails:
>
> -------------------------------8<------------------------------
> FSTYP         -- nfs
> PLATFORM      -- Linux/x86_64 wberr 4.12.11-300.fc26.x86_64
> MKFS_OPTIONS  -- knfsdsrv:/export/scratch
> MOUNT_OPTIONS -- -o context=3Dsystem_u:object_r:root_t:s0 knfsdsrv:/expor=
t/scratch /mnt/scratch
>
> nfs/002	 - output mismatch (see /home/jlayton/git/xfstests/results//nfs/0=
02.out.bad)
>     --- tests/nfs/002.out	2017-07-19 13:12:59.354561869 -0400
>     +++ /home/jlayton/git/xfstests/results//nfs/002.out.bad	2017-09-12 11=
:17:17.335943539 -0400
>     @@ -1,3 +1,3 @@
>      QA output created by 002
>      Format and mount
>     -Test passed!
>     +Success on second fsync on fd[1]!

Interesting.
I haven't reviewed the kernel code yet, but having looked at the test
code I see that the one file is opened 10 time and that the *same* block
in the file (65k?) is written via each fd.
If I write to a file, and then someone else over-writes all the bytes
that I wrote, then the page is written to the server and gets an error,
then you could argue that as none of the bytes I wrote were involved in
the error, I don't need to see the error status - someone else has taken
on responsibility for that range.

Maybe the test should/could write a few bytes with a different offset for e=
ach
fd ??

NeilBrown


>     ...
>     (Run 'diff -u tests/nfs/002.out /home/jlayton/git/xfstests/results//n=
fs/002.out.bad'  to see the entire diff)
> Ran: nfs/002
> Failures: nfs/002
> Failed 1 of 1 tests
> -------------------------------8<------------------------------
>
> I'm not sure that errors are really propagated to all struct files like
> you suggest above. I'll plan to look a little more closely at what's
> happening here, when I get some time.
>
>> >=20
>> > In that case, yes...mixing in errseq_t doesn't really buy us much here,
>> > and I agree with most of the changes above.
>> >=20
>> > That said...I'm still not thrilled with how NFS_CONTEXT_ERROR_WRITE is
>> > handled in this code. That flag is set when a write fails, but is only
>> > cleared on fsync.
>> >=20
>> > That seems wrong to me. Why wait for an fsync to start doing async
>> > writes again once they start working? What if the application never do=
es
>> > an fsync? Clearing that flag on a successful WRITE seems like it'd make
>> > more sense.
>>=20
>> We don't really 'wait' for an fsync.  Having NFS_CONTEXT_ERROR_WRITE
>> means that the very next write will force an fsync
>> (nfs_need_check_write()).  So we really just wait for the next write.
>> The current code doesn't seem "obviously right" to me, but it isn't
>> "obviously wrong" either, and I can only make it obviously right to me
>> by making it more complex, and I don't think I can justify that.
>
> Thanks for pointing this out. I missed the bit about it forcing the
> fsync when this fails. I agree that that should be fine.
>
> --=20
> Jeff Layton <jlayton@redhat.com>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlm4VdYACgkQOeye3VZi
gbku0Q/8CnmtVG5BQq7y4x/0Hp4pgOTd92IHhpmkmSnB2g9i4Z91qMVI0wrFqbWc
++9zAGW84Q9TkmLcdJ0+qT6evdj0t9WMyBrifkuFzze3MtON2j9cW2zSqX5Rlj4O
x0IL+93hMda7Q8TfxwfyXXYv88vpIsm3ezv8iBHjqAL5dcnkn6DufyCnXTCrybkH
bEiCg4PYzzoy5M//Qa6J1nJthMmULxDHlr99FMs+IpshrSP3ROUjb8ePbRftGLYN
u5+wolV6ndRHb2c5QjDrW6p0IQMakSuNSd9Q99mxMP7h8p9ulBdnzAtE7rXiP3JA
AqVe1/FKyT/8AqiktAoDnmPKACIHpELKSoPjMLY9oY1IYnpCrEeNw/Be3lvoPqnx
Zn0YCcS5ngyGCnd3lJ+YUc2PpbARYoA/kKCNiFQz9qozkm0//ZnCn1QlJhPMQyH4
lNWxoFUtiEsvszEIzor6lIDVcEjnOfJ+qEheRNh2StVjUZTLwtXGz9XBv2YwK+VV
7XqQWxeAYIlYyIJvTbjQLS8MmznBXVTai+Rwyfc2cbhvFFb4z2iNjRxoe7gCerUp
A7N+rtOojmRNhWeu6cJ8fibZum8EbV/kzyBU4xhd9rC6BVikiXxeA2bt+co7UtdR
L9itGGKXixkR5k4vVMODPoDij5jfs/BK0skXgg+dQuNfY22UVSk=
=Kv1Y
-----END PGP SIGNATURE-----
--=-=-=--
