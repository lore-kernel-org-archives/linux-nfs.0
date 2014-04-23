Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([209.166.131.148]:32918 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752835AbaDWMzR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Apr 2014 08:55:17 -0400
Message-ID: <5357B827.8040506@panasas.com>
Date: Wed, 23 Apr 2014 15:55:03 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 00/17] NFS: Create a common path used by reads and writes
References: <1397768981-12856-1-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1397768981-12856-1-git-send-email-Anna.Schumaker@Netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/18/2014 12:09 AM, Anna Schumaker wrote:
> I noticed that much of the read and write code was almost identical, with
> only minor differences in argument types and names.  These patches seek to
> unify these two codepaths wherever possible in order to make future changes
> easier.
> 
> Table of contents:
> 	Patches 01 - 05: Set up common data structures.
> 	Patches 06 - 10: Set up a shared rpc_call_ops struct.
> 	Patches 11 - 15: Set up a shared nfs_pageio_ops struct.
> 
> Some of the commit setup was moved into common code, but I'm willing to
> move this back into write.c if this looks to be a problem.
> 
> Future work:
> 	I have rough pNFS patches that don't currently apply.  They need
> 	more testing, and I figured this was enough code churn already.
> 
> Testing:
> 	I tested every version of NFS using the cthon and xfs tests without
> 	hitting anything new.  Any extra testing would be great seeing how
> 	the read and write paths are vitally important.
> 
> Questions?  Comments?  Death threats?
> 
> Anna

Good god. Anna did I already tell you that I like you a lot.

This "Identical code but the name" bothered me so much, to no end,
for so long. I envy you that you got to do it finally and so simple
it is.

After you are done there is bunch of code coalescing to do at
pnfs-objects as well. which will be real fun.

Thanks for doing this. Looks very good so far, yes please keep
it on a public tree for quick testing. Perhaps ask Trond to keep
it on his tree in a branch. (So to get some coverage under the linux-next
tree mongers from Intel)

real real cool, spring day
Boaz

