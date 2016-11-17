Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:44171 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933111AbcKQHPN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Nov 2016 02:15:13 -0500
Date: Thu, 17 Nov 2016 08:15:23 +0100
From: Greg KH <greg@kroah.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: stable@vger.kernel.org, Vasco Steinmetz <linux@kyberraum.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [stable 4.8] xprtrdma: Fix DMAR failure in frwr_op_map() after
 reconnect
Message-ID: <20161117071523.GA5435@kroah.com>
References: <480AB524-3381-4699-B6E3-1D4D16FF843C@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <480AB524-3381-4699-B6E3-1D4D16FF843C@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 16, 2016 at 03:50:47PM -0500, Chuck Lever wrote:
> Please cherry-pick this commit for v4.8 stable:
> 
> commit 62bdf94a2049822ef8c6d4b0e83cd9c3a1663ab4
> Author:     Chuck Lever <chuck.lever@oracle.com>
> AuthorDate: Mon Nov 7 16:16:24 2016 -0500
> Commit:     Anna Schumaker <Anna.Schumaker@Netapp.com>
> CommitDate: Thu Nov 10 11:04:54 2016 -0500
> 
>     xprtrdma: Fix DMAR failure in frwr_op_map() after reconnect
> 
> This commit is needed to prevent DMAR errors during a spurious
> RDMA connection close. Problem reported by Vasco Steinmetz.
> 
> To apply 62bdf94a cleanly to v4.8.7, please first apply this
> one-line clean-up commit:
> 
> commit 5690a22d8612e1788b48b4ea53c59868589cd2db
> Author:     Daniel Wagner <daniel.wagner@bmw-carit.de>
> AuthorDate: Fri Sep 23 10:41:57 2016 +0200
> Commit:     Anna Schumaker <Anna.Schumaker@Netapp.com>
> CommitDate: Fri Sep 23 09:48:24 2016 -0400
> 
>     xprtrdma: use complete() instead complete_all()
> 
> 

All now queued up, thanks.

greg k-h
