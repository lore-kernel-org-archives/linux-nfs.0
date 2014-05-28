Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43343 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753019AbaE1VJF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 May 2014 17:09:05 -0400
Date: Wed, 28 May 2014 17:08:59 -0400
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 41/52] nfsd4: turn off zero-copy-read in exotic cases
Message-ID: <20140528210858.GF22210@fieldses.org>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
 <1400787148-25941-42-git-send-email-bfields@redhat.com>
 <20140528080945.GA6797@infradead.org>
 <20140528140151.GB13012@pad.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140528140151.GB13012@pad.redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 28, 2014 at 10:01:52AM -0400, J. Bruce Fields wrote:
> On Wed, May 28, 2014 at 01:09:45AM -0700, Christoph Hellwig wrote:
> > On Thu, May 22, 2014 at 03:32:16PM -0400, J. Bruce Fields wrote:
> > > Later patches handle those "exotic compounds", this one just makes sure
> > > zero-copy is turned off in those cases.
> > 
> > How did you test these exotic compounds?
> 
> I have is a pynfs test that sends a compound with multiple reads in it.

But, look, it wasn't turned on in my regular tests so, surprise, I
regressed recently without noticing; I intend to fold in the below after
some more testing.

> I don't think that's pushed out to my regular pynfs tree, I'll try to do
> that today.

Still working on that.

--b.

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 3f8bfb9..3976dc6 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3197,12 +3197,10 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 		WARN_ON_ONCE(resp->rqstp->rq_splice_ok);
 		return nfserr_resource;
 	}
-
-	if (resp->xdr.buf->page_len) {
-		WARN_ON_ONCE(resp->rqstp->rq_splice_ok);
+	if (resp->xdr.buf->page_len && resp->rqstp->rq_splice_ok) {
+		WARN_ON_ONCE(1);
 		return nfserr_resource;
 	}
-
 	xdr_commit_encode(xdr);
 
 	maxcount = svc_max_payload(resp->rqstp);
