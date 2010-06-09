From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 1/3] nfsd: don't try to shut down nfs4 state handling
 unless it's up
Date: Wed, 9 Jun 2010 14:29:43 -0400
Message-ID: <20100609142943.60d31a11@tlielax.poochiereds.net>
References: <1275924800-5214-1-git-send-email-jlayton@redhat.com>
	<1275924800-5214-2-git-send-email-jlayton@redhat.com>
	<20100608235828.GK26435@fieldses.org>
	<20100609062922.4bae21ac@corrin.poochiereds.net>
	<20100609180907.GB10953@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49918 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758105Ab0FIS3q convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jun 2010 14:29:46 -0400
In-Reply-To: <20100609180907.GB10953@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 9 Jun 2010 14:09:07 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Jun 09, 2010 at 06:29:22AM -0400, Jeff Layton wrote:
> > On Tue, 8 Jun 2010 19:58:28 -0400
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > On Mon, Jun 07, 2010 at 11:33:18AM -0400, Jeff Layton wrote:
> > > > If someone tries to shut down the laundry_wq while it isn't up it'll
> > > > cause an oops.
> > > 
> > > OK, thanks.
> > > 
> > > Hm: what about the opposite (admittedly probably less crucial) problem:
> > > are there cases where nfs4_state_start() gets called but never
> > > nfs4_state_shutdown?
> > > 
> > > From a quick look, I don't see what prevents that.
> > > 
> > > --b.
> > > 
> > 
> > I don't see that problem. nfs4_state_shutdown gets called when the
> > nfsd_serv is torn down, and it only gets brought up in nfsd_svc,
> 
> If nfs4_state_start() succeeds, then nfsd_create_server() is called.  It calls
> svc_create_pooled(), which is passed nfsd_last_thread() as a parameter.
> 
> If svc_create_pooled succeeds, then I think we're guaranteed nfsd_last_thread()
> will get called eventually.
> 
> But if svc_create_pooled fails, I don't think nfsd_last_thread() is ever
> called.
> 

Ahh ok, I see what you're talking about now. Yeah, that should probably
also be fixed. I think we just need to ensure to shut down the state in
an error condition. Something like this compile-tested only patch?

>From 19bd25ea9a76ea184e4c30831765e812ce19b0a5 Mon Sep 17 00:00:00 2001
From: Jeff Layton <jlayton@redhat.com>
Date: Wed, 9 Jun 2010 14:21:51 -0400
Subject: [PATCH] nfsd: shut down NFSv4 state when nfsd_svc encounters an error

Currently, it's left up in some situations. That could cause the grace
period to be shorter than it should be (along with other problems).

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfssvc.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 06b2a26..a06ea99 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -402,9 +402,9 @@ nfsd_svc(unsigned short port, int nrservs)
 	nfsd_reset_versions();
 
 	error = nfsd_create_serv();
-
 	if (error)
-		goto out;
+		goto shutdown_state;
+
 	error = nfsd_init_socks(port);
 	if (error)
 		goto failure;
@@ -416,9 +416,12 @@ nfsd_svc(unsigned short port, int nrservs)
 		 * so subtract 1
 		 */
 		error = nfsd_serv->sv_nrthreads - 1;
- failure:
+failure:
 	svc_destroy(nfsd_serv);		/* Release server */
- out:
+shutdown_state:
+	if (error < 0)
+		nfs4_state_shutdown();
+out:
 	mutex_unlock(&nfsd_mutex);
 	return error;
 }
-- 
1.5.5.6

