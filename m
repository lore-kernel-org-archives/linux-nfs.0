From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 0/3] Intro: Better handling coarse-grained timestamps
Date: Wed, 16 Jan 2008 14:47:52 -0500
Message-ID: <1200512872.6932.8.camel@heimdal.trondhjem.org>
References: <20080115162658.GA18911@newbie.thebellsplace.net>
	 <20080116015526.GC26010@newbie.thebellsplace.net>
	 <1200449912.28088.22.camel@heimdal.trondhjem.org>
	 <Pine.BSO.4.64.0801161211340.25972@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Bob Bell <b_linuxnfs-Y/+76LoPTq9wBoktGHYdvgC/G2K4zDHf@public.gmane.org>, linux-nfs@vger.kernel.org
To: "david m. richter" <richterd@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:42593 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751598AbYAPTr5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jan 2008 14:47:57 -0500
In-Reply-To: <Pine.BSO.4.64.0801161211340.25972@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-01-16 at 12:16 -0500, david m. richter wrote:
> 	so then, would it instead be correct to say that the negative 
> dentry caching on the client afforded by the delegation is beneficial 
> insofar as it obviates the client's need to revalidate the file/directory 
> in question?  if so, i understand the flawed CTO wording and will fix the 
> wiki.

Delegations give you a guarantee that the directory contents (i.e. the
readdir() information) have not changed, and so the client no longer
needs to poll the directory for change information.

IOW: specifically they allow the client to optimise away the GETATTR
call in opendir(), and they allow it to optimise away most of
nfs_lookup_revalidate().

Cheers
  Trond

