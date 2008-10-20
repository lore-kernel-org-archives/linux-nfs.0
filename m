From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 1/4] nfsd: Minor cleanup of find_stateid
Date: Mon, 20 Oct 2008 11:44:28 +0530
Message-ID: <20081020061428.17722.68145.sendpatchset@localhost.localdomain>
Cc: Krishna Kumar <krkumar2@in.ibm.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:41636 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976AbYJTGOc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Oct 2008 02:14:32 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e38.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id m9K6DrBx031592
	for <linux-nfs@vger.kernel.org>; Mon, 20 Oct 2008 00:13:53 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9K6EVUs100870
	for <linux-nfs@vger.kernel.org>; Mon, 20 Oct 2008 00:14:31 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9K6EUM4027921
	for <linux-nfs@vger.kernel.org>; Mon, 20 Oct 2008 00:14:30 -0600
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

Minor cleanup/rewrite of find_stateid. Compile tested.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 fs/nfsd/nfs4state.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff -ruNp linux-2.6.27.org/fs/nfsd/nfs4state.c linux-2.6.27.new/fs/nfsd/nfs4state.c
--- linux-2.6.27.org/fs/nfsd/nfs4state.c	2008-10-20 10:47:23.000000000 +0530
+++ linux-2.6.27.new/fs/nfsd/nfs4state.c	2008-10-20 10:48:29.000000000 +0530
@@ -2421,13 +2421,13 @@ static struct list_head lockstateid_hash
 static struct nfs4_stateid *
 find_stateid(stateid_t *stid, int flags)
 {
-	struct nfs4_stateid *local = NULL;
+	struct nfs4_stateid *local;
 	u32 st_id = stid->si_stateownerid;
 	u32 f_id = stid->si_fileid;
 	unsigned int hashval;
 
 	dprintk("NFSD: find_stateid flags 0x%x\n",flags);
-	if ((flags & LOCK_STATE) || (flags & RD_STATE) || (flags & WR_STATE)) {
+	if (flags & (LOCK_STATE | RD_STATE | WR_STATE)) {
 		hashval = stateid_hashval(st_id, f_id);
 		list_for_each_entry(local, &lockstateid_hashtbl[hashval], st_hash) {
 			if ((local->st_stateid.si_stateownerid == st_id) &&
@@ -2435,7 +2435,8 @@ find_stateid(stateid_t *stid, int flags)
 				return local;
 		}
 	} 
-	if ((flags & OPEN_STATE) || (flags & RD_STATE) || (flags & WR_STATE)) {
+
+	if (flags & (OPEN_STATE | RD_STATE | WR_STATE)) {
 		hashval = stateid_hashval(st_id, f_id);
 		list_for_each_entry(local, &stateid_hashtbl[hashval], st_hash) {
 			if ((local->st_stateid.si_stateownerid == st_id) &&
