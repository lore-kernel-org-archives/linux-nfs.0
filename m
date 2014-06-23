Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:13346 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751108AbaFWWKT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Jun 2014 18:10:19 -0400
Date: Mon, 23 Jun 2014 18:10:17 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/3] nfsd: fix rare symlink decoding bug
Message-ID: <20140623221016.GA9429@pad.redhat.com>
References: <1403559272-11019-1-git-send-email-bfields@redhat.com>
 <CAHQdGtQXjvyaXx9PkYW=96F+wvPEj8-=eGFV2NDpfFZEB77E5w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtQXjvyaXx9PkYW=96F+wvPEj8-=eGFV2NDpfFZEB77E5w@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 23, 2014 at 05:41:31PM -0400, Trond Myklebust wrote:
> On Mon, Jun 23, 2014 at 5:34 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> > +               len = create->cr_linklen;
> > +               data = kmalloc(len + 1, GFP_KERNEL);
> > +               /*
> > +                * Null-terminating in place isn't safe since
> > +                * cr_linkname might end on a page boundary.
> >                  */
> > -               create->cr_linkname[create->cr_linklen] = 0;
> > -
> > +               if (!data)
> > +                       return nfserr_jukebox;
> > +               memcpy(data, create->cr_linkname, len + 1);
> 
> Shouldn't that be a copy of 'len' bytes?

Doh, yes.

After sending out I realized that we'd probably rather than do a single
alloc&copy instead of two, so I'm thinking of doing the following (still
testing).

But my first draft of that had the same problem that you pointed out
here!

--b.

commit f719db9342235b3ebd4d65b9944fce9168177682
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Jun 19 16:44:48 2014 -0400

    nfsd: fix rare symlink decoding bug
    
    An NFS operation that creates a new symlink includes the symlink data,
    which is xdr-encoded as a length followed by the data plus 0 to 3 bytes
    of zero-padding as required to reach a 4-byte boundary.
    
    The vfs, on the other hand, wants null-terminated data.
    
    The simple way to handle this would be by copying the data into a newly
    allocated buffer with space for the final null.
    
    The current nfsd_symlink code tries to be more clever by skipping that
    step in the (likely) case where the byte following the string is already
    0.
    
    But that assumes that the byte following the string is ours to look at.
    In fact, it might be the first byte of a page that we can't read, or of
    some object that another task might modify.
    
    Worse, the NFSv4 code tries to fix the problem by actually writing to
    that byte.
    
    In the NFSv2/v3 cases this actually appears to be safe:
    
    	- nfs3svc_decode_symlinkargs explicitly null-terminates the data
    	  (after first checking its length and copying it to a new
    	  page).
    	- NFSv2 limits symlinks to 1k.  The buffer holding the rpc
    	  request is always at least a page, and the link data (and
    	  previous fields) have maximum lengths that prevent the request
    	  from reaching the end of a page.
    
    In the NFSv4 case the CREATE op is potentially just one part of a long
    compound so can end up on the end of a page if you're unlucky.
    
    The minimal fix here is to copy and null-terminate in the NFSv4 case.
    The nfsd_symlink() interface here seems too fragile, though.  It should
    really either do the copy itself every time or just require a
    null-terminated string.
    
    Reported-by: Jeff Layton <jlayton@primarydata.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 6851b00..8f029db 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -617,15 +617,6 @@ nfsd4_create(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	switch (create->cr_type) {
 	case NF4LNK:
-		/* ugh! we have to null-terminate the linktext, or
-		 * vfs_symlink() will choke.  it is always safe to
-		 * null-terminate by brute force, since at worst we
-		 * will overwrite the first byte of the create namelen
-		 * in the XDR buffer, which has already been extracted
-		 * during XDR decode.
-		 */
-		create->cr_linkname[create->cr_linklen] = 0;
-
 		status = nfsd_symlink(rqstp, &cstate->current_fh,
 				      create->cr_name, create->cr_namelen,
 				      create->cr_linkname, create->cr_linklen,
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 2d305a1..56bdf4a 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -600,7 +600,18 @@ nfsd4_decode_create(struct nfsd4_compoundargs *argp, struct nfsd4_create *create
 		READ_BUF(4);
 		create->cr_linklen = be32_to_cpup(p++);
 		READ_BUF(create->cr_linklen);
-		SAVEMEM(create->cr_linkname, create->cr_linklen);
+		/*
+		 * The VFS will want a null-terminated string, and
+		 * null-terminating in place isn't safe since this might
+		 * end on a page boundary:
+		 */
+		create->cr_linkname =
+				kmalloc(create->cr_linklen + 1, GFP_KERNEL);
+		if (!create->cr_linkname)
+			return nfserr_jukebox;
+		memcpy(create->cr_linkname, p, create->cr_linklen);
+		create->cr_linkname[create->cr_linklen] = '\0';
+		defer_free(argp, kfree, create->cr_linkname);
 		break;
 	case NF4BLK:
 	case NF4CHR:
