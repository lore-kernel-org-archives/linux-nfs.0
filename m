Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44365 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751862AbbEHI5U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 May 2015 04:57:20 -0400
From: NeilBrown <neilb@suse.de>
To: linux-raid@vger.kernel.org, Shaohua Li <shli@kernel.org>
Date: Fri, 08 May 2015 18:56:12 +1000
Subject: [PATCH 6/7] md/raid5: fix allocation of 'scribble' array.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20150508085611.19179.77495.stgit@notabene.brown>
In-Reply-To: <20150508085345.19179.8866.stgit@notabene.brown>
References: <20150508085345.19179.8866.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As the new 'scribble' array is sized based on chunk size,
we need to make sure the size matches the largest of 'old'
and 'new' chunk sizes when the array is undergoing reshape.

We also potentially need to resize it even when not resizing
the stripe cache, as chunk size can change without changing
number of devices.

So move the 'resize' code into a separate function, and
consider old and new sizes when allocating.

Signed-off-by: NeilBrown <neilb@suse.de>
Fixes: 46d5b785621a ("raid5: use flex_array for scribble data")
---
 drivers/md/raid5.c |   65 ++++++++++++++++++++++++++++++++++------------------
 1 file changed, 43 insertions(+), 22 deletions(-)

diff --git a/drivers/md/raid5.c b/drivers/md/raid5.c
index 9748e525e4c0..3873eaa6fa2e 100644
--- a/drivers/md/raid5.c
+++ b/drivers/md/raid5.c
@@ -2068,6 +2068,35 @@ static struct flex_array *scribble_alloc(int num, int cnt, gfp_t flags)
 	return ret;
 }
 
+static int resize_chunks(struct r5conf *conf, int new_disks, int new_sectors)
+{
+	unsigned long cpu;
+	int err = 0;
+
+	mddev_suspend(conf->mddev);
+	get_online_cpus();
+	for_each_present_cpu(cpu) {
+		struct raid5_percpu *percpu;
+		struct flex_array *scribble;
+
+		percpu = per_cpu_ptr(conf->percpu, cpu);
+		scribble = scribble_alloc(new_disks,
+					  new_sectors / STRIPE_SECTORS,
+					  GFP_NOIO);
+
+		if (scribble) {
+			flex_array_free(percpu->scribble);
+			percpu->scribble = scribble;
+		} else {
+			err = -ENOMEM;
+			break;
+		}
+	}
+	put_online_cpus();
+	mddev_resume(conf->mddev);
+	return err;
+}
+
 static int resize_stripes(struct r5conf *conf, int newsize)
 {
 	/* Make all the stripes able to hold 'newsize' devices.
@@ -2096,7 +2125,6 @@ static int resize_stripes(struct r5conf *conf, int newsize)
 	struct stripe_head *osh, *nsh;
 	LIST_HEAD(newstripes);
 	struct disk_info *ndisks;
-	unsigned long cpu;
 	int err;
 	struct kmem_cache *sc;
 	int i;
@@ -2178,25 +2206,6 @@ static int resize_stripes(struct r5conf *conf, int newsize)
 	} else
 		err = -ENOMEM;
 
-	get_online_cpus();
-	for_each_present_cpu(cpu) {
-		struct raid5_percpu *percpu;
-		struct flex_array *scribble;
-
-		percpu = per_cpu_ptr(conf->percpu, cpu);
-		scribble = scribble_alloc(newsize, conf->chunk_sectors /
-			STRIPE_SECTORS, GFP_NOIO);
-
-		if (scribble) {
-			flex_array_free(percpu->scribble);
-			percpu->scribble = scribble;
-		} else {
-			err = -ENOMEM;
-			break;
-		}
-	}
-	put_online_cpus();
-
 	/* Step 4, return new stripes to service */
 	while(!list_empty(&newstripes)) {
 		nsh = list_entry(newstripes.next, struct stripe_head, lru);
@@ -6228,8 +6237,11 @@ static int alloc_scratch_buffer(struct r5conf *conf, struct raid5_percpu *percpu
 		percpu->spare_page = alloc_page(GFP_KERNEL);
 	if (!percpu->scribble)
 		percpu->scribble = scribble_alloc(max(conf->raid_disks,
-			conf->previous_raid_disks), conf->chunk_sectors /
-			STRIPE_SECTORS, GFP_KERNEL);
+						      conf->previous_raid_disks),
+						  max(conf->chunk_sectors,
+						      conf->prev_chunk_sectors)
+						   / STRIPE_SECTORS,
+						  GFP_KERNEL);
 
 	if (!percpu->scribble || (conf->level == 6 && !percpu->spare_page)) {
 		free_scratch_buffer(conf, percpu);
@@ -7205,6 +7217,15 @@ static int check_reshape(struct mddev *mddev)
 	if (!check_stripe_cache(mddev))
 		return -ENOSPC;
 
+	if (mddev->new_chunk_sectors > mddev->chunk_sectors ||
+	    mddev->delta_disks > 0)
+		if (resize_chunks(conf,
+				  conf->previous_raid_disks
+				  + max(0, mddev->delta_disks),
+				  max(mddev->new_chunk_sectors,
+				      mddev->chunk_sectors)
+			    ) < 0)
+			return -ENOMEM;
 	return resize_stripes(conf, (conf->previous_raid_disks
 				     + mddev->delta_disks));
 }


