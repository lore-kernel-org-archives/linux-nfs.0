Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:51800 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752269Ab2HICaX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Aug 2012 22:30:23 -0400
Received: by pbbrr13 with SMTP id rr13so90540pbb.19
        for <linux-nfs@vger.kernel.org>; Wed, 08 Aug 2012 19:30:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1344452224.8925.30.camel@lade.trondhjem.org>
References: <1344391392-1948-1-git-send-email-bergwolf@gmail.com>
 <1344391392-1948-4-git-send-email-bergwolf@gmail.com> <1344452224.8925.30.camel@lade.trondhjem.org>
From: Peng Tao <bergwolf@gmail.com>
Date: Thu, 9 Aug 2012 10:30:02 +0800
Message-ID: <CA+a=Yy4G7cBmSU-sDXZ7=cb3Qkfr1n7MzSp3mKdK_UYSZ6iKng@mail.gmail.com>
Subject: Re: [PATCH RFC 3/3] NFS41: send real read size in layoutget for DIO
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "bharrosh@panasas.com" <bharrosh@panasas.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 9, 2012 at 2:57 AM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Wed, 2012-08-08 at 10:03 +0800, Peng Tao wrote:
>> From: Peng Tao <tao.peng@emc.com>
>>
>> We don't have the real IO size information in buffer read, but for direct
>> read, we can get it from dreq->bytes_left. Let's make use of it.
>
> What's wrong with using the nfs_readpages arguments? The readahead code
> will tell you exactly how many pages it is trying to read.
>
The nr_pages information gets dropped before calling into pnfs code...

How about something like bellow for buffer reads? (untested patch and
needs to integrate with DIO size for sure).

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 2e00fea..cec79c2 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1162,7 +1162,7 @@ pnfs_generic_pg_init_read(struct
nfs_pageio_descriptor *pgio, struct nfs_page *r
 	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 					   req->wb_context,
 					   req_offset(req),
-					   req->wb_bytes,
+					   (unsigned)pgio->pg_layout_private,
 					   IOMODE_READ,
 					   GFP_KERNEL);
 	/* If no lseg, fall back to read through mds */
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index b6bdb18..64fb0e2 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -649,6 +649,7 @@ int nfs_readpages(struct file *filp, struct
address_space *mapping,

 	NFS_PROTO(inode)->read_pageio_init(&pgio, inode,
&nfs_async_read_completion_ops);

+	pgio.pg_layout_private = (void *)nr_pages;
 	ret = read_cache_pages(mapping, pages, readpage_async_filler, &desc);

 	nfs_pageio_complete(&pgio);


-- 
Thanks,
Tao
