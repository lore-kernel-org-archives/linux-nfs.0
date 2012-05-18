Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:47675 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933155Ab2ERTb6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 May 2012 15:31:58 -0400
Date: Fri, 18 May 2012 12:31:56 -0700
From: Greg KH <greg@kroah.com>
To: Jonathan Nieder <jrnieder@gmail.com>
Cc: stable@vger.kernel.org, Rik Theys <Rik.Theys@esat.kuleuven.be>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, David Flyn <davidf@rd.bbc.co.uk>,
        Jeff Layton <jlayton@redhat.com>, 659111@bugs.debian.org
Subject: Re: [PATCH 3.0.y, 3.2.y] NFSv4: Revalidate uid/gid after open
Message-ID: <20120518193156.GD4874@kroah.com>
References: <alpine.LRH.2.00.1204242156380.28096@helium.esat.kuleuven.be>
 <20120511092020.GD5733@burratino>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120511092020.GD5733@burratino>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 11, 2012 at 04:20:20AM -0500, Jonathan Nieder wrote:
> This is a shorter (and more appropriate for stable kernels) analog to
> the following upstream commit:
> 
> commit 6926afd1925a54a13684ebe05987868890665e2b
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Sat Jan 7 13:22:46 2012 -0500
> 
>     NFSv4: Save the owner/group name string when doing open
> 
>     ...so that we can do the uid/gid mapping outside the asynchronous RPC
>     context.
>     This fixes a bug in the current NFSv4 atomic open code where the client
>     isn't able to determine what the true uid/gid fields of the file are,
>     (because the asynchronous nature of the OPEN call denies it the ability
>     to do an upcall) and so fills them with default values, marking the
>     inode as needing revalidation.
>     Unfortunately, in some cases, the VFS will do some additional sanity
>     checks on the file, and may override the server's decision to allow
>     the open because it sees the wrong owner/group fields.
> 
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Without this patch, logging into two different machines with home
> directories mounted over NFS4 and then running "vim" and typing ":q"
> in each reliably produces the following error on the second machine:
> 
> 	E137: Viminfo file is not writable: /users/system/rtheys/.viminfo
> 
> This regression was introduced by 80e52aced138 ("NFSv4: Don't do
> idmapper upcalls for asynchronous RPC calls", merged during the 2.6.32
> cycle) --- after the OPEN call, .viminfo has the default values for
> st_uid and st_gid (0xfffffffe) cached because we do not want to let
> rpciod wait for an idmapper upcall to fill them in.
> 
> The fix used in mainline is to save the owner and group as strings and
> perform the upcall in _nfs4_proc_open outside the rpciod context,
> which takes about 600 lines.  For stable, we can do something similar
> with a one-liner: make open check for the stale fields and make a
> (synchronous) GETATTR call to fill them when needed.
> 
> Trond dictated the patch, I typed it in, and Rik tested it.
> 
> Addresses http://bugs.debian.org/659111 and
>           https://bugzilla.redhat.com/789298
> 
> Reported-by: Rik Theys <Rik.Theys@esat.kuleuven.be>
> Explained-by: David Flyn <davidf@rd.bbc.co.uk>
> Signed-off-by: Jonathan Nieder <jrnieder@gmail.com>
> Tested-by: Rik Theys <Rik.Theys@esat.kuleuven.be>
> ---
> Hi Ben and Greg,
> 
> Please consider this patch for inclusion in 3.0.y and 3.2.y kernels.
> 3.3.y doesn't need it since 6926afd1925a was merged during the 3.3
> merge window.

Wonderful work, now applied to the 3.0-stable tree, thanks for doing
this.

greg k-h
