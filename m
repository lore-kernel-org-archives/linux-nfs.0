Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:38795 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752517Ab3JXIph convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Oct 2013 04:45:37 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Christoph Anton Mitterer <calestyo@scientia.net>
CC: "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: XATTRs in NFS?
Date: Thu, 24 Oct 2013 08:45:35 +0000
Message-ID: <EFB2CFAD-FACC-401D-BF0C-1C573B23A873@netapp.com>
References: <1382560643.6924.12.camel@heisenberg.scientia.net>
In-Reply-To: <1382560643.6924.12.camel@heisenberg.scientia.net>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 23, 2013, at 9:37 PM, Christoph Anton Mitterer <calestyo@scientia.net> wrote:

> Hi.
> 
> I just wondered about the current situation (respectively plans)
> regarding XATTRs in NFS (I personally don't care much about the
> version,... of course v4 would be nice, but v3 should do either).
> 
> 
> I'm aware about the patches for v3 that James Morris has submitted some
> time ago, but AFAICS these were never accepted/merged.
> 
> Asking him (off-list) he mentioned that any such work would need to take
> place in NFS4.
> 
> 
> I've seen some comments from the past, saying that it should never
> happen since it would cause performance issues - but I guess one could
> make it optional.
> 
> 
> I have some use case where I need a network filesystem with XATTR
> support providing the features of most standard filesystems (locking,
> etc.).
> And I'm sure there are plenty more use-cases.
> 
> 
> So are there any plans to get this into NFS?
> 


labeled NFS (i.e. security labels for NFS) is already supported in Linux 3.10 and newer.

There are no plans to merge general purpose xattrs. Please just use an application-specific database.

Cheers
   Trond