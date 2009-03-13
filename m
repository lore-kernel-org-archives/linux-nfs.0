Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:49624 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759887AbZCMW3y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Mar 2009 18:29:54 -0400
Subject: Re: Horrible NFS Client Performance During Heavy Server IO
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: David Rees <drees76@gmail.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <72dbd3150903131459u273d8e8nc9e966eae01848f7@mail.gmail.com>
References: <72dbd3150903131336m78526d4ao1308052d6233b70@mail.gmail.com>
	 <1236978608.7265.41.camel@heimdal.trondhjem.org>
	 <72dbd3150903131432u43d9ba43nf0456b99aed0f8fd@mail.gmail.com>
	 <1236980438.7265.47.camel@heimdal.trondhjem.org>
	 <72dbd3150903131459u273d8e8nc9e966eae01848f7@mail.gmail.com>
Content-Type: text/plain
Date: Fri, 13 Mar 2009 18:29:49 -0400
Message-Id: <1236983389.7265.51.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2009-03-13 at 14:59 -0700, David Rees wrote:
> And the activity around the time I am reproducing the slowdown:
> 
> Server nfs v3:
> null         getattr      setattr      lookup       access       readlink
> 0         0% 3503     75% 7         0% 31        0% 1027     22% 0         0%
> read         write        create       mkdir        symlink      mknod
> 9         0% 50        1% 6         0% 0         0% 0         0% 0         0%
> remove       rmdir        rename       link         readdir      readdirplus
> 2         0% 0         0% 2         0% 0         0% 0         0% 0         0%
> fsstat       fsinfo       pathconf     commit
> 0         0% 0         0% 0         0% 13        0%

Is this the result of only doing 2 'dd' copies? That's a lot of GETATTR
calls for that kind of workload...

Trond

