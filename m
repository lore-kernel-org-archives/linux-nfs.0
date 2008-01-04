From: Wendy Cheng <wcheng@redhat.com>
Subject: [PATCH] Fix NLM reference count panic
Date: Fri, 04 Jan 2008 17:48:49 -0500
Message-ID: <477EB7D1.9030303@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040108010804020300040508"
To: NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44861 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752873AbYADWvR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Jan 2008 17:51:17 -0500
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id m04MpFQn031464
	for <linux-nfs@vger.kernel.org>; Fri, 4 Jan 2008 17:51:15 -0500
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com [172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id m04MpEhu021707
	for <linux-nfs@vger.kernel.org>; Fri, 4 Jan 2008 17:51:14 -0500
Received: from [172.16.59.29] (wendyc-t.rdu.redhat.com [172.16.59.29])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id m04MpE2p016405
	for <linux-nfs@vger.kernel.org>; Fri, 4 Jan 2008 17:51:14 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040108010804020300040508
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This is not exciting as Jeff Garzik's new NFSv4 server but a painful 
chore needs to be done. Will start to push the patches for NLM lock 
failover code next week. However, instead of doing large amount of 
patches all at once, would like to do it one by one, if they can be 
functionally separated. This is to avoid the tedious re-base works I 
have been doing for the past, (oh no), two years ??!!!

First one should be simple enough without too much explanation ....

-- Wendy




--------------040108010804020300040508
Content-Type: text/x-patch;
 name="001-nlm_f_count.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="001-nlm_f_count.patch"

This fixes the incorrect fclose call inside nlm_traverse_files() where 
a posix lock could still be held by NFS client. Problem was found in a
kernel panic inside locks_remove_flock() (fs/locks.c:2034) as part of 
the fclose call due to NFS-NLM locks still hanging on inode->i_flock list. 

Also see: http://people.redhat.com/wcheng/Patches/NFS/NLM/001.txt

 svcsubs.c |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

--- gfs2-nmw/fs/lockd/svcsubs.c	2007-04-10 11:59:09.000000000 -0400
+++ linux/fs/lockd/svcsubs.c	2007-04-18 10:01:23.000000000 -0400
@@ -250,8 +250,7 @@ nlm_traverse_files(struct nlm_host *host
 			mutex_lock(&nlm_file_mutex);
 			file->f_count--;
 			/* No more references to this file. Let go of it. */
-			if (list_empty(&file->f_blocks) && !file->f_locks
-			 && !file->f_shares && !file->f_count) {
+			if (!nlm_file_inuse(file)) {
 				hlist_del(&file->f_list);
 				nlmsvc_ops->fclose(file->f_file);
 				kfree(file);

--------------040108010804020300040508--
