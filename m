From: Neil Brown <neilb@suse.de>
Subject: Re: mountd randomly crash and panic the server
Date: Tue, 1 May 2007 09:59:46 +1000
Message-ID: <17974.33522.70308.585198@notabene.brown>
References: <461CFABE.9050301@barazer.net> <46234130.5020502@oxeva.fr>
	<17955.21572.383131.837268@notabene.brown>
	<4623830D.7040108@oxeva.fr>
	<17956.8604.672536.126674@notabene.brown>
	<46367FBC.6000007@oxeva.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Gabriel Barazer <gabriel@oxeva.fr>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hifmq-0002AQ-QI
	for nfs@lists.sourceforge.net; Mon, 30 Apr 2007 17:00:09 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hifmr-0001Ta-Qf
	for nfs@lists.sourceforge.net; Mon, 30 Apr 2007 17:00:11 -0700
In-Reply-To: message from Gabriel Barazer on Tuesday May 1
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

On Tuesday May 1, gabriel@oxeva.fr wrote:
> On 04/17/2007 3:23:40 +0200, Neil Brown <neilb@suse.de> wrote:
> 
> > 
> > I did end up just hunting through the patches between 2.6.18 and
> > 2.6.20 and I think I have found it (I had already looked at the code
> > where the bug is, but didn't see it the first time :-().
> > 
> > Could you try this patch and report the results please?
> > I'm very confident that the patch is correct and required, but I would
> > like to also know that it fixes your problem.
> > 
> 
> By the way, I patched the 2.6.20.7 kernel since you provided the patch, 
> and haven't encountered any stability problem, except some CFQ scheduler 

Cool, thanks for the report.

>   related kernel panics, which are, I suppose, not linked to the NFS 
> problem (I still mention it because unrelated but linked problems like 
> this sometimes happens)

CFQ panics ?  In cfq_dispatch_insert by any chance?

This patch from Jens Axboe might be what you need.

NeilBrown

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 9e37971..f965be7 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -532,6 +532,11 @@ static void cfq_add_rq_rb(struct request *rq)
 
 	if (!cfq_cfqq_on_rr(cfqq))
 		cfq_add_cfqq_rr(cfqd, cfqq);
+
+	/*
+	 * check if this request is a better next-serve candidate
+	 */
+	cfqq->next_rq = cfq_choose_req(cfqd, cfqq->next_rq, rq);
 }
 
 static inline void
@@ -1639,12 +1644,6 @@ cfq_rq_enqueued(struct cfq_data *cfqd, struct cfq_queue *cfqq,
 		cfqq->meta_pending++;
 
 	/*
-	 * check if this request is a better next-serve candidate)) {
-	 */
-	cfqq->next_rq = cfq_choose_req(cfqd, cfqq->next_rq, rq);
-	BUG_ON(!cfqq->next_rq);
-
-	/*
 	 * we never wait for an async request and we don't allow preemption
 	 * of an async request. so just return early
 	 */


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
