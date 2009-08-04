From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: ->migratepage aops for nfs missing
Date: Tue, 04 Aug 2009 18:06:34 -0400
Message-ID: <1249423594.12510.0.camel@heimdal.trondhjem.org>
References: <1249419186.5377.20.camel@heimdal.trondhjem.org>
	 <20090804202648.GA12484@basil.fritz.box>  <25558.1249423367@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andi Kleen <andi@firstfloor.org>, linux-nfs@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63988 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932893AbZHDWGo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Aug 2009 18:06:44 -0400
In-Reply-To: <25558.1249423367@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-08-04 at 23:02 +0100, David Howells wrote:
> Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> 
> > The only thing I'm not 100% sure about is fscache, but I think the
> > correct thing is just to call nfs_fscache_release_page(). David?
> 
> Yes, probably.  Note that that will only release the page unconditionally if
> gfp includes __GFP_WAIT.

Right, but I believe that migratepage does allow you to sleep, so that
shouldn't be a problem.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
