Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54578 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756912Ab1E3O6m convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 May 2011 10:58:42 -0400
Subject: Re: infinite getdents64 loop
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Ruediger Meier <sweet_f_a@gmx.de>
Cc: linux-nfs@vger.kernel.org
Date: Mon, 30 May 2011 10:58:41 -0400
In-Reply-To: <201105301137.02061.sweet_f_a@gmx.de>
References: <201105281502.32719.sweet_f_a@gmx.de>
	 <201105291855.04487.sweet_f_a@gmx.de>
	 <1306688643.2386.24.camel@lade.trondhjem.org>
	 <201105301137.02061.sweet_f_a@gmx.de>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1306767521.5971.2.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-05-30 at 11:37 +0200, Ruediger Meier wrote: 
> On Sunday 29 May 2011, Trond Myklebust wrote:
> > It's actually a problem with the underlying filesystem: it is
> > generating readdir 'offsets' that are not unique. In other words, if
> 
> Does this mean ext4 generally does not work with for nfs?

ext2/3/4 are all known to have this problem when you switch on the
hashed b-tree directories. Typically, a directory with a million entries
will have several tens of cookie collisions.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

