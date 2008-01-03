From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT] More NFS client fixes for 2.6.24-rc6
Date: Thu, 3 Jan 2008 10:30:48 +0100
Message-ID: <20080103093048.GA16803@elte.hu>
References: <1199329417.28241.3.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:56100 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753934AbYACJbF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jan 2008 04:31:05 -0500
In-Reply-To: <1199329417.28241.3.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


* Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> commit 53478daff2c8b494d2af1ede6611f166f81bc393
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Wed Jan 2 13:28:57 2008 -0500
> 
>     NFS: Fix a possible Oops in fs/nfs/super.c
>     
>     Sigh... commit 4584f520e1f773082ef44ff4f8969a5d992b16ec (NFS: Fix NFS
>     mountpoint crossing...) had a slight flaw: server can be NULL if sget()
>     returned an existing superblock.
>     
>     Fix the fix by dereferencing s->s_fs_info.
>     
>     Also add in the same namespace Oops fix for NFSv4 in both the mountpoint
>     crossing case, and the referral case.
>     
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

shouldnt this commit have included the full credit of the bugfix:

  http://bugzilla.kernel.org/show_bug.cgi?id=9647

  ------------>
  Description From Adrian Bunk 2007-12-27 12:36

  The Coverity checker spotted that commit
  4584f520e1f773082ef44ff4f8969a5d992b16ec introduced the following NULL
  dereference in 2.6.24-rc6:

  <--  snip  -->
         if (s->s_fs_info != server) {
                 nfs_free_server(server);
                 server = NULL;     <---------------
         }

  ------- Comment #1 From Adrian Bunk 2007-12-27 12:37:42 -------
  The NULL dereference is at the 
  server->nfs_client->rpc_ops->dir_inode_ops.
  <--------------

	Ingo
