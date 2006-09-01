From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 004 of 19] knfsd: lockd: introduce nsm_handle
Date: Sat, 2 Sep 2006 09:50:00 +1000
Message-ID: <17656.50984.845357.143322@cse.unsw.edu.au>
References: <20060901141639.27206.patches@notabene>
	<1060901043825.27464@suse.de>
	<20060831232029.b003e8a7.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GJIm4-0006wC-8p
	for nfs@lists.sourceforge.net; Fri, 01 Sep 2006 16:50:13 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GJIm3-0003v5-GU
	for nfs@lists.sourceforge.net; Fri, 01 Sep 2006 16:50:13 -0700
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: message from Andrew Morton on Thursday August 31
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thursday August 31, akpm@osdl.org wrote:
> On Fri, 1 Sep 2006 14:38:25 +1000
> NeilBrown <neilb@suse.de> wrote:
> 
> > +nsm_release(struct nsm_handle *nsm)
> > +{
> > +	if (!nsm)
> > +		return;
> > +	if (atomic_read(&nsm->sm_count) == 1) {
> > +		down(&nsm_sema);
> > +		if (atomic_dec_and_test(&nsm->sm_count)) {
> > +			list_del(&nsm->sm_link);
> > +			kfree(nsm);
> > +		}
> > +		up(&nsm_sema);
> > +	}
> > +}
> 
> That's weird-looking.  Are you sure?  afaict, if ->sm_count ever gets a
> value of 2 or more, it's unfreeable.  

How do you *do* that?  I thought I had already found the bugs...

Thanks :-)
NeilBrown


---
Subject: Fix locking in nsm_release

The locking is all backwards and broken.

We first atomic_dec_and_test.
If this fails, someone else has an active reference and we need do
no more.
If it succeeds, then the only ref is in the hash table, but someone
might be about to find and use that reference.  nsm_mutex provides
exclusion against this.  If sm_count is still 0 once the
mutex has been gained, then it is safe to discard the nsm.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/lockd/host.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff .prev/fs/lockd/host.c ./fs/lockd/host.c
--- .prev/fs/lockd/host.c	2006-09-01 18:56:39.000000000 +1000
+++ ./fs/lockd/host.c	2006-09-02 09:44:04.000000000 +1000
@@ -507,9 +507,9 @@ nsm_release(struct nsm_handle *nsm)
 {
 	if (!nsm)
 		return;
-	if (atomic_read(&nsm->sm_count) == 1) {
+	if (atomic_dec_and_test(&nsm->sm_count)) {
 		mutex_lock(&nsm_mutex);
-		if (atomic_dec_and_test(&nsm->sm_count)) {
+		if (atomic_read(&nsm->sm_count) == 0) {
 			list_del(&nsm->sm_link);
 			kfree(nsm);
 		}

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
