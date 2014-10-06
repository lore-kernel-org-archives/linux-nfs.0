Return-Path: linux-nfs-owner@vger.kernel.org
Received: from auth-4.ukservers.net ([217.10.138.158]:54825 "EHLO
	auth-4.ukservers.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751344AbaJFOhT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Oct 2014 10:37:19 -0400
Received: from main.carlh.net (unknown [37.139.5.111])
	(using TLSv1.2 with cipher DHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	by auth-4.ukservers.net (Postfix smtp) with ESMTPS id 34B9C1CC7B01
	for <linux-nfs@vger.kernel.org>; Mon,  6 Oct 2014 15:37:18 +0100 (BST)
Received: from carl (helo=localhost)
	by main.carlh.net with local-esmtp (Exim 4.80)
	(envelope-from <cth@carlh.net>)
	id 1Xb9PV-0007gz-7K
	for linux-nfs@vger.kernel.org; Mon, 06 Oct 2014 15:37:17 +0100
Date: Mon, 6 Oct 2014 15:37:13 +0100 (BST)
From: Carl Hetherington <cth@carlh.net>
To: linux-nfs@vger.kernel.org
Message-ID: <alpine.DEB.2.02.1410061536100.27485@main.carlh.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Subject: [PATCHv2 2/2] intermittent erroneous uid/gid bug with
 NFS4/Kerberos
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs: Call request_valid_key_with_auxdata() from
nfs_idmap_request_key() so that the keys code asks userspace for an updated
key if one has expired.  Without this, nfs_idmap_request_key() can return an
expired key which causes incorrect uid/gid mappings.

Signed-off-by: Carl Hetherington <cth@carlh.net>
---
  fs/nfs/idmap.c | 4 ++--
  1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 567983d..744e40f 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -278,8 +278,8 @@ static struct key *nfs_idmap_request_key(const char *name, size_t namelen,
  	rkey = request_key(&key_type_id_resolver, desc, "");
  	if (IS_ERR(rkey)) {
  		mutex_lock(&idmap->idmap_mutex);
-		rkey = request_key_with_auxdata(&key_type_id_resolver_legacy,
-						desc, "", 0, idmap);
+		rkey = request_valid_key_with_auxdata(&key_type_id_resolver_legacy,
+						      desc, "", 0, idmap);
  		mutex_unlock(&idmap->idmap_mutex);
  	}

-- 
1.9.1


