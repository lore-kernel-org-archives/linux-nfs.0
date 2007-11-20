From: Greg Kroah-Hartman <gregkh@suse.de>
Subject: [NFS] [patch 07/29] knfsd: fix spurious EINVAL errors on first
	access of	new filesystem
Date: Tue, 20 Nov 2007 10:23:23 -0800
Message-ID: <20071120182323.GH28611__12811.639373149$1195592413$gmane$org@kroah.com>
References: <20071120181733.702234406@mini.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Roland <devzero-S0/GAf8tV78@public.gmane.org>,
	Theodore Ts'o <tytso@mit.edu>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	Justin Forbes <jmforbes-a5Mqy2EUIFVAfugRpC6u6w@public.gmane.org>,
	Domenico Andreoli <cavokz@gmail.com>,
	Chris Wedgwood <reviews-vFB7bnJMxjixIvdkapsUdQ@public.gmane.org>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Michael Krufky <mkrufky-dJidKbW2IEtAfugRpC6u6w@public.gmane.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw-lrwSPXAIdEw7YuNMryXyOw@public.gmane.org>,
	akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
	Andreas Gruenbacher <agruen@suse.de>
To: linux-kernel@vger.kernel.org, stable@kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IuXnv-0005Zq-8e
	for nfs@lists.sourceforge.net; Tue, 20 Nov 2007 10:26:35 -0800
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IuXo0-0005r8-Mf
	for nfs@lists.sourceforge.net; Tue, 20 Nov 2007 10:26:41 -0800
In-Reply-To: <20071120182248.GA28611@kroah.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

2.6.23-stable review patch.  If anyone has any objections, please let us
know.

------------------
From: J. Bruce Fields <bfields@citi.umich.edu>

patch ac8587dcb58e40dd336d99d60f852041e06cc3dd in mainline.

The v2/v3 acl code in nfsd is translating any return from fh_verify() to
nfserr_inval.  This is particularly unfortunate in the case of an
nfserr_dropit return, which is an internal error meant to indicate to
callers that this request has been deferred and should just be dropped
pending the results of an upcall to mountd.

Thanks to Roland <devzero-S0/GAf8tV78@public.gmane.org> for bug report and data collection.

Cc: Roland <devzero-S0/GAf8tV78@public.gmane.org>
Acked-by: Andreas Gruenbacher <agruen@suse.de>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Reviewed-By: NeilBrown <neilb@suse.de>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 fs/nfsd/nfs2acl.c |    2 +-
 fs/nfsd/nfs3acl.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -41,7 +41,7 @@ static __be32 nfsacld_proc_getacl(struct
 
 	fh = fh_copy(&resp->fh, &argp->fh);
 	if ((nfserr = fh_verify(rqstp, &resp->fh, 0, MAY_NOP)))
-		RETURN_STATUS(nfserr_inval);
+		RETURN_STATUS(nfserr);
 
 	if (argp->mask & ~(NFS_ACL|NFS_ACLCNT|NFS_DFACL|NFS_DFACLCNT))
 		RETURN_STATUS(nfserr_inval);
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -37,7 +37,7 @@ static __be32 nfsd3_proc_getacl(struct s
 
 	fh = fh_copy(&resp->fh, &argp->fh);
 	if ((nfserr = fh_verify(rqstp, &resp->fh, 0, MAY_NOP)))
-		RETURN_STATUS(nfserr_inval);
+		RETURN_STATUS(nfserr);
 
 	if (argp->mask & ~(NFS_ACL|NFS_ACLCNT|NFS_DFACL|NFS_DFACLCNT))
 		RETURN_STATUS(nfserr_inval);

-- 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

