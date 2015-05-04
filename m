Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46894 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751108AbbEDVsY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 May 2015 17:48:24 -0400
Date: Mon, 4 May 2015 17:48:22 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Kinglong Mee <kinglongmee@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under pseudo
 root
Message-ID: <20150504214822.GA16827@fieldses.org>
References: <20150429191934.GA23980@fieldses.org>
 <20150430075225.21a71056@notabene.brown>
 <20150430213602.GB9509@fieldses.org>
 <20150501115326.51f5613a@notabene.brown>
 <20150501020324.GP889@ZenIV.linux.org.uk>
 <20150501122333.1476c999@notabene.brown>
 <20150501022939.GQ889@ZenIV.linux.org.uk>
 <20150501130826.40721dd0@notabene.brown>
 <20150501132953.GA2583@fieldses.org>
 <20150503091653.35169382@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150503091653.35169382@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, May 03, 2015 at 09:16:53AM +1000, NeilBrown wrote:
> On Fri, 1 May 2015 09:29:53 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
> > On Fri, May 01, 2015 at 01:08:26PM +1000, NeilBrown wrote:
> > > On Fri, 1 May 2015 03:29:40 +0100 Al Viro <viro@ZenIV.linux.org.uk> wrote:
> > > 
> > > > On Fri, May 01, 2015 at 12:23:33PM +1000, NeilBrown wrote:
> > > > > > What kind of consistency warranties do callers expect, BTW?  You do realize
> > > > > > that between iterate_dir() and callbacks an entry might have been removed
> > > > > > and/or replaced?
> > > > > 
> > > > > For READDIR_PLUS, lookup_one_len is called on each name and it requires
> > > > > i_mutex, so the code currently holds i_mutex over the whole sequence.
> > > > > This is triggering a deadlock.
> > > > 
> > > > Yes, I've seen the context.  However, you are _not_ holding it between
> > > > actual iterate_dir() and those callbacks, which opens a window when
> > > > directory might have been changed.
> > > > 
> > > > Again, what kind of consistency is expected by callers?  Are they ready to
> > > > cope with "there's no such entry anymore" or "inumber is nothing like
> > > > what we'd put in ->ino, since it's no the same object" or "->d_type is
> > > > completely unrelated to what we'd found, since the damn thing had been
> > > > removed and created from scratch"?
> > > 
> > > Ah, sorry.
> > > 
> > > Yes, the callers are prepared for "there's no such entry anymore".
> > > They don't use d_type, so don't care if it might be meaningless.
> > > NFSv4 doesn't use ino either, but NFSv3 does and isn't properly cautious
> > > about ino changing.
> > > 
> > > In nfs3xdr, we should probably pass 'ino' to encode_entryplus_baggage() and
> > > thence to compose_entry_fh() and it should report failure if
> > > dchild->d_inode->i_ino doesn't match.
> > 
> > Just to make sure I understand the concern..... So it shouldn't really
> > be a problem if readdir and lookup find different objects for the same
> > name, the problem is just when we mix attributes from the two objects,
> > right?  Looks like the v3 code could return an inode number derived from
> > the readdir and a filehandle from the lookup, which is a problem.  The
> > v4 code will get everything from the result of the lookup, which should
> > be OK.
> 
> That agrees with my understanding, yes.
> 
> I did wonder for a little while about the possibility of a directory
> containing both 'a' and 'b', and NFSv4 doing the readdir and the stat of 'a',
> and the a "mv a b" happening before the stat of 'b'.
> 
> Then the readdir response will show both 'a' and 'b' referring to the same
> object with a link count of 1.
> 
> I can't quite decide if that is a problem or not.
> 
> 
> > 
> > > Simply not returning the extra attributes is perfectly acceptable in NFSv3.
> > 
> > Right, so no big deal anyway.--b.
> 
> Not a big deal, but we should really add a patch like the following ("like"
> as in "actually compile tested and documented" which this one isn't).

Doesn't seem to break anything.  Any second thoughts, or can I add a
signed-off-by?

--b.

commit e11f8acace69
Author: NeilBrown <neilb@suse.de>
Date:   Sun May 3 09:16:53 2015 +1000

    nfsd: stop READDIRPLUS returning inconsistent attributes
    
    The NFSv3 READDIRPLUS gets some of the returned attributes from the
    readdir, and some from an inode returned from a new lookup.  The two
    objects could be different thanks to intervening renames.
    
    The attributes in READDIRPLUS are optional, so let's just skip them if
    we notice this case.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index e4b2b4322553..f6e7cbabac5a 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -805,7 +805,7 @@ encode_entry_baggage(struct nfsd3_readdirres *cd, __be32 *p, const char *name,
 
 static __be32
 compose_entry_fh(struct nfsd3_readdirres *cd, struct svc_fh *fhp,
-		const char *name, int namlen)
+		 const char *name, int namlen, u64 ino)
 {
 	struct svc_export	*exp;
 	struct dentry		*dparent, *dchild;
@@ -830,19 +830,21 @@ compose_entry_fh(struct nfsd3_readdirres *cd, struct svc_fh *fhp,
 		goto out;
 	if (d_really_is_negative(dchild))
 		goto out;
+	if (dchild->d_inode->i_ino != ino)
+		goto out;
 	rv = fh_compose(fhp, exp, dchild, &cd->fh);
 out:
 	dput(dchild);
 	return rv;
 }
 
-static __be32 *encode_entryplus_baggage(struct nfsd3_readdirres *cd, __be32 *p, const char *name, int namlen)
+static __be32 *encode_entryplus_baggage(struct nfsd3_readdirres *cd, __be32 *p, const char *name, int namlen, u64 ino)
 {
 	struct svc_fh	*fh = &cd->scratch;
 	__be32 err;
 
 	fh_init(fh, NFS3_FHSIZE);
-	err = compose_entry_fh(cd, fh, name, namlen);
+	err = compose_entry_fh(cd, fh, name, namlen, ino);
 	if (err) {
 		*p++ = 0;
 		*p++ = 0;
@@ -927,7 +929,7 @@ encode_entry(struct readdir_cd *ccd, const char *name, int namlen,
 		p = encode_entry_baggage(cd, p, name, namlen, ino);
 
 		if (plus)
-			p = encode_entryplus_baggage(cd, p, name, namlen);
+			p = encode_entryplus_baggage(cd, p, name, namlen, ino);
 		num_entry_words = p - cd->buffer;
 	} else if (*(page+1) != NULL) {
 		/* temporarily encode entry into next page, then move back to
@@ -941,7 +943,7 @@ encode_entry(struct readdir_cd *ccd, const char *name, int namlen,
 		p1 = encode_entry_baggage(cd, p1, name, namlen, ino);
 
 		if (plus)
-			p1 = encode_entryplus_baggage(cd, p1, name, namlen);
+			p1 = encode_entryplus_baggage(cd, p1, name, namlen, ino);
 
 		/* determine entry word length and lengths to go in pages */
 		num_entry_words = p1 - tmp;
