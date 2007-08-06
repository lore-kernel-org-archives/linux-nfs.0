From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: 2.6.23-rc1-mm2
Date: Mon, 06 Aug 2007 08:24:56 +0200
Message-ID: <1186381496.21957.30.camel@johannes.berg>
References: <20070731230932.a9459617.akpm@linux-foundation.org>
	<200708031301.01569.marc.dietrich@ap.physik.uni-giessen.de>
	<20070803093830.39852a01.akpm@linux-foundation.org>
	<1186160608.7255.10.camel@localhost> <20070803172137.GA3783@tv-sign.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1591494154=="
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Neil Brown <neilb@suse.de>, linux-kernel@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net, Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>,
	Marc Dietrich <Marc.Dietrich@ap.physik.uni-giessen.de>
To: Oleg Nesterov <oleg@tv-sign.ru>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IHxcr-0005yh-0X
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 01:07:41 -0700
Received: from crystal.sipsolutions.net
	([195.210.38.204] helo=sipsolutions.net ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IHxct-0003ZC-Gz
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 01:07:45 -0700
In-Reply-To: <20070803172137.GA3783@tv-sign.ru>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


--===============1591494154==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-1nm6AYDMdTxXkn7pmFze"


--=-1nm6AYDMdTxXkn7pmFze
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-08-03 at 21:21 +0400, Oleg Nesterov wrote:

> To avoid a possible confusion: it is still OK if work->func() flushes
> its own workqueue, so strictly speaking this trace is false positive,
> but it would be very nice if we can get rid of this practice.

I just had a thought: we could get rid of this warning by using a
read-lock here. That way, flushing from within a work function (which
would be seen as read-after-read recursive lock) won't trigger this
warning. Patch below. This would, however, also get rid of any warnings
for run_workqueue recursion. Which again we may or may not want, the
code inidicates that it should be allowed up to a depth of three.

However, the question whether we should allow flush_workqueue from
within a struct work is mainly an API policy issue; it doesn't hurt to
flush a workqueue from within a work, but it is probably nearer the
intent to use targeted cancel_work_sync() or such. OTOH, one could
imagine situations where multiple different work structs are on that
workqueue belonging to the same subsystem and then the general
flush_scheduled_work() call is the only way to guarantee nothing is on
scheduled at a given point... I don't feel qualified to make the
decision for or against allowing this use of the API at this point.

Marc, do you have an easy way to trigger this warning? Could you verify
that it goes away with the patch below applied?

johannes

---
 kernel/workqueue.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- wireless-dev.orig/kernel/workqueue.c	2007-08-06 08:11:23.297846657 +020=
0
+++ wireless-dev/kernel/workqueue.c	2007-08-06 08:19:54.727846657 +0200
@@ -272,7 +272,7 @@ static void run_workqueue(struct cpu_wor
=20
 		BUG_ON(get_wq_data(work) !=3D cwq);
 		work_clear_pending(work);
-		lock_acquire(&cwq->wq->lockdep_map, 0, 0, 0, 2, _THIS_IP_);
+		lock_acquire(&cwq->wq->lockdep_map, 0, 0, 1, 2, _THIS_IP_);
 		lock_acquire(&lockdep_map, 0, 0, 0, 2, _THIS_IP_);
 		f(work);
 		lock_release(&lockdep_map, 1, _THIS_IP_);
@@ -395,7 +395,7 @@ void fastcall flush_workqueue(struct wor
 	int cpu;
=20
 	might_sleep();
-	lock_acquire(&wq->lockdep_map, 0, 0, 0, 2, _THIS_IP_);
+	lock_acquire(&wq->lockdep_map, 0, 0, 1, 2, _THIS_IP_);
 	lock_release(&wq->lockdep_map, 1, _THIS_IP_);
 	for_each_cpu_mask(cpu, *cpu_map)
 		flush_cpu_workqueue(per_cpu_ptr(wq->cpu_wq, cpu));
@@ -779,7 +779,7 @@ static void cleanup_workqueue_thread(str
 	if (cwq->thread =3D=3D NULL)
 		return;
=20
-	lock_acquire(&cwq->wq->lockdep_map, 0, 0, 0, 2, _THIS_IP_);
+	lock_acquire(&cwq->wq->lockdep_map, 0, 0, 1, 2, _THIS_IP_);
 	lock_release(&cwq->wq->lockdep_map, 1, _THIS_IP_);
=20
 	flush_cpu_workqueue(cwq);


--=-1nm6AYDMdTxXkn7pmFze
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGtr64/ETPhpq3jKURAv06AJ45NY35aGJ//zmZaeKuIjLUgBATrwCeI3IF
2nwaF8W7kXaqbjDO311EsSk=
=H0ai
-----END PGP SIGNATURE-----

--=-1nm6AYDMdTxXkn7pmFze--



--===============1591494154==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--===============1591494154==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1591494154==--
