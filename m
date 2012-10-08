Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail3.ks.pochta.ru ([62.141.94.173]:49638 "EHLO
	mail3.ks.pochta.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753933Ab2JHPUv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Oct 2012 11:20:51 -0400
Message-ID: <1349708828.1183.5.camel@lix>
Subject: exportfs crash with long path
From: Ivan Romanov <drizt@land.ru>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 08 Oct 2012 21:07:08 +0600
Content-Type: multipart/mixed; boundary="=-ebu/n9Oo77Dwu5UEEdUP"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-ebu/n9Oo77Dwu5UEEdUP
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit

Hello. I opened a bug with nfs-utils on Redhat Bugzilla. And got an
advice to email upstream. So I just repeat my bug text with a patch.

How reproducible:
always

Steps to Reproduce:
# mkdir -p /home/kudinae/Общедоступные
# echo '/home/kudinae/Общедоступные oek-1(rw,sync,no_wdelay,no_root_squash,no_subtree_check)' > /etc/exports
# exportfs -a
Segmentation fault

I've obtained the sources. So a crush happens on export.c:293. variable
pos has negative value. I think problem into strtoint and export_hash
functions. strtoint has unsigned type and always returns positive value
but export_hash impicity cast it to signed int. So it is possible to
get negative value. I wrote patch to fix this.

Original Red Hat bug
https://bugzilla.redhat.com/show_bug.cgi?id=863054

--=-ebu/n9Oo77Dwu5UEEdUP
Content-Disposition: attachment; filename="nfs-utils-hash.patch"
Content-Type: text/x-patch; name="nfs-utils-hash.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

diff --git a/support/export/export.c b/support/export/export.c
index 4fda30a..0257903 100644
--- a/support/export/export.c
+++ b/support/export/export.c
@@ -357,7 +357,7 @@ strtoint(char *str)
 static int 
 export_hash(char *str)
 {
-	int num = strtoint(str);
+	unsigned int num = strtoint(str);
 
 	return num % HASH_TABLE_SIZE;
 }

--=-ebu/n9Oo77Dwu5UEEdUP--

