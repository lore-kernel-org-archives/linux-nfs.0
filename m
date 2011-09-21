Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58945 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751415Ab1IUSxN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Sep 2011 14:53:13 -0400
Subject: Re: regression when opening directories on NFSv4
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Date: Wed, 21 Sep 2011 14:53:12 -0400
In-Reply-To: <20110921115854.02605a7f@tlielax.poochiereds.net>
References: <20110921115854.02605a7f@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1316631192.21183.40.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-09-21 at 11:58 -0400, Jeff Layton wrote: 
> We had a regression reported against RHEL concerning the opening of
> directories and it looks like that same problem is in current mainline
> code too. If you do the following on a directory that is not yet in the
> dcache you get an EISDIR error:
> 
>      open("/mnt/nfs/dir1", O_RDONLY)         = -1 EISDIR (Is a directory)
> 
> If however, you stat the directory first, the open works. The
> difference seems to be that in the first case we're going through the
> lookup codepath, and in the second we go through d_revalidate.
> 
> In the first case, we send an OPEN call to the server and it responds
> with NFS4ERR_ISDIR. That gets translated to -EISDIR, and returned to
> userspace. It wasn't always this way though, and I think the regression
> was introduced in commit d953126a2.
> 
> That patch was added to fix an oops due to a buggy server, and I'm
> unclear on how best to fix this. It seems like we need to allow the
> server to fall back to doing a normal lookup when we get -EISDIR on the
> OPEN call, but how do we ensure that we don't end up with the same oops
> from that server bug?

How about returning an error if we get to the file->f_ops->open on a
regular file in NFSv4?

In NFSv4.1 we could theoretically issue an OPEN will CLAIM_FH (assuming
there are servers out there that support it), but for NFSv4 as far as I
can see, there will always be a potential for races.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

