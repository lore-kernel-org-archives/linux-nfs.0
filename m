Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:38264 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754393Ab3BQOgx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 17 Feb 2013 09:36:53 -0500
Message-ID: <5120EABE.1040207@panasas.com>
Date: Sun, 17 Feb 2013 16:35:42 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Michael Monnerie <lists.michael.monnerie@is.it-management.at>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: How to make clients NOT block
References: <680509590.JPpPf8D3KZ@saturn>
In-Reply-To: <680509590.JPpPf8D3KZ@saturn>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/16/2013 01:30 PM, Michael Monnerie wrote:
> Dear list,
> 
> we've had several servers block today because they all have a NFS mount point 
> from a linux kernel 3.7.6 server. This is the fstab entry:
> 
> 1.1.1.1:/nfsshare/all /shared nfs4 defaults,tcp,intr,relatime,async,acl 0 9
> 
> The NFS server crashed and was offline, that made all clients block. Even 
> after the NFS server was up again, most clients were stuck to the point they 
> had to be rebooted. What mount options should we use so clients don't block 
> completely when the NFS server is gone? It's no problem to unmount the NFS 
> share, or get errors, but the clients must not stop their work.
> 

It's the "-o soft" mount option to mount or fstab. Note that it will unstuck
you at most operations, after a timeout the Applications will receive EIO.

("most", because rarely it'll D state anyway)

Cheers
Boaz

