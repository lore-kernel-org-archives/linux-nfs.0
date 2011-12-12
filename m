Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46162 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752147Ab1LLWk0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Dec 2011 17:40:26 -0500
Date: Mon, 12 Dec 2011 17:40:25 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Benny Halevy <bhalevy@tonian.com>
Cc: Tigran Mkrtchyan <kofemann@googlemail.com>, linux-nfs@vger.kernel.org,
        Tigran Mkrtchyan <kofemann@gmail.com>
Subject: Re: [PATCH] nfsd41: handle current stateid in open and close
Message-ID: <20111212224025.GB22927@fieldses.org>
References: <1323207847-19118-1-git-send-email-tigran.mkrtchyan@desy.de>
 <20111206230823.GH12640@fieldses.org>
 <4EDF677C.7030209@tonian.com>
 <20111207171133.GD20079@fieldses.org>
 <4EE0E123.20401@tonian.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EE0E123.20401@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 08, 2011 at 06:09:07PM +0200, Benny Halevy wrote:
> On 2011-12-07 19:11, J. Bruce Fields wrote:
> > On Wed, Dec 07, 2011 at 03:17:48PM +0200, Benny Halevy wrote:
> >> On 2011-12-07 01:08, J. Bruce Fields wrote:
> >>> It's a little verbose, but yes it does nicely collect the current
> >>> stateid getting/setting into one place.  Benny, is the more or less what
> >>> you were thinking of?
> >>
> >> Yes it is, though I also liked your direction of just using the current
> >> stateid for xdr decoding and encoding.
> > 
> > I'd still have a slight preference for doing it that way, just because
> > it would take fewer lines of code--but I can live with this too, so I'll
> > leave the choice to Tigran's excellent taste....
> > 
> >> { ~0, { { ~0, ~0 }, ~0 } } is ugly but compact :)
> >>
> >> And the following may be an overkill...
> >> {
> >> 	.si_generation = ~0,
> >> 	.si_opaque = {
> >> 		.so_clid = {
> >> 			.cl_boot = ~0,
> >> 			.cl_id = ~0,
> >> 		},
> >> 		.so_id = ~0
> >> 	}
> >> };
> > 
> > Reminding myself of http://tools.ietf.org/html/rfc5661#section-8.2.3...
> > "Stateid values whose "other" field is either all zeros or all ones are
> > reserved."
> > 
> > Maybe:
> > 
> > #define all_ones   {{~0,~0 },~0}
> > #define all_zeroes {{ 0, 0 }, 0}
> > const stateid_t one_stateid = {
> > 	.si_generation = ~0,
> > 	.si_opaque = all_ones
> > };
> 
> That looks like a good compromise to me.
> 
> > const stateid_t current_stateid = {
> > 	.si_generation = 1,
> > 	.si_opaque = all_zeroes
> > };
> > ...
> > 
> > Or you could ditch the all_zeroes; it's just there for some kind of
> > symmetry.
> 
> Yeah, static initialization to zero is guaranteed.

OK, applying the following assuming no objections.--b.

commit f32f3c2d3f09a586349ca9180885dc8741290fd9
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Dec 12 15:00:35 2011 -0500

    nfsd4: initialize special stateid's at compile time
    
    Stateid's with "other" ("opaque") field all zeros or all ones are
    reserved.  We define all_ones separately on the off chance there will be
    more such some day, though currently all the other special stateid's
    have zero other field.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6ab6779..213da7b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -49,12 +49,20 @@
 time_t nfsd4_lease = 90;     /* default lease time */
 time_t nfsd4_grace = 90;
 static time_t boot_time;
-static stateid_t zerostateid;             /* bits all 0 */
-static stateid_t onestateid;              /* bits all 1 */
+
+#define all_ones {{~0,~0},~0}
+static const stateid_t one_stateid = {
+	.si_generation = ~0,
+	.si_opaque = all_ones,
+};
+static const stateid_t zero_stateid = {
+	/* all fields zero */
+};
+
 static u64 current_sessionid = 1;
 
-#define ZERO_STATEID(stateid) (!memcmp((stateid), &zerostateid, sizeof(stateid_t)))
-#define ONE_STATEID(stateid)  (!memcmp((stateid), &onestateid, sizeof(stateid_t)))
+#define ZERO_STATEID(stateid) (!memcmp((stateid), &zero_stateid, sizeof(stateid_t)))
+#define ONE_STATEID(stateid)  (!memcmp((stateid), &one_stateid, sizeof(stateid_t)))
 
 /* forward declarations */
 static int check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner);
@@ -4564,7 +4572,6 @@ nfs4_state_init(void)
 	}
 	for (i = 0; i < LOCKOWNER_INO_HASH_SIZE; i++)
 		INIT_LIST_HEAD(&lockowner_ino_hashtbl[i]);
-	memset(&onestateid, ~0, sizeof(stateid_t));
 	INIT_LIST_HEAD(&close_lru);
 	INIT_LIST_HEAD(&client_lru);
 	INIT_LIST_HEAD(&del_recall_lru);
