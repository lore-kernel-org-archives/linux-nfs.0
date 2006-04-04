From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] Re: [PATCH 011 of 16] knfsd: svcrpc: WARN() instead of returning an error from svc_take_page
Date: Mon, 3 Apr 2006 22:26:13 -0400
Message-ID: <20060404022613.GB6365@fieldses.org>
References: <20060403151452.1567.patches@notabene> <1060403051901.1857@suse.de> <200604040002.22544.ioe-lkml@rameria.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NeilBrown <neilb@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964966AbWDDC0U@vger.kernel.org>
To: Ingo Oeser <ioe-lkml@rameria.de>
In-Reply-To: <200604040002.22544.ioe-lkml@rameria.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, Apr 04, 2006 at 12:02:21AM +0200, Ingo Oeser wrote:
> On Monday, 3. April 2006 07:19, you wrote:
> > diff ./include/linux/sunrpc/svc.h~current~ ./include/linux/sunrpc/svc.h
> > --- ./include/linux/sunrpc/svc.h~current~	2006-04-03 15:12:15.000000000 +1000
> > +++ ./include/linux/sunrpc/svc.h	2006-04-03 15:12:15.000000000 +1000
> > @@ -197,15 +197,13 @@ svc_take_res_page(struct svc_rqst *rqstp
> >  	return rqstp->rq_respages[rqstp->rq_resused++];
> >  }
> >  
> > -static inline int svc_take_page(struct svc_rqst *rqstp)
> > +static inline void svc_take_page(struct svc_rqst *rqstp)
> >  {
> > -	if (rqstp->rq_arghi <= rqstp->rq_argused)
> > -		return -ENOMEM;
> > +	WARN_ON(rqstp->rq_arghi <= rqstp->rq_argused);
> >  	rqstp->rq_arghi--;
> >  	rqstp->rq_respages[rqstp->rq_resused] =
> >  		rqstp->rq_argpages[rqstp->rq_arghi];
> >  	rqstp->rq_resused++;
> > -	return 0;
> >  }
> 
> What will prevent underflow of ->rq_arghi and overflow of ->rq_resused here?
> 
> Before that change, this code would return without 
> modifying both members here on error.
> 
> Now this code makes the error worse with each call.
> 
> Just ignore me, if this is ok :-)

No, you're right, apologies.  The results could be worse than if we'd
just BUG()'d there.

So we should probably either just bite the bullet and make that a BUG(),
or add back the return.  The latter option appended in the form of a
replacement patch....

--b.

svcrpc: WARN() instead of returning an error from svc_take_page

Every caller of svc_take_page ignores its return value and assumes it
succeeded.  So just WARN() instead of returning an ignored error.  This
would have saved some time debugging a recent nfsd4 problem.

If there are still failure cases here, then the result is probably that we
overwrite an earlier part of the reply while xdr-encoding.

While the corrupted reply is a nasty bug, it would be worse to panic here
and create the possibility of a remote DOS; hence WARN() instead of BUG().

Thanks to Ingo Oeser for noticing a bug in an earlier version of this
patch.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---

 include/linux/sunrpc/svc.h |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 50cab2a..5035643 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -197,15 +197,16 @@ svc_take_res_page(struct svc_rqst *rqstp
 	return rqstp->rq_respages[rqstp->rq_resused++];
 }
 
-static inline int svc_take_page(struct svc_rqst *rqstp)
+static inline void svc_take_page(struct svc_rqst *rqstp)
 {
-	if (rqstp->rq_arghi <= rqstp->rq_argused)
-		return -ENOMEM;
+	if (rqstp->rq_arghi <= rqstp->rq_argused) {
+		WARN_ON(1);
+		return;
+	}
 	rqstp->rq_arghi--;
 	rqstp->rq_respages[rqstp->rq_resused] =
 		rqstp->rq_argpages[rqstp->rq_arghi];
 	rqstp->rq_resused++;
-	return 0;
 }
 
 static inline void svc_pushback_allpages(struct svc_rqst *rqstp)
