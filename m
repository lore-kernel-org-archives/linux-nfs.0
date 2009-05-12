From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [stable] [PATCH] NFS: Fix the notifications when renaming onto
 an existing file
Date: Tue, 12 May 2009 18:42:40 -0400
Message-ID: <1242168160.5407.18.camel@heimdal.trondhjem.org>
References: <20090512222420.6972.25308.stgit@heimdal.trondhjem.org>
	 <20090512223105.GA16679@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: stable@kernel.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7337 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751980AbZELWmo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 May 2009 18:42:44 -0400
In-Reply-To: <20090512223105.GA16679@kroah.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-05-12 at 15:31 -0700, Greg KH wrote:
> On Tue, May 12, 2009 at 06:24:20PM -0400, Trond Myklebust wrote:
> > NFS appears to be returning an unnecessary "delete" notification when
> > we're doing an atomic rename. See
> > 
> >   http://bugzilla.gnome.org/show_bug.cgi?id=575684
> > 
> > The fix is to get rid of the redundant call to d_delete().
> > 
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > ---
> > Please apply to 2.6.27 - 2.6.29 stable series...
> 
> Is this already in Linus's tree?  If so, what is the git commit id?

Sorry, I forgot to include that. The commit id in mainline is
b1e4adf4ea41bb8b5a7bfc1a7001f137e65495df.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
