Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:11320 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754315Ab1GRRfe convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Jul 2011 13:35:34 -0400
Subject: Re: [PATCH] nfs: don't use d_move in nfs_async_rename_done
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        viro@ZenIV.linux.org.uk
Date: Mon, 18 Jul 2011 13:35:14 -0400
In-Reply-To: <1311002790-6650-1-git-send-email-jlayton@redhat.com>
References: <1311002790-6650-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1311010514.23313.4.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-07-18 at 11:26 -0400, Jeff Layton wrote: 
> If the task that initiated the sillyrename ends up being killed by a
> fatal signal, then it will eventually return back to userspace and end
> up releasing the i_mutex. d_move however needs to be done while holding
> the i_mutex.

Umm... Where is this requirement documented? I thought the rename_lock
was there to protect against lookup races etc with d_move.

Besides, NFS already has
nfs_block_sillyrename()/nfs_unblock_sillyrename() to provide further
exclusion between dentry lookups and revalidations and the silly-unlink
code.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

