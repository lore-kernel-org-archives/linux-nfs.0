Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29699 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755078Ab1CRBuC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Mar 2011 21:50:02 -0400
Subject: Re: Small O_SYNC writes are no longer NFS_DATA_SYNC
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20110318120417.435551da@notabene.brown>
References: <20110216171555.6642c630@notabene.brown>
	 <1300405987.4621.10.camel@lade.trondhjem.org>
	 <20110318120417.435551da@notabene.brown>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 17 Mar 2011 21:49:26 -0400
Message-ID: <1300412966.9671.9.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-03-18 at 12:04 +1100, NeilBrown wrote:
> On Thu, 17 Mar 2011 19:53:07 -0400 Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> > Would it ever be wrong to set the FILE_SYNC flag for the very last rpc
> > call in a writeback series? I'm thinking that we might want to set
> > FLUSH_STABLE before the call to pageio_complete in
> > nfs_writepage_locked() and nfs_writepages().
> 
> Interesting idea.
> 
> Am I correct in assuming you only mean if wbc->sync_mode == WB_SYNC_ALL.
> It wouldn't seem to make any sense for WB_SYNC_NONE.
> 
> In that case that last RPC would be immediately followed by a COMMIT. So it
> could be reasonable to make it NFS_DATA_SYNC.

No. DATA_SYNC _requires_ a COMMIT to ensure that metadata is synced too,
so it makes little sense to use it here.

> However the server would be seeing something a bit odd - a sequence of
> unstable writes, then a stable write, then a commit.  This could cause it to
> 'sync' things in the 'wrong' order which might be less than optimal.  It
> would depend a lot on the particular server and filesystem of course, but it
> seems to be mis-communicating.  So I think I would avoid this approach
> (assuming I understand it correctly).

Yes. Thinking a bit more about it, the latest versions of the Linux
server actually do use vfs_fsync_range(), so it no longer makes sense to
replace COMMIT with a FILE_SYNC write.

However we could adopt the Solaris convention of always starting
writebacks with a FILE_SYNC, and then falling back to UNSTABLE for the
second rpc call and all subsequent calls...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

