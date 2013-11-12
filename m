Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:32025 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753735Ab3KLWdy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Nov 2013 17:33:54 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Charles Edward Lever <chuck.lever@oracle.com>,
        Weston Andros Adamson <dros@netapp.com>
Subject: Re: [PATCH] nfs: don't retry detect_trunking with RPC_AUTH_UNIX
 more than once
Date: Tue, 12 Nov 2013 22:33:49 +0000
Message-ID: <3A135082-6C37-41A8-9B37-AAF0AA884DEC@netapp.com>
References: <1384291851-11154-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1384291851-11154-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 12, 2013, at 16:30, Jeff Layton <jlayton@redhat.com> wrote:

> Currently, when we try to mount and get back NFS4ERR_CLID_IN_USE or
> NFS4ERR_WRONGSEC, we create a new rpc_clnt and then try the call again.
> There is no guarantee that doing so will work however, so we can end up
> retrying the call in an infinite loop.
> 
> Worse yet, we create the new client using rpc_clone_client_set_auth,
> which creates the new client as a child of the old one. Thus, we can end
> up with a *very* long lineage of rpc_clnts. When we go to put all of the
> references to them, we can end up with a long call chain that can smash
> the stack as each rpc_free_client() call can recurse back into itself.

Note that we should perhaps also try to fix rpc_free_client. I have a patch for that...

Cheers
  Trond