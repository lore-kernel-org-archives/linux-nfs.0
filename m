From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/1] update Documentation/filesystems/00-INDEX with new
	nfsd related docs.
Date: Tue, 28 Apr 2009 12:55:11 -0400
Message-ID: <20090428165511.GR17891@fieldses.org>
References: <1239129937-14669-1-git-send-email-bhalevy@panasas.com> <49DBA235.3070602@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	James Lentini <jlentini@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:42901 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754190AbZD1QzN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2009 12:55:13 -0400
In-Reply-To: <49DBA235.3070602@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applied.--b.

On Tue, Apr 07, 2009 at 09:57:57PM +0300, Benny Halevy wrote:
> On Apr. 07, 2009, 21:45 +0300, Benny Halevy <bhalevy@panasas.com> wrote:
> 
> Sorry, pls add:
> 
> Cc: James Lentini <jlentini@netapp.com>
> 
> > Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> > ---
> >  Documentation/filesystems/00-INDEX |    4 ++++
> >  1 files changed, 4 insertions(+), 0 deletions(-)
> > 
> > diff --git a/Documentation/filesystems/00-INDEX b/Documentation/filesystems/00-INDEX
> > index 52cd611..d3cc954 100644
> > --- a/Documentation/filesystems/00-INDEX
> > +++ b/Documentation/filesystems/00-INDEX
> > @@ -66,6 +66,10 @@ mandatory-locking.txt
> >  	- info on the Linux implementation of Sys V mandatory file locking.
> >  ncpfs.txt
> >  	- info on Novell Netware(tm) filesystem using NCP protocol.
> > +nfs41-server.txt
> > +	- info on the Linux server implementation of NFSv4 minor version 1.
> > +nfs-rdma.txt
> > +	- how to install and setup the Linux NFS/RDMA client and server software.
> >  nfsroot.txt
> >  	- short guide on setting up a diskless box with NFS root filesystem.
> >  ntfs.txt
