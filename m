Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:43402 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753111Ab0ITMt2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Sep 2010 08:49:28 -0400
Received: from cyclope.frec.bull.fr (cyclope.frec.bull.fr [129.183.4.9])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 0341B6F59F
	for <linux-nfs@vger.kernel.org>; Mon, 20 Sep 2010 14:49:20 +0200 (CEST)
Received: from [129.183.101.247] (pa-129.183.101.247.frec.bull.fr [129.183.101.247])
	by cyclope.frec.bull.fr (Postfix) with ESMTP id C39032728D
	for <linux-nfs@vger.kernel.org>; Mon, 20 Sep 2010 14:49:16 +0200 (CEST)
Message-ID: <4C97584F.4020104@bull.net>
Date: Mon, 20 Sep 2010 14:49:19 +0200
From: Menyhart Zoltan <Zoltan.Menyhart@bull.net>
To: linux-nfs@vger.kernel.org
Subject: Locking question around "...PagePrivate()"
References: <4C7E4469.70807@duchatelet.net>
In-Reply-To: <4C7E4469.70807@duchatelet.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

nfs_inode_add_request() runs under the protection of the Page Lock
while setting up SetPagePrivate(), set_page_private().

The consumers of PagePrivate() run also under the protection of the Page Lock.

On the other hand, nfs_inode_remove_request() invoked by
nfs_writeback_release_full() and nfs_commit_release() apparently does
not take the Page Lock.

nfs_inode_remove_request() includes the sequence of

         set_page_private(req->wb_page, 0);
         ClearPagePrivate(req->wb_page);

When the base kernel calls e.g.

	mapping->a_ops->releasepage(page, gfp_mask)

then nfs_release_page() may see an incoherent "private" state.

Should not all the "private" operations be protected by the Page Lock?

Thanks,

Zoltan Menyhart
