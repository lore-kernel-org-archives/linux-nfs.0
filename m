Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.tv2.hu ([91.82.156.6]:54013 "EHLO mail.tv2.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752213AbbCaPra convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Mar 2015 11:47:30 -0400
Received: from autodiscover.intra.tv2.hu ([10.4.1.26] helo=ex-5.intra.tv2.hu)
	by mail.tv2.hu with esmtp (Exim 4.71)
	(envelope-from <balazs.gal@tv2.hu>)
	id 1YcxuJ-00018D-LA
	for linux-nfs@vger.kernel.org; Tue, 31 Mar 2015 17:16:47 +0200
From: =?iso-8859-2?Q?G=E1l=2C_Bal=E1zs?= <balazs.gal@tv2.hu>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Linux kernel 3.18+ blocklayout driver support only 4k pNFS block size
Date: Tue, 31 Mar 2015 15:16:41 +0000
Message-ID: <DB3PR03MB0891F4C3C510AB5C7565A4D0BAF40@DB3PR03MB0891.eurprd03.prod.outlook.com>
Content-Type: text/plain; charset="iso-8859-2"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all!

Started with version 3.18 the Linux kernel blocklayout driver will support pNFS servers with pnfs_block_size <= PAGE_SIZE only.

You can find this restriction in the fs/nfs/blocklayout/blocklayout.c at the bl_set_layoutdriver function:

	if (server->pnfs_blksize > PAGE_SIZE) {
		printk(KERN_ERR "%s: pNFS blksize %d not supported.\n",
			__func__, server->pnfs_blksize);
		return -EINVAL;
	}

The page size is 4k on x64, but we use an EMC VNX5300 storage as a pNFS server, which use a hardcoded 8k file system block size.
So I'm not able to use the VNX pNFS functionality with the current kernel anymore.

As I know, EMC is not the only one solution with the 8k block size, so this can brake lot of product on the market.

There is another issue with the client layout get requests implementation, what will limit the pNFS max file size in 524MB with the maximum 4k layout length in the request.
This is a normal limitation with other block layout pNFS servers also?

I'm just a dummy user from the broadcast Industry, and I want report it only, but it would be great if this problem can be handled by someone/somehow.

Thanks for your help!

Best regards

BALÁZS GÁL


