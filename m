Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55907 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751368Ab3EUUZm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 May 2013 16:25:42 -0400
Date: Tue, 21 May 2013 16:25:41 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <steved@redhat.com>
Cc: Bruce Fields <bfields@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD: Don't give out read delegations on exclusive
 creates
Message-ID: <20130521202541.GA13725@fieldses.org>
References: <1368643909-8059-1-git-send-email-steved@redhat.com>
 <20130521192338.GC12114@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130521192338.GC12114@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 21, 2013 at 03:23:38PM -0400, bfields wrote:
> On Wed, May 15, 2013 at 02:51:49PM -0400, Steve Dickson wrote:
> > When an exclusive create is done with the mode bits
> > set (aka open(testfile, O_CREAT | O_EXCL, 0777)) this
> 
> so implicitly O_RDONLY.  Is that common?  Maybe so, OK.
> 
> > causes a OPEN op followed by a SETATTR op. When a
> > read delegation is given in the OPEN, it causes
> > the SETATTR to delay with EAGAIN until the
> > delegation is recalled.
> > 
> > This patch caused exclusive creates to give out
> > a write delegation (which turn into no delegation)
> > which allows the SETATTR seamlessly succeed.
> 
> OK.  May as well make it apply to all creates, though, I think?
> Any create flag seems like a sign the file's likely to be modified soon,
> hence isn't a good candidate for a read delegation.

That would look like the following.

--b.

commit 3f47b6220ca6b08a7ab86baaaab87389707a3308
Author: Steve Dickson <steved@redhat.com>
Date:   Wed May 15 14:51:49 2013 -0400

    NFSD: Don't give out read delegations on exclusive creates
    
    When an exclusive create is done with the mode bits
    set (aka open(testfile, O_CREAT | O_EXCL, 0777)) this
    causes a OPEN op followed by a SETATTR op. When a
    read delegation is given in the OPEN, it causes
    the SETATTR to delay with EAGAIN until the
    delegation is recalled.
    
    This patch caused exclusive creates to give out
    a write delegation (which turn into no delegation)
    which allows the SETATTR seamlessly succeed.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>
    [bfields: do this for any CREATE, not just exclusive; comment]
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c4f6339..44dcea9 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3113,8 +3113,17 @@ nfs4_open_delegation(struct net *net, struct svc_fh *fh,
 				goto out;
 			if (!cb_up || !(oo->oo_flags & NFS4_OO_CONFIRMED))
 				goto out;
+			/*
+			 * Also, if the file was opened for write or
+			 * create, there's a good chance the client's
+			 * about to write to it, resulting in an
+			 * immediate recall (since we don't support
+			 * write delegations):
+			 */
 			if (open->op_share_access & NFS4_SHARE_ACCESS_WRITE)
 				flag = NFS4_OPEN_DELEGATE_WRITE;
+			else if (open->op_create == NFS4_OPEN_CREATE)
+				flag = NFS4_OPEN_DELEGATE_WRITE;
 			else
 				flag = NFS4_OPEN_DELEGATE_READ;
 			break;
