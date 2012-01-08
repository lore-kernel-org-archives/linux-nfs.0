Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:5399 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752042Ab2AHRUj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Jan 2012 12:20:39 -0500
Message-ID: <1326043237.2935.0.camel@lade.trondhjem.org>
Subject: Re: [PATCH v2] NFSv4: Save the owner/group name string when doing
 open
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Date: Sun, 08 Jan 2012 12:20:37 -0500
In-Reply-To: <23AF1B91-F3FF-4B9F-AAE3-A9DDB4ED205A@oracle.com>
References: <1325956115-21767-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1325960863-31742-1-git-send-email-Trond.Myklebust@netapp.com>
	 <23AF1B91-F3FF-4B9F-AAE3-A9DDB4ED205A@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2012-01-07 at 18:13 -0500, Chuck Lever wrote: 
> On Jan 7, 2012, at 1:27 PM, Trond Myklebust wrote:
> 
> > ...so that we can do the uid/gid mapping outside the asynchronous RPC
> > context.
> > This fixes a bug in the current NFSv4 atomic open code where the client
> > isn't able to determine what the true uid/gid fields of the file are,
> > (because the asynchronous nature of the OPEN call denies it the ability
> > to do an upcall) and so fills them with default values, marking the
> > inode as needing revalidation.
> > Unfortunately, in some cases, the VFS will do some additional sanity
> > checks on the file, and may override the server's decision to allow
> > the open because it sees the wrong owner/group fields.
> 
> I expect this change would also address the known problem with empty application core dumps on NFSv4 mounts...?

Yes. I believe that the above mentioned VFS-level checks were the
problem there.


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

