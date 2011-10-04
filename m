Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:52150 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756019Ab1JDKd3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Oct 2011 06:33:29 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>, Brent Welch <welch@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCH 10/19] ore: Support for partial component table
Date: Tue, 4 Oct 2011 12:33:19 +0200
Message-ID: <1317724399-27608-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4E8ADEDA.4050709@panasas.com>
References: <4E8ADEDA.4050709@panasas.com>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Users like the objlayout-driver would like to only pass
a partial device table that covers the IO in question.
For example exofs divides the file into raid-group-sized
chunks and only serves group_width number of devices at
a time.

The partiality is communicated by setting
ore_componets->first_dev and the array covers all logical
devices from oc->first_dev upto (oc->first_dev + oc->numdevs)

The ore_comp_dev() API receives a logical device index
and returns the actual present device in the table.
An out-of-range dev_index will BUG.

Logical device index is the theoretical device index as if
all the devices of a file are present. .i.e:
	total_devs = group_width * mirror_p1 * group_count
	0 <= dev_index < total_devs

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/exofs.h       |    1 +
 fs/exofs/ore.c         |    4 ++++
 include/scsi/osd_ore.h |    7 ++++---
 3 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/exofs/exofs.h b/fs/exofs/exofs.h
index 006fd6f..51f4b4c 100644
--- a/fs/exofs/exofs.h
+++ b/fs/exofs/exofs.h
@@ -217,6 +217,7 @@ static inline void exofs_init_comps(struct ore_components *oc,
 	one_comp->obj.id = oid;
 	exofs_make_credential(one_comp->cred, &one_comp->obj);
 
+	oc->first_dev = 0;
 	oc->numdevs = sbi->layout.group_width * sbi->layout.mirrors_p1 *
 							sbi->layout.group_count;
 	oc->single_comp = EC_SINGLE_COMP;
diff --git a/fs/exofs/ore.c b/fs/exofs/ore.c
index 0b992e1..7913168 100644
--- a/fs/exofs/ore.c
+++ b/fs/exofs/ore.c
@@ -62,6 +62,10 @@ static struct osd_obj_id *_ios_obj(struct ore_io_state *ios, unsigned index)
 
 static struct osd_dev *_ios_od(struct ore_io_state *ios, unsigned index)
 {
+	ORE_DBGMSG2("oc->first_dev=%d oc->numdevs=%d i=%d oc->ods=%p\n",
+		    ios->oc->first_dev, ios->oc->numdevs, index,
+		    ios->oc->ods);
+
 	return ore_comp_dev(ios->oc, index);
 }
 
diff --git a/include/scsi/osd_ore.h b/include/scsi/osd_ore.h
index baeef02..492b70d 100644
--- a/include/scsi/osd_ore.h
+++ b/include/scsi/osd_ore.h
@@ -49,6 +49,7 @@ struct ore_dev {
 };
 
 struct ore_components {
+	unsigned	first_dev;		/* First logical device no    */
 	unsigned	numdevs;		/* Num of devices in array    */
 	/* If @single_comp == EC_SINGLE_COMP, @comps points to a single
 	 * component. else there are @numdevs components
@@ -70,14 +71,14 @@ struct ore_components {
 static inline struct osd_dev *ore_comp_dev(
 	const struct ore_components *oc, unsigned i)
 {
-	BUG_ON(oc->numdevs <= i);
-	return oc->ods[i]->od;
+	BUG_ON((i < oc->first_dev) || (oc->first_dev + oc->numdevs <= i));
+	return oc->ods[i - oc->first_dev]->od;
 }
 
 static inline void ore_comp_set_dev(
 	struct ore_components *oc, unsigned i, struct osd_dev *od)
 {
-	oc->ods[i]->od = od;
+	oc->ods[i - oc->first_dev]->od = od;
 }
 
 struct ore_striping_info {
-- 
1.7.2.3

