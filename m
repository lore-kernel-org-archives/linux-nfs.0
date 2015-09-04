Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:33126 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757849AbbIDKlW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Sep 2015 06:41:22 -0400
Received: by ykei199 with SMTP id i199so16581218yke.0
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2015 03:41:21 -0700 (PDT)
Date: Fri, 4 Sep 2015 06:41:17 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: steved@redhat.com, Bruce James Fields <bfields@fieldses.org>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] exportfs: add support for "nowcc" option
Message-ID: <20150904064117.1a011f45@tlielax.poochiereds.net>
In-Reply-To: <CAHQdGtS=ZCnG+YgNZAT0+DqpBQs30OQOZLsvTEDNsxA6x7EUEg@mail.gmail.com>
References: <1441301785-17602-1-git-send-email-jeff.layton@primarydata.com>
	<20150903183103.GB10088@fieldses.org>
	<20150903144544.58cfd728@tlielax.poochiereds.net>
	<20150903190548.GE10088@fieldses.org>
	<20150903194255.GG10088@fieldses.org>
	<20150903160011.1104a3d3@tlielax.poochiereds.net>
	<20150903203200.GI10088@fieldses.org>
	<20150903164330.7c050480@tlielax.poochiereds.net>
	<CAHQdGtS=ZCnG+YgNZAT0+DqpBQs30OQOZLsvTEDNsxA6x7EUEg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 3 Sep 2015 15:27:52 -0700
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Sep 3, 2015 16:43, "Jeff Layton" <jlayton@poochiereds.net> wrote:
> >
> > On Thu, 3 Sep 2015 16:32:00 -0400
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> >
> > > On Thu, Sep 03, 2015 at 04:00:11PM -0400, Jeff Layton wrote:
> > > > On Thu, 3 Sep 2015 15:42:55 -0400
> > > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > >
> > > > > On Thu, Sep 03, 2015 at 03:05:48PM -0400, J. Bruce Fields wrote:
> > > > > > On Thu, Sep 03, 2015 at 02:45:44PM -0400, Jeff Layton wrote:
> > > > > > > On Thu, 3 Sep 2015 14:31:03 -0400
> > > > > > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > > > > >
> > > > > > > > On Thu, Sep 03, 2015 at 01:36:25PM -0400, Jeff Layton wrote:
> > > > > > > > > This is the userland companion patch for the patch to add a
> "nowcc"
> > > > > > > > > option to knfsd. This just adds the necessary code to allow
> userspace
> > > > > > > > > to set that option.
> > > > > > > > >
> > > > > > > > > Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> > > > > > > > > ---
> > > > > > > > >  support/include/nfs/export.h |  3 ++-
> > > > > > > > >  support/nfs/exports.c        |  5 +++++
> > > > > > > > >  utils/exportfs/exportfs.c    |  2 ++
> > > > > > > > >  utils/exportfs/exports.man   | 14 ++++++++++++++
> > > > > > > > >  4 files changed, 23 insertions(+), 1 deletion(-)
> > > > > > > > >
> > > > > > > > > diff --git a/support/include/nfs/export.h
> b/support/include/nfs/export.h
> > > > > > > > > index 1194255899bd..68bee5c2f305 100644
> > > > > > > > > --- a/support/include/nfs/export.h
> > > > > > > > > +++ b/support/include/nfs/export.h
> > > > > > > > > @@ -26,7 +26,8 @@
> > > > > > > > >  #define  NFSEXP_CROSSMOUNT       0x4000
> > > > > > > > >  #define NFSEXP_NOACL             0x8000 /* reserved for
> possible ACL related use */
> > > > > > > > >  #define NFSEXP_V4ROOT            0x10000
> > > > > > > > > -#define NFSEXP_PNFS            0x20000
> > > > > > > > > +#define NFSEXP_PNFS              0x20000
> > > > > > > > > +#define NFSEXP_NOWCC             0x40000
> > > > > > > > >  /*
> > > > > > > > >   * All flags supported by the kernel before addition of the
> > > > > > > > >   * export_features interface:
> > > > > > > > > diff --git a/support/nfs/exports.c b/support/nfs/exports.c
> > > > > > > > > index 0aea6f154f09..791b5f756c9c 100644
> > > > > > > > > --- a/support/nfs/exports.c
> > > > > > > > > +++ b/support/nfs/exports.c
> > > > > > > > > @@ -276,6 +276,7 @@ putexportent(struct exportent *ep)
> > > > > > > > >   if (ep->e_flags & NFSEXP_NOREADDIRPLUS)
> > > > > > > > >           fprintf(fp, "nordirplus,");
> > > > > > > > >   fprintf(fp, "%spnfs,", (ep->e_flags & NFSEXP_PNFS)? "" :
> "no_");
> > > > > > > > > + fprintf(fp, "%swcc,", (ep->e_flags & NFSEXP_NOWCC) ? "no"
> : "");
> > > > > > > > >   if (ep->e_flags & NFSEXP_FSID) {
> > > > > > > > >           fprintf(fp, "fsid=%d,", ep->e_fsid);
> > > > > > > > >   }
> > > > > > > > > @@ -586,6 +587,10 @@ parseopts(char *cp, struct exportent
> *ep, int warn, int *had_subtree_opt_ptr)
> > > > > > > > >                   setflags(NFSEXP_PNFS, active, ep);
> > > > > > > > >           else if (!strcmp(opt, "no_pnfs"))
> > > > > > > > >                   clearflags(NFSEXP_PNFS, active, ep);
> > > > > > > > > +         else if (!strcmp(opt, "wcc"))
> > > > > > > > > +                 clearflags(NFSEXP_NOWCC, active, ep);
> > > > > > > > > +         else if (!strcmp(opt, "nowcc"))
> > > > > > > > > +                 setflags(NFSEXP_NOWCC, active, ep);
> > > > > > > > >           else if (strncmp(opt, "anonuid=", 8) == 0) {
> > > > > > > > >                   char *oe;
> > > > > > > > >                   ep->e_anonuid = strtol(opt+8, &oe, 10);
> > > > > > > > > diff --git a/utils/exportfs/exportfs.c
> b/utils/exportfs/exportfs.c
> > > > > > > > > index 87582316b086..a2afc80ee6ea 100644
> > > > > > > > > --- a/utils/exportfs/exportfs.c
> > > > > > > > > +++ b/utils/exportfs/exportfs.c
> > > > > > > > > @@ -823,6 +823,8 @@ dump(int verbose, int export_format)
> > > > > > > > >                           c = dumpopt(c, "no_acl");
> > > > > > > > >                   if (ep->e_flags & NFSEXP_PNFS)
> > > > > > > > >                           c = dumpopt(c, "pnfs");
> > > > > > > > > +                 if (ep->e_flags & NFSEXP_NOWCC)
> > > > > > > > > +                         c = dumpopt(c, "nowcc");
> > > > > > > > >                   if (ep->e_flags & NFSEXP_FSID)
> > > > > > > > >                           c = dumpopt(c, "fsid=%d",
> ep->e_fsid);
> > > > > > > > >                   if (ep->e_uuid)
> > > > > > > > > diff --git a/utils/exportfs/exports.man
> b/utils/exportfs/exports.man
> > > > > > > > > index 93092463153b..9213a228bb04 100644
> > > > > > > > > --- a/utils/exportfs/exports.man
> > > > > > > > > +++ b/utils/exportfs/exports.man
> > > > > > > > > @@ -417,6 +417,20 @@ devices. The default can be explicitly
> requested with the
> > > > > > > > >  .I no_pnfs
> > > > > > > > >  option.
> > > > > > > > >
> > > > > > > > > +.TP
> > > > > > > > > +.IR nowcc
> > > > > > > > > +This option disables the collection and reporting of WCC
> (weak cache
> > > > > > > > > +consistency) data in NFSv3 requests.  RFC 1813 recommends
> that all
> > > > > > > > > +servers report this information to the clients as it
> allows the client
> > > > > > > > > +to avoid some extra round trips to the server.  In some
> underlying
> > > > > > > > > +filesystems however, collecting this data can be cost
> prohibitive and
> > > > > > > > > +atomicity is difficult to guarantee.
> > > > >
> > > > > By the way, independently of this change, maybe we should by default
> > > > > disable the pre-op attribute on distributed filesystems?  As I
> > > > > understand it we're just depending on the i_mutex for atomicity,
> which
> > > > > can't be right in that case.
> > > > >
> > > > > --b.
> > > >
> > > > Right. In the case of something like a clustered or network filesystem
> > > > you really can't guarantee atomicity, so why even try?
> > > >
> > > > So, that is another option...we could add a flags field to the
> > > > export_operations struct and use one flag to indicate whether to send
> > > > wcc attrs. That'd give us the ability to add other flags in the future
> > > > as well.
> > > >
> > > > The reason I went with the export option is that I didn't really want
> > > > to add the flags field, and I figured the flexibility of being able to
> > > > do that on any filesystem might be helpful.
> > > >
> > > > That said, I'm open to doing it that way instead of (or in addition
> to)
> > > > the export option if you think it would be better.
> > >
> > > Well, it's sounding so far like:
> > >
> > >       - nobody will want this on a non-distributed filesystem (hard to
> > >         see what the benefit would be; and it might cost).
> > >       - people probably *do* want this on any distributed filesystem.
> > >       - we could save users some trouble by not giving them another
> > >         export option which they might just set wrong.
> > >
> > > Eh, but I think I'm wrong about #2.  Dropping the pre-op attribute is
> > > arguably necessary for correctness, but dropping the post-op attribute
> > > as well isn't necessary and might hurt, right?  OK.
> > >
> >
> > Oh, hmmm.
> >
> > The pre-op attrs are generally pretty lightweight. It just scrapes the
> > info out of the in-core inode. The post-op attrs require a vfs_getattr
> > call though, and that's where the expensive part comes in. I guess I
> > looked at them as a unit. You either want both pre and post attrs or
> > none. The patch disables both when you add the nowcc option.
> >
> > So I guess this means you're leaning toward a flags field in the export
> > operations instead of an export option? If so, I'm fine with that and I
> > can respin the patch accordingly.
> 
> Agreed that this is desirable. Which filesystems are going to turn this on
> by default?
> 

Good question. I'll certainly do it for NFS in the reexporting code
that we're working on, but I'd be a little leery of adding this to
others without some OK by their maintainers and some testing. I'd
expect that ceph, lustre, gfs2, and ocfs2 would probably be good places
to consider enabling it though.

What I'll probably do is add the flag and drop a note to those
maintainers mentioning that they may want to consider enabling it. I'll
also plan to document this in Documentation/filesystems/nfs/Exporting
to help them make an informed decision about it.

> > There is probably some micro-optimization in turning them off on local
> > filesystems when you are doing DIO or having it act as a DS for
> > flexfiles, but I doubt it's significant enough to bother with.
> 
> Disagree. There are quite a few workloads where the wcc mainly results in
> unnecessary cache flushes on the client due to out of order RPC replies.
> I.e. the sysadmin knows there is only one client accessing the file at a
> time, but the OOO replies lead to clients believing there are multiple
> accesses to the same file.
> 

Ahh...apples and oranges. I was referring to the performance impact of
doing the actual vfs_getattr call on the underlying fs, not the effect
on the client. For filesystems that have a cheap getattr routine, there
really is little harm to the server in sending the data along.

OOO replies are a different problem entirely though. It seems like that
might be better addressed by a  "nowcc" mount option on the client?
Having to set that on the server seems a bit too coarse-grained if the
admin has to make that decision based on workload.

-- 
Jeff Layton <jlayton@poochiereds.net>
