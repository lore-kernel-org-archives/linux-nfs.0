From: Olaf Kirch <okir@suse.de>
Subject: NFS O_DIRECT data_updates desync
Date: Mon, 17 May 2004 17:32:29 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040517153229.GN14755@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="NzB8fVQJ5HfG6fxh"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BPk6W-0003XX-2S
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 08:32:36 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BPk6V-0000iG-KY
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 08:32:35 -0700
Received: from hermes.suse.de (hermes-ext.suse.de [195.135.221.8])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by Cantor.suse.de (Postfix) with ESMTP id C08625CA395
	for <nfs@lists.sourceforge.net>; Mon, 17 May 2004 17:32:29 +0200 (CEST)
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Trond, Chuck,

there's a code path in nfs_direct_write_seg where
NFS_I(inode)->data_updates can get out of sync with reality,
which will lead to a BUG() in nfs_clear_inode later on.

I'm attaching a patch that addresses this issue.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 

--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=nfs-direct-dataref

--- linux-2.6.5/fs/nfs/direct.c.count	2004-05-14 17:18:51.000000000 +0200
+++ linux-2.6.5/fs/nfs/direct.c	2004-05-17 17:27:21.000000000 +0200
@@ -297,7 +297,7 @@
 		if (result <= 0) {
 			if (tot_bytes > 0)
 				break;
-			return result;
+			goto out;
 		}
 
 		if (tot_bytes == 0)
@@ -336,9 +336,12 @@
 						VERF_SIZE) != 0)
 			goto sync_retry;
 	}
+	result = tot_bytes;
+
+out:
 	nfs_end_data_update_defer(inode);
 
-	return tot_bytes;
+	return result;
 
 sync_retry:
 	wdata.args.stable = NFS_FILE_SYNC;

--NzB8fVQJ5HfG6fxh--


-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
