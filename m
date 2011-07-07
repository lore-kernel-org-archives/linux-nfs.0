Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24359 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756744Ab1GGOta (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jul 2011 10:49:30 -0400
Date: Thu, 7 Jul 2011 10:49:28 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] sunrpc: when call_bind fails with -EACCES, don't exit
 with -EIO
Message-ID: <20110707104928.062a54a6@barsoom.rdu.redhat.com>
In-Reply-To: <1310049356.3863.45.camel@lade.trondhjem.org>
References: <1310049133-10255-1-git-send-email-jlayton@redhat.com>
	<1310049356.3863.45.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 07 Jul 2011 10:35:56 -0400
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> On Thu, 2011-07-07 at 10:32 -0400, Jeff Layton wrote: 
> > Commit 0b760113a fixed the client not to loop indefinitely if the
> > rpcbind was continually failing. When this occurs though, the rpc_task
> > now exits with a status of -EIO. If the tk_status is -EACCES, it seems
> > like we should preserve that in this situation.
> 
> Why? This isn't the POSIX EACCES error, but a sign that the server is
> once again refusing to do business with us: usually that means EIO.
> 

Fair enough. I figured that an EACCES error would better describe the
situation than EIO, but I'll defer to your judgement on this.

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>
