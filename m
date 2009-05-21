From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.29+ NFS-Server Problem "reconnect_path: npd != pd"
Date: Thu, 21 May 2009 13:32:13 -0400
Message-ID: <1242927133.6687.4.camel@heimdal.trondhjem.org>
References: <20090521142026.GA5566@geggus.net>
	 <1242924599.6687.1.camel@heimdal.trondhjem.org>
	 <20090521165751.GA4428@geggus.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:35766 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753163AbZEURcP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 May 2009 13:32:15 -0400
In-Reply-To: <20090521165751.GA4428-6gBBswh35yKsTnJN9+BGXg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-05-21 at 18:57 +0200, Sven Geggus wrote:
> Trond Myklebust schrieb am Donnerstag, den 21. Mai um 18:49 Uhr:
> 
> > I can't find any such error message in the kernel.
> 
> The message seems to come from fs/exportfs/expfs.c
> 
> > Is this the userland NFS server?
> 
> No, its not!
> 
> Sven

So what is the underlying filesystem that you are exporting, and what
does your /etc/exports file look like?

Trond

