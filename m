Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:39047 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753145Ab2BFTiq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Feb 2012 14:38:46 -0500
Received: from compute4.internal (compute4.nyi.mail.srv.osa [10.202.2.44])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id D008E21068
	for <linux-nfs@vger.kernel.org>; Mon,  6 Feb 2012 14:38:44 -0500 (EST)
Date: Mon, 6 Feb 2012 11:38:36 -0800
From: Greg KH <gregkh@linuxfoundation.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Possible fixes for 2.6.32 stable
Message-ID: <20120206193836.GA16746@kroah.com>
References: <8FB4CAA9-65A1-498F-BA0B-96AA520EBBA2@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <8FB4CAA9-65A1-498F-BA0B-96AA520EBBA2@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 06, 2012 at 02:11:37PM -0500, Chuck Lever wrote:
> Hi-
> 
> Oracle's UEK kernel is within a few dozen commits of 2.6.32 stable.
> We recently discovered two critical problems with the NFS client in
> UEK that have upstream fixes that can be back ported.  I'm notifying
> you as a courtesy because these problems were reproduced in
> 2.6.32-stable, and the fixes are simple back ports you may wish to
> apply.
> 
> 
> The first issue: The 2.6.32 NFS client fails to perform NFSv4 state
> recovery after a server reboot if an NFS server returns
> NFS4ERR_NO_GRACE, and then blocks state recovery because its grace
> period has not expired.  Because the client fails to perform state
> recovery, it continues to use stale NFSv4 state tokens, which causes,
> among other symptoms, an infinite loop with the server.  The fixes for
> this are:
> 
> From 2.6.33: e345e88a, 4f7cdf18, c8b7ae3d, a9ed2e25
> 
> From 2.6.36: b0ed9dbc
> 
> These cleanly apply in that order to 2.6.32.  With these commits
> applied, our UEK NFS clients are able to perform NFSv4 state recovery
> correctly when an NFS server returns NFS4ERR_NO_GRACE.

These all look sane, I've queued them up now.

> The second issue: After a RPC over TCP connection is dropped, the
> 2.6.32 RPC client reconnects then immediately drops a new TCP
> connection, in a loop.  The client's NFS mount point becomes unusable.
> The fixes for this are:
> 
> From 2.6.34: 5fe46e9d

This applied fine.

> From 2.6.36: 669502ff

This one was contained in 2.6.32.40 (May 2011), so you you are still
needing it, please let me know what is wrong with the existing tree.

thanks,

greg k-h
