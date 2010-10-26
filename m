Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34164 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754279Ab0JZRUU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Oct 2010 13:20:20 -0400
Date: Tue, 26 Oct 2010 13:20:17 -0400
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Bryan Schumaker <bjschuma@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: rename idmapper components
Message-ID: <20101026172016.GA526@fieldses.org>
References: <4CC6D4F9.3040402@netapp.com>
 <1288100354.9435.5.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1288100354.9435.5.camel@heimdal.trondhjem.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Oct 26, 2010 at 09:39:14AM -0400, Trond Myklebust wrote:
> On Tue, 2010-10-26 at 09:17 -0400, Bryan Schumaker wrote:
> > This patch renames the idmapper upcall program from nfs.upcall to nfs.idmap.
> > It also changes the key type from id_resolver to nfs_idmap.
...
> We should _not_ be doing this kind of user space api change after the
> code has been merged by Linus.
> 
> I don't mind a patch to the documentation that changes 'nfs.upcall' to
> match the name given in nfs-utils, but it is too late to change the name
> 'id_resolver': that should have been done before the merge window.

There's precedent for fixing new interfaces before the final release, so
it seems unlikely to be a huge problem before -rc1.

Though agreed that there should still be a higher standard for changes
made after the moment the interface is merged--and a slightly
inconsistent name may not meet the standard....

--b.
