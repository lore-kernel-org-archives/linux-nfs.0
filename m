Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13566 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751145Ab0HQWC3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Aug 2010 18:02:29 -0400
Subject: Re: should sillyrename be an asynchronous operation?
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20100817093009.74800ec7@tlielax.poochiereds.net>
References: <20100817093009.74800ec7@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 17 Aug 2010 18:02:12 -0400
Message-ID: <1282082532.18385.18.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-08-17 at 09:30 -0400, Jeff Layton wrote:
> We had a bug report recently where someone was complaining about
> silly-renamed files being left around:
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=511901
> 
> ...they attached a reproducer to the bug which involves a
> pthreads-based program killing a child thread that's unlinking and
> closing a file.
> 
> The unlink triggers a sillyrename (since the file is still open). The
> parent kills the child thread and if timed just right, the child thread
> will be killed after the RENAME call is issued but before the reply is
> processed. The file will end up renamed on the server, but the client
> won't be aware of it and won't unlink it during dentry_iput.
> 
> It's a bit of work, but the best way I can envision to fix this would
> be to make sillyrename do an asynchronous RENAME call, and have it wait
> for the reply. If the task is killed, then the RENAME can proceed and
> the file would be unlinked when the dput is done by the rpc_release
> call.
> 
> At this point, I just want to know whether this approach is acceptable
> before I spend time on it. Is there a better way to handle this?

Well... The rpc_release cannot allocate memory, so you're going to have
to preallocate the struct nfs_unlinkdata afaics.

I suppose one way to do that would be to call nfs_async_unlink() first,
then do the rename, then cancel the async_unlink if the rename attempt
fails.
We already do something like that in nfs_do_call_unlink if we race with
a lookup...

Cheers
  Trond
