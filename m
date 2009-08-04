From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: ->migratepage aops for nfs missing
Date: Tue, 04 Aug 2009 16:53:06 -0400
Message-ID: <1249419186.5377.20.camel@heimdal.trondhjem.org>
References: <20090804202648.GA12484@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>,
	David Howells <dhowells@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6819 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932281AbZHDUyP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Aug 2009 16:54:15 -0400
In-Reply-To: <20090804202648.GA12484-u0/ZJuX+froe6aEkudXLsA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-08-04 at 22:26 +0200, Andi Kleen wrote:
> Trond,
> 
> Any particular reason ->migratepage is not enabled for 
> the nfs file aops?
> 
> Is it known to be unsafe to move NFS buffer pages at runtime?
> 
> I have a similar requirement for memory error handling.
> 
> Thanks,
> 
> -Andi

Hi Andi,

I don't think there are any fundamental problems with migrating NFS page
cache pages. In order to handle dirty pages, we'd need to write the
equivalent of buffer_migrate_page() in order to transfer the private
data, lock and update the 'struct nfs_page' that tracks the page's dirty
area.

The only thing I'm not 100% sure about is fscache, but I think the
correct thing is just to call nfs_fscache_release_page(). David?

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
