Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12270 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760008Ab0JZR2W convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Oct 2010 13:28:22 -0400
Subject: Re: [PATCH] NFS: rename idmapper components
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Bryan Schumaker <bjschuma@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <20101026172016.GA526@fieldses.org>
References: <4CC6D4F9.3040402@netapp.com>
	 <1288100354.9435.5.camel@heimdal.trondhjem.org>
	 <20101026172016.GA526@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 26 Oct 2010 13:27:18 -0400
Message-ID: <1288114038.12370.8.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-10-26 at 13:20 -0400, J. Bruce Fields wrote:
> On Tue, Oct 26, 2010 at 09:39:14AM -0400, Trond Myklebust wrote:
> > On Tue, 2010-10-26 at 09:17 -0400, Bryan Schumaker wrote:
> > > This patch renames the idmapper upcall program from nfs.upcall to nfs.idmap.
> > > It also changes the key type from id_resolver to nfs_idmap.
> ...
> > We should _not_ be doing this kind of user space api change after the
> > code has been merged by Linus.
> > 
> > I don't mind a patch to the documentation that changes 'nfs.upcall' to
> > match the name given in nfs-utils, but it is too late to change the name
> > 'id_resolver': that should have been done before the merge window.
> 
> There's precedent for fixing new interfaces before the final release, so
> it seems unlikely to be a huge problem before -rc1.
> 
> Though agreed that there should still be a higher standard for changes
> made after the moment the interface is merged--and a slightly
> inconsistent name may not meet the standard....

The name isn't really inconsistent: we use "dns_resolver" for the DNS
upcall types, so "id_resolver" shouldn't really be a problem...

Trond

