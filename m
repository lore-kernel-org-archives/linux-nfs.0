Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52202 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751553Ab3HBLnP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Aug 2013 07:43:15 -0400
Date: Fri, 2 Aug 2013 07:43:53 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Ric Wheeler <rwheeler@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Anand Avati <avati@redhat.com>, Brian Foster <bfoster@redhat.com>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        Alexander Viro <aviro@redhat.com>, David Howells <dhowells@redhat.com>,
        Eric Paris <eparis@redhat.com>,
        Linux NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] [REPOST] fuse: drop dentry on failed revalidate
Message-ID: <20130802074353.514c8886@corrin.poochiereds.net>
In-Reply-To: <CAJfpegu1RXAYOGWyuCeckJ8WHfK=3dFc5bm1zsM=1Qt3zcfbsg@mail.gmail.com>
References: <20130725055209.GA15621@sh-el5.eng.rdu2.redhat.com>
	<51F13948.3050100@redhat.com>
	<CAJfpegtpcXz+i-3txRC_NjTsYjXP5S4oJUdGstG+-PWVzazEWQ@mail.gmail.com>
	<51F81465.9010402@redhat.com>
	<20130801163940.GA1356@tucsk.piliscsaba.szeredi.hu>
	<51FAACD9.8020205@redhat.com>
	<CAJfpegu1RXAYOGWyuCeckJ8WHfK=3dFc5bm1zsM=1Qt3zcfbsg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2 Aug 2013 11:02:25 +0200
Miklos Szeredi <miklos@szeredi.hu> wrote:

> On Thu, Aug 1, 2013 at 8:45 PM, Ric Wheeler <rwheeler@redhat.com> wrote:
> >
> > Adding in the NFS list for broader review.
> >
> > I thought that the issue was primarily in FUSE itself, not seen in practice
> > in NFS?
> 
> I haven't tested NFS (have but a single notebook here) but AFAICS the
> issue of not fuse specific but is inherent in the fact that NFS does
> d_drop() on a non-empty directory dentry.  It does check for submounts
> *before*, but it doesn't do anything about submounts *after* (or
> during) the d_drop().   It's probably not something people complain
> about, because they choose mountpoints to be pretty stable points in
> the tree that don't get removed or moved around.
> 
> Thanks,
> Miklos
> 
> >>
> >> diff --git a/fs/dcache.c b/fs/dcache.c
> >> index 87bdb53..5c51217 100644
> >> --- a/fs/dcache.c
> >> +++ b/fs/dcache.c
> >> @@ -1103,6 +1103,34 @@ rename_retry:
> >>   }
> >>   EXPORT_SYMBOL(have_submounts);
> >>   +static bool __has_unlinked_ancestor(struct dentry *dentry)
> >> +{
> >> +       struct dentry *this;
> >> +
> >> +       for (this = dentry; !IS_ROOT(this); this = this->d_parent) {
> >> +               if (d_unhashed(this))
> >> +                       return true;
> >> +       }
> >> +       return false;
> >> +}
> >> +
> >> +/*
> >> + * Called by mount code to check if the mountpoint is reachable (e.g. NFS
> >> can
> >> + * unhash a directory dentry and then the complete subtree can become
> >> + * unreachable).
> >> + */
> >> +bool has_unlinked_ancestor(struct dentry *dentry)
> >> +{
> >> +       bool found;
> >> +
> >> +       /* Need exclusion wrt. have_submounts() */
> >> +       write_seqlock(&rename_lock);
> >> +       found = __has_unlinked_ancestor(dentry);
> >> +       write_sequnlock(&rename_lock);
> >> +
> >> +       return found;
> >> +}
> >> +
> >>   /*
> >>    * Search the dentry child list of the specified parent,
> >>    * and move any unused dentries to the end of the unused
> >> diff --git a/fs/internal.h b/fs/internal.h
> >> index 7c5f01c..d232355 100644
> >> --- a/fs/internal.h
> >> +++ b/fs/internal.h
> >> @@ -126,6 +126,7 @@ extern int invalidate_inodes(struct super_block *,
> >> bool);
> >>    * dcache.c
> >>    */
> >>   extern struct dentry *__d_alloc(struct super_block *, const struct qstr
> >> *);
> >> +extern bool has_unlinked_ancestor(struct dentry *dentry);
> >>     /*
> >>    * read_write.c
> >> diff --git a/fs/namespace.c b/fs/namespace.c
> >> index 7b1ca9b..bb92a9c 100644
> >> --- a/fs/namespace.c
> >> +++ b/fs/namespace.c
> >> @@ -634,6 +634,15 @@ static struct mountpoint *new_mountpoint(struct
> >> dentry *dentry)
> >>         }
> >>         dentry->d_flags |= DCACHE_MOUNTED;
> >>         spin_unlock(&dentry->d_lock);
> >> +
> >> +       if (has_unlinked_ancestor(dentry)) {
> >> +               spin_lock(&dentry->d_lock);
> >> +               dentry->d_flags &= ~DCACHE_MOUNTED;
> >> +               spin_unlock(&dentry->d_lock);
> >> +               kfree(mp);
> >> +               return ERR_PTR(-ENOENT);
> >> +       }
> >> +
> >>         mp->m_dentry = dentry;
> >>         mp->m_count = 1;
> >>         list_add(&mp->m_hash, chain);
> >
> >


Ok, took me a couple of times to look over the code but I think I
understand the problem now...

IIUC, then this patch should only ever cause this to return -ENOENT in
a situation similar to the one in Anand's reproducer, right? The
mountpoint-to-be was unlinked in another tree, and thus we found it to
be invalid in the tree that we're mounting in. If so, then the dentry
didn't exist at some point during the race window. Returning -ENOENT
seems reasonable to me in that situation.

It might cause some strange setups to regress, but aren't those already
broken anyway? Or does the fact that NFS uses d_materialise_* helpers to
hook these dentries back into the tree help paper over that?

-- 
Jeff Layton <jlayton@redhat.com>
