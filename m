Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49052 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752844Ab0IGF4D convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Sep 2010 01:56:03 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o875u3p1018863
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 7 Sep 2010 01:56:03 -0400
Received: from sleipnir.ol (vpn-236-160.phx2.redhat.com [10.3.236.160])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o875u2jZ032440
	for <linux-nfs@vger.kernel.org>; Tue, 7 Sep 2010 01:56:03 -0400
Date: Tue, 7 Sep 2010 02:56:01 -0300
From: Fabio Olive Leite <fleite@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] Remove incorrect do_vfs_lock message
Message-ID: <20100907025601.22a5ea2f@sleipnir.ol>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The do_vfs_lock function on fs/nfs/file.c is only called if NLM is
not being used, via the -onolock mount option. Therefore it cannot
really be "out of sync with lock manager" when the local locking
function called returns an error, as there will be no corresponding
call to the NLM. For details, simply check the if/else on do_setlk
and do_unlk on fs/nfs/file.c.

Signed-Off-By: Fabio Olive Leite <fleite@redhat.com>

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -723,10 +723,6 @@ static int do_vfs_lock(struct file *file, struct file_lock *fl)
 		default:
 			BUG();
 	}
-	if (res < 0)
-		dprintk(KERN_WARNING "%s: VFS is out of sync with lock manager"
-			" - error %d!\n",
-				__func__, res);
 	return res;
 }
 

Please keep me copied as I don't subscribe to the list.

Regards,
Fábio Olivé
-- 
TcheLinux.org, OeSC-Livre.org, Chapecó, SC
ex sed lex awk yacc, e pluribus unix, amem
