Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:42524 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935970Ab3DJUMI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Apr 2013 16:12:08 -0400
Date: Wed, 10 Apr 2013 16:12:05 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 19/19] NFSDv4.2: Added NFS v4.2 support to the NFS server
Message-ID: <20130410201205.GI24404@pad.fieldses.org>
References: <1364939160-20874-1-git-send-email-SteveD@redhat.com>
 <1364939160-20874-20-git-send-email-SteveD@redhat.com>
 <20130410152526.GD24404@pad.fieldses.org>
 <51658C23.5030805@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <51658C23.5030805@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 10, 2013 at 11:58:27AM -0400, Steve Dickson wrote:
> 
> 
> On 10/04/13 11:25, J. Bruce Fields wrote:
> > On Tue, Apr 02, 2013 at 05:46:00PM -0400, Steve Dickson wrote:
> >> From: Steve Dickson <steved@redhat.com>
> >>
> >> This enable NFSv4.2 support for the server. To enable this
> >> code do the following:
> >>   echo "+4.2" >/proc/fs/nfsd/versions
> > 
> > The patches are ordered strangely: labeled nFS support depends on 4.2
> > support, so we should be adding 4.2 support first, then labeled NFS
> > support on top of that.
> Seriously that actually matter?  So you want just commit the 4.2 and not
> not the label NFS patches? 

Yes, please, let's get that fixed on both the client and server, even
though, yes I expect we'll probably commit them all at once.

> > Note a 4.1 client shouldn't see the server return the new attribute as
> > supported unless it's using 4.2, and attempts to set it should error
> > out unless it's using 4.2.
> How is that handled with 4.0 vers 4.1? Just looking for a point to the code... 
I don't actually remember.  Grepping around....  Looks like it's mainly
the nfsd_suppattrs{0,1,2} functions in fs/nfsd/nfsd.h.

--b.
