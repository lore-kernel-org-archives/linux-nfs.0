From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: next: build fails at fs/lockd/svclock.c
Date: Mon, 11 May 2009 14:46:00 -0400
Message-ID: <20090511184600.GD793@fieldses.org>
References: <a4423d670905040623q48eb552ft3bd107d6aa71d63b@mail.gmail.com> <1241444370.5754.5.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Beregalov <a.beregalov@gmail.com>,
	linux-next <linux-next@vger.kernel.org>,
	Felix Blyakher <felixb@sgi.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:35011 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752271AbZEKSqE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 May 2009 14:46:04 -0400
In-Reply-To: <1241444370.5754.5.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 04, 2009 at 09:39:30AM -0400, Trond Myklebust wrote:
> On Mon, 2009-05-04 at 17:23 +0400, Alexander Beregalov wrote:
> > Hi
> > 
> > Randconfig fails like this
> > 
> > fs/lockd/svclock.c: In function 'nlmsvc_freegrantargs':
> > fs/lockd/svclock.c:330: error: implicit declaration of function
> > 'locks_release_private'
> > 
> > caused by a9e61e25f9d2
> > (lockd: call locks_release_private to cleanup per-filesystem state)
> > 
> > 
> > # CONFIG_FILE_LOCKING is not set
> > CONFIG_LOCKD=y
> > --
> 
> See the posting "[PATCH v2] lockd: fix FILE_LOCKING=n build error" by
> Randy Dunlap last Tuesday.

What happened to this--is it in some maintainer's tree now?

--b.
