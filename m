Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:23955 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751252Ab1F1X0W convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jun 2011 19:26:22 -0400
Subject: Re: [PATCH][Resend] coredump: call vfs_getattr() to get inode
 attributes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Arnaud Giersch <arnaud.giersch@free.fr>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Tue, 28 Jun 2011 19:26:01 -0400
In-Reply-To: <87tyb9r6wh.fsf@free.fr>
References: <87tyb9r6wh.fsf@free.fr>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1309303561.27467.9.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-06-28 at 23:19 +0200, Arnaud Giersch wrote: 
> From: Arnaud Giersch <arnaud.giersch@free.fr>
> 
> In do_coredump(), call vfs_getattr() to get inode attributes, and do not
> get them directly from the fields of the inode struct.
> 
> Without this patch, when dumping core on an NFSv4 mount, and the i_uid
> field is not correctly filled at open time, the uid check fails, and an
> empty core dump is produced.
> 
> This apparently only happens when there was no "core" file before the
> dump.  If a "core" file owned by the current user is already present, it
> is correctly filled.
> 
> The reason is that decode_attr_owner() in fs/nfs/nfs4xdr.c is not
> allowed to call the idmapper when it receives may_sleep = 0 (see commit
> 80e52aced138bb41b045a8595a87510f27d8d8c5, and some explanations in
> http://article.gmane.org/gmane.linux.nfs/33391).
> 
> Signed-off-by: Arnaud Giersch <arnaud.giersch@free.fr>

This wants to be fixed in the NFS layer, not the VFS.

What we should do is the following:

     1. Save the string versions of user@domain/group@domain in the
        struct nfs4_opendata so that we can resolve them from the
        process context in _nfs4_proc_open(). 
     2. Fix nfs4_atomic_open() so that it revalidates any inode that has
        the NFS_INO_INVALID_ATTR flag set.

Cheers
   Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

