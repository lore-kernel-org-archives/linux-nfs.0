Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx61.netapp.com ([216.240.31.181]:52522 "EHLO mx61.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752753AbeCUTgM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 21 Mar 2018 15:36:12 -0400
Subject: Re: linux-next: please clean up the nfs-anna tree
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        Trond Myklebust <trond.myklebust@fys.uio.no>,
        NFS Mailing List <linux-nfs@vger.kernel.org>
CC: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
References: <20180321111140.618e1e6c@canb.auug.org.au>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <df592a0d-8318-7a7c-386c-07838351524a@Netapp.com>
Date: Wed, 21 Mar 2018 15:36:02 -0400
MIME-Version: 1.0
In-Reply-To: <20180321111140.618e1e6c@canb.auug.org.au>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/20/2018 08:11 PM, Stephen Rothwell wrote:
> Hi all,
> 
> It only seems to contain commits that have been upsreamed as different
> commits and is causing conflicts:
> 
> CONFLICT (content): Merge conflict in net/sunrpc/xprtrdma/transport.c
> CONFLICT (content): Merge conflict in net/sunrpc/xprt.c

Sorry about that!  I've updated the tree, and added in patches for 4.17 while I was at it

Anna
> 
