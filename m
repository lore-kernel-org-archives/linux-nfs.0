From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: atimes not updated over NFS
Date: Wed, 09 Jan 2008 18:31:05 -0500
Message-ID: <1199921465.7638.5.camel@heimdal.trondhjem.org>
References: <20080109101313.GG9212@aym.net2.nerim.net>
	 <1199892437.11141.2.camel@heimdal.trondhjem.org>
	 <20080109223748.GH9212@aym.net2.nerim.net>
	 <1199920996.7638.3.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Andre Majorel <aym-xunil-Bi/FLWfhfolQFI55V6+gNQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:47447 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756080AbYAIXbJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Jan 2008 18:31:09 -0500
In-Reply-To: <1199920996.7638.3.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-01-09 at 18:23 -0500, Trond Myklebust wrote:
> On Wed, 2008-01-09 at 23:37 +0100, Andre Majorel wrote:
> > I'll take your word for it. However, let me assure you that atimes
> > somehow used to work over NFS, even for files small enough to fit
> > in the cache. Had they been broken, I would have known. I use Mutt.
> 
> How would the server know to update the atime? If the file is in cache
> we don't READ.

Put differently. Have you checked on the _server_ that the atime is
actually changing when you do these tests on the client?

Trond

