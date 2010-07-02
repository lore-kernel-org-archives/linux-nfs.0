Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:40645 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757111Ab0GBND3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Jul 2010 09:03:29 -0400
Subject: Re: Empty core dumps on NFSv4 mounts
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Arnaud Giersch <arnaud.giersch@iut-bm.univ-fcomte.fr>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <wwezkyas466.fsf@powwow.iut-bm.univ-fcomte.fr>
References: <wwezkyas466.fsf@powwow.iut-bm.univ-fcomte.fr>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 02 Jul 2010 09:03:24 -0400
Message-ID: <1278075804.3258.20.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-07-02 at 10:01 +0200, Arnaud Giersch wrote:
> Hi,
> 
> On NFSv4 mounts, many core dumps are empty, although ulimit -c is
> unlimited.  An ls command shortly after the core dump often shows
> 4294967294 (2^32-2) as UID and GID for the "core" file.
> 
> This only happens when there was no "core" file before the dump.  If a
> "core" file owned by the current user is already present, it is
> correctly filled.
> 
> After having done a git bisect, it seems that the problem was
> introduced by commit 80e52aced138bb41b045a8595a87510f27d8d8c5
> (NFSv4: Don't do idmapper upcalls for asynchronous RPC calls).
> 
> If I understand correctly what happens, do_coredump() [fs/exec.c] fails
> because (inode->i_uid != current_fsuid()).  In fact inode->i_uid equals
> -2, because decode_attr_owner() [fs/nfs/nfs4xdr.c], which is called from
> nfs4_xdr_dec_open() via decode_getfattr(), returns without calling
> nfs_map_to_uid(), since its may_sleep parameter is false.
> 
> I however do not clearly understand what the aforementioned commit is
> supposed to fix.  I read the linux-nfs mailing list archive, and tried
> some google search, but I didn't find anything.

rpciod threads should never do anything that can cause them to sleep.
Doing an upcall as part of an XDR decode is therefore verboten.

We should ideally rather be saving the owner/group strings and doing the
upcall after the XDR is done. While that wasn't feasible when 'fattr'
structs were being allocated on the stack, now that they are dynamically
allocated, maybe we can rethink that...

Cheers
  Trond

