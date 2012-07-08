Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail4-relais-sop.national.inria.fr ([192.134.164.105]:45215
	"EHLO mail4-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750922Ab2GHJP5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Jul 2012 05:15:57 -0400
Date: Sun, 8 Jul 2012 11:15:54 +0200 (CEST)
From: Julia Lawall <julia.lawall@lip6.fr>
To: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: question about fs/nfs/direct.c
Message-ID: <alpine.DEB.2.02.1207081113180.2436@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following code, in the function nfs_direct_write_reschedule, looks 
strange to me:

         list_for_each_entry_safe(req, tmp, &reqs, wb_list) {
                 if (!nfs_pageio_add_request(&desc, req)) {
                         nfs_list_add_request(req, &failed);
                         spin_lock(cinfo.lock);
                         dreq->flags = 0;
                         dreq->error = -EIO;
                         spin_unlock(cinfo.lock);
                 }
                 nfs_release_request(req);
         }
         nfs_pageio_complete(&desc);

         while (!list_empty(&failed))
                 nfs_unlock_and_release_request(req);

After the list_for_each_entry_safe, req is an address at some offset from 
the list head.  So it does not seem like an appropriate argument to 
nfs_unlock_and_release_request.

julia
