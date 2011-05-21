Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:28030 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757388Ab1EUXp2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 May 2011 19:45:28 -0400
Message-ID: <4DD84E8E.5040508@panasas.com>
Date: Sun, 22 May 2011 02:45:18 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, Fred Isaman <iisaman@netapp.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Smack on the head: Questions about pnfs write path
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Fred git blame points to you:

What was the meaning of the below code:

@@ -1014,18 +1015,22 @@ static int nfs_flush_one(struct nfs_pageio_descriptor *desc)
 		*pages++ = req->wb_page;
 	}
 	req = nfs_list_entry(data->pages.next);
	if ((!lseg) && list_is_singular(&data->pages))
 		lseg = pnfs_update_layout(desc->pg_inode, req->wb_context,
 					  req_offset(req), desc->pg_count,
 					  IOMODE_RW);

I mean why only the list_is_singular() case gets a pnfs_update_layout?

Because I have a very funny BUG:
If I do:
	dd if=/dev/zero of=/mnt/pnfs/dd1 bs=4k count=1
  I get a nice pnfs write out.
But if I do:
	dd if=/dev/zero of=/mnt/pnfs/dd1 bs=4k count=2 (or any > 1)
  I see all IO going to MDS

Below patch fixes that:
@@ -1014,18 +1015,22 @@ static int nfs_flush_one(struct nfs_pageio_descriptor *desc)
 		*pages++ = req->wb_page;
 	}
 	req = nfs_list_entry(data->pages.next);
-	if ((!lseg) && list_is_singular(&data->pages))
+	if ((!lseg) /*&& list_is_singular(&data->pages)*/)
 		lseg = pnfs_update_layout(desc->pg_inode, req->wb_context,
 					  req_offset(req), desc->pg_count,
 					  IOMODE_RW);

Which points to what I'm saying all along. pNFS Write path had no testing
but by me.

(BTW am still fighting the unbalanced lseg ref)

Thanks
Boaz

