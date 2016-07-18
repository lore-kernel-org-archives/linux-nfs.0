Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:29424 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750732AbcGREdB convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Jul 2016 00:33:01 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
CC: List Linux <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v4 24/28] NFS: Getattr doesn't require data sync semantics
Date: Mon, 18 Jul 2016 04:32:53 +0000
Message-ID: <A9C18137-87A3-4652-ADD6-E8E1C4BAE27B@primarydata.com>
References: <1467844205-76852-16-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-17-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-18-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-19-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-20-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-21-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-22-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-23-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-24-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-25-git-send-email-trond.myklebust@primarydata.com>
 <20160718034847.GA1195@infradead.org>
In-Reply-To: <20160718034847.GA1195@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Christoph,

> On Jul 17, 2016, at 23:48, Christoph Hellwig <hch@infradead.org> wrote:
> 
> On Wed, Jul 06, 2016 at 06:30:01PM -0400, Trond Myklebust wrote:
>> When retrieving stat() information, NFS unfortunately does require us to
>> sync writes to disk in order to ensure that mtime and ctime are up to
>> date. However we shouldn't have to ensure that those writes are persisted.
>> 
>> Relaxing that requirement does mean that we may see an mtime/ctime change
>> if the server reboots and forces us to replay all writes.
>> 
>> The exception to this rule are pNFS clients that are required to send
>> layoutcommit, however that is dealt with by the call to pnfs_sync_inode()
>> in _nfs_revalidate_inode().
> 
> This one breaks xfstests generic/207 on block/scsi layout for me.  The
> reason for that is that we need a layoutcommit after writing out all
> data for the file for the file size to be updated on the server.
> 
> Below is my attempt to fix this by re-adding pnfs_sync_inode to
> nfs_getattr.  The call in _nfs_revalidate_inode isn't enough as it
> doesn't get called in most cases we care about.
> 

I’m not understanding this argument. Why do we care if the file size is up to date on the server if we’re not sending an actual GETATTR on the wire to retrieve the file size?

Cheers
  Trond

