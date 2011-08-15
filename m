Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34507 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751985Ab1HOVZm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Aug 2011 17:25:42 -0400
Date: Mon, 15 Aug 2011 17:25:39 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com, nfsv4@ietf.org
Subject: Re: open() of device special files
Message-ID: <20110815212539.GA32181@fieldses.org>
References: <20110815153637.GD28629@fieldses.org>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AA9B9FB@SACMVEXC2-PRD.hq.netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AA9B9FB@SACMVEXC2-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Aug 15, 2011 at 09:03:30AM -0700, Myklebust, Trond wrote:
> > -----Original Message-----
> > From: J. Bruce Fields [mailto:bfields@fieldses.org]
> > How is the client supposed to handle opens of device special files?
> On
> > a 3.1-rc1-based client to a linux server over v4.0 I'm seeing it try
> an
> > OPEN call and failing when it gets an INVAL return.
> > 
> > This looks like bogus client behavior (OPEN should fail on such
> files),
> > unless the server has the error return wrong and the client's using an
> > OPEN error to recover.
> > 
> > If I first stat the device and then open it then it works as expected
> > (the client does an open of the local device).
> > 
> > I'm a bit annoyed at myself as I have a feeling we've discussed this
> > before but I can't find a reference now.
> 
> Hmm... NFS4ERR_INVAL means 'invalid argument', which is not the case
> here; all the arguments that the client is passing to the server are
> valid, however the file cannot be opened because the pathname resolves
> on the server to a file of the wrong type.
> 
> I can't see any other error definition that is "obviously correct", but
> it looks to me as if NFS4ERR_SYMLINK might be the closest thing. One
> reason is the dot-x file defines NFS4ERR_SYMLINK as meaning "should be
> file/directory". The other reason is that NFS4ERR_SYMLINK should
> _always_ trigger the correct behaviour on a client: a fresh lookup of
> the component.

Confirmed the fix; I'll apply.

But that's tricky--we should be document it for other server
implementers if it's the right thing to do (working group list cc'd).

--b.

commit 3d83c016da8652f30dcac372772b67d68f33bfbd
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Aug 15 16:55:02 2011 -0400

    nfsd4: return nfserr_symlink on v4 OPEN of non-regular file
    
    Without this, an attempt to open a device special file without first
    stat'ing it will fail.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 90c6aa6..cc8eb8d 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -69,6 +69,17 @@ nfsd_mode_check(struct svc_rqst *rqstp, umode_t mode, int type)
 			return nfserr_notdir;
 		else if ((mode & S_IFMT) == S_IFDIR)
 			return nfserr_isdir;
+		/*
+		 * err_symlink is our catch-all error in the v4 case; this
+		 * looks odd, but:
+		 *	- the comment next to ERR_SYMLINK in file is
+		 *	  "should be file/directory"
+		 *	- we happen to know this will cause the linux v4
+		 *	  client to do the right thing on attempts to open
+		 *	  something other than a regular file:
+		 */
+		else if (rqstp->rq_vers == 4)
+			return nfserr_symlink;
 		else
 			return nfserr_inval;
 	}
