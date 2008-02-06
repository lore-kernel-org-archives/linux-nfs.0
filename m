From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS performance (Currently 2.6.20)
Date: Wed, 06 Feb 2008 10:18:16 -0500
Message-ID: <1202311096.12647.28.camel@heimdal.trondhjem.org>
References: <3093.195.41.66.226.1202292274.squirrel@mail.jabbernet.dk>
	 <47A9C620.70106@oxeva.fr>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jesper Krogh <jesper-Q2TZfHgGEy4@public.gmane.org>, linux-nfs@vger.kernel.org
To: Gabriel Barazer <gabriel-KSe8qvLY914@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:58104 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751665AbYBFPSY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Feb 2008 10:18:24 -0500
In-Reply-To: <47A9C620.70106-KSe8qvLY914@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-02-06 at 15:37 +0100, Gabriel Barazer wrote:

> > 
> > Should I go for NFSv2 (default if I dont change mount options) NFSv3 ? or
> > NFSv4
> 
> NFSv2/3 have nearly the same performance

Only if you shoot yourself in the foot by setting the 'async' flag
in /etc/exports. Don't do that...

Most people will want to use NFSv3 for performance reasons. Unlike NFSv2
with 'async', NFSv3 with the 'sync' export flag set actually does _safe_
server-side caching of writes.

Trond

