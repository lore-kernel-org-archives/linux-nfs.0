Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34807 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758467Ab0J1PkW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Oct 2010 11:40:22 -0400
Subject: Re: [PATCH] nfs-utils: add nfs.idmap
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <4CC9966B.1050103@netapp.com>
References: <4CC6CE30.90105@netapp.com> <4CC70D34.1060600@netapp.com>
	 <4CC99463.9000108@RedHat.com>  <4CC9966B.1050103@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Oct 2010 11:40:05 -0400
Message-ID: <1288280405.3194.44.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-10-28 at 11:27 -0400, Bryan Schumaker wrote:
> On 10/28/2010 11:18 AM, Steve Dickson wrote:
> > Hey Bryan,
> > 
> > A couple nits.... which I will be more than willing to take of... 
> > 
> > 1) I would like to change the binary name from nfs.idmap to nfsidmap
> >    which is consistent with how the rest of the binaries are named.
> >    (i.e. binary names generally don't have any '.' or '-' in them)
> >    
> > 2) Change the source directory from utils/nfs.idmap to 
> >    utils/idmap which again makes it consistent with what
> >    is already there. 
> 
> These both sounds reasonable to me.  I'll make a patch to modify the kernel documentation to reflect this.
> > 

We just sent in one patch to change the name in the kernel docs, now the
name is changing again?

Let's wait with this until an actual nfs-utils release is available, so
we can also update the 'Documentation/Changes' file with the new minimal
release version number.

Trond
