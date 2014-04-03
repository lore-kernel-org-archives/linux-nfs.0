Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6183 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753388AbaDCUMB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Apr 2014 16:12:01 -0400
Date: Thu, 3 Apr 2014 16:11:53 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Mark Lord <mlord@pobox.com>
Cc: Albert Fluegel <af@muc.de>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: linux-3.14 nfsd regression
Message-ID: <20140403201153.GD28790@pad.redhat.com>
References: <533D8D73.1090603@pobox.com>
 <20140403171643.GB28790@pad.redhat.com>
 <533D9F8A.6030001@pobox.com>
 <20140403193024.GC28790@pad.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140403193024.GC28790@pad.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 03, 2014 at 03:30:24PM -0400, J. Bruce Fields wrote:
> On Thu, Apr 03, 2014 at 01:51:06PM -0400, Mark Lord wrote:
> > On 14-04-03 01:16 PM, J. Bruce Fields wrote:
> > > On Thu, Apr 03, 2014 at 12:33:55PM -0400, Mark Lord wrote:
> > >> This commit from linux-3.14 breaks our NFS-root clients here:
> > >>
> > >> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=6e14b46b91fee8a049b0940333ce13a820beaaa5
> > >>
> > >>
> > >> - *p++ = htonl((u32) stat->mode);
> > >> + *p++ = htonl((u32) (stat->mode & S_IALLUGO));
> > >>
> > >>
> > >> Reverting the one-liner above (on the server) fixes it for us,
> > >> as does reverting back to linux-3.13.8 on the server.
> > >>
> > >> The NFS-root clients are on PowerPC (big-endian) architecture,
> > >> running linux-3.12.16. The NFS server is on an Intel PC running linux-3.14.
> > >>
> > >> ACL is completely disabled on server and client,
> > >> and we're using NFSv2/v3.  No support for v4.
> > >>
> > >> I instrumented the function to see what other bits were being cleared
> > >> by the (stat->mode & S_IALLUGO) masking.  The results are attached.
> > > 
> > > Hm, it sounds like a bug in the client if it's depending on those high
> > > bits.
> > 
> > But only for mounting / starting up from the nfsroot, it seems.
> > I wonder if there's an unusual code path for that in there?
> > The regular stuff looks mostly fine:
> > 
> >         p = xdr_decode_ftype3(p, &fmode);
> >         fattr->mode = (be32_to_cpup(p++) & ~S_IFMT) | fmode;
> 
> Hm, but that's in nfs3xdr.c; in nfs2xdr.c we have just
> 
> 	fattr->mode = be32_to_cpup(p+);
> 
> and NFSv2 is the default for nfsroot.  Do you have some reason to
> believe you're not using NFSv2?

Oh, bah, after actually writing a patch for this I thought to check the
rfc's and in fact rfc 1094 2.3.5 says that v2 *does* encode the file
type both in the type and mode fields of the attributes, though it
describes this as "a bug in the protocol".

So I think the nfsd patch was just flat-out wrong in the v2 case, and
that it probably just isn't worth "fixing" the client.

But patch included below anyway for amusement value.

--b.

commit 86706287828aa5b4deed6b6b1478e89d2e2c9707
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Apr 3 16:04:59 2014 -0400

    nfs: nfsv2 client shouldn't get ftype from mode
    
    The NFSv2 client is using the high bits of the mode to determine the
    file type; use the "type" field instead.
    
    XXX: rfc 1094 actually says this behavior is correct for NFSv2, though
    this is described as "a bug in the protocol".  So probably this isn't
    worth changing.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 62db136..40fb021 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -166,23 +166,28 @@ out_overflow:
 }
 
 /*
- * 2.3.2.  ftype
- *
- *	enum ftype {
- *		NFNON = 0,
- *		NFREG = 1,
- *		NFDIR = 2,
- *		NFBLK = 3,
- *		NFCHR = 4,
- *		NFLNK = 5
- *	};
- *
+ * Map file type to S_IFMT bits
  */
-static __be32 *xdr_decode_ftype(__be32 *p, u32 *type)
+static const umode_t nfs2_type2fmt[] = {
+	[NFNON] = 0,
+	[NFREG] = S_IFREG,
+	[NFDIR] = S_IFDIR,
+	[NFBLK] = S_IFBLK,
+	[NFCHR] = S_IFCHR,
+	[NFLNK] = S_IFLNK,
+	[NFSOCK] = S_IFSOCK,
+	[NFBAD] = 0,
+	[NFFIFO] = S_IFIFO,
+};
+
+static __be32 *xdr_decode_ftype(__be32 *p, umode_t *mode)
 {
-	*type = be32_to_cpup(p++);
-	if (unlikely(*type > NF2FIFO))
-		*type = NFBAD;
+	u32 type;
+
+	type = be32_to_cpup(p++);
+	if (unlikely(type > NF2FIFO))
+		type = NFBAD;
+	*mode = nfs2_type2fmt[type];
 	return p;
 }
 
@@ -277,7 +282,8 @@ static __be32 *xdr_decode_time(__be32 *p, struct timespec *timep)
  */
 static int decode_fattr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 {
-	u32 rdev, type;
+	umode_t fmode;
+	u32 rdev;
 	__be32 *p;
 
 	p = xdr_inline_decode(xdr, NFS_fattr_sz << 2);
@@ -286,9 +292,9 @@ static int decode_fattr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 
 	fattr->valid |= NFS_ATTR_FATTR_V2;
 
-	p = xdr_decode_ftype(p, &type);
+	p = xdr_decode_ftype(p, &fmode);
 
-	fattr->mode = be32_to_cpup(p++);
+	fattr->mode = (be32_to_cpup(p++) & ~S_IFMT) | fmode;
 	fattr->nlink = be32_to_cpup(p++);
 	fattr->uid = make_kuid(&init_user_ns, be32_to_cpup(p++));
 	if (!uid_valid(fattr->uid))
@@ -302,7 +308,7 @@ static int decode_fattr(struct xdr_stream *xdr, struct nfs_fattr *fattr)
 
 	rdev = be32_to_cpup(p++);
 	fattr->rdev = new_decode_dev(rdev);
-	if (type == (u32)NFCHR && rdev == (u32)NFS2_FIFO_DEV) {
+	if (fmode == S_IFCHR && rdev == (u32)NFS2_FIFO_DEV) {
 		fattr->mode = (fattr->mode & ~S_IFMT) | S_IFIFO;
 		fattr->rdev = 0;
 	}
