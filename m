Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:43292 "EHLO
	bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755154Ab3EFPxj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 May 2013 11:53:39 -0400
Message-ID: <1367855617.1868.16.camel@dabdike>
Subject: Re: [PATCH 00/17] lnfs: linux-3.9 release
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Ric Wheeler <rwheeler@redhat.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>, Jack Rieden <jrieden@redhat.com>
Date: Mon, 06 May 2013 08:53:37 -0700
In-Reply-To: <51848BE0.2080901@redhat.com>
References: <1367515151-31015-1-git-send-email-SteveD@redhat.com>
	 <51848BE0.2080901@redhat.com>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2013-05-04 at 07:17 +0300, Ric Wheeler wrote:
> On 05/02/2013 08:18 PM, Steve Dickson wrote:
> > From: Steve Dickson <steved@redhat.com>
> >
> > Here is an the next rlease of the label NFS patches
> > ported to the linux-3.9 release
> >
> > The following changes were made from the previous release.
> > (Note, only the server patch changed in this release)
> >
> > * Remove the buffer overflow in the allocation of labels.
> >
> > * Removed needless char * casting
> >
> > * Removed the -EMSGSIZE to nfs4err_badlabel errno mapping
> >    by changing the return value of nfsd4_label_alloc() to
> >    be a _be32 value.
> 
> It would be great to see this patch series land in time for 3.10 - seems like a 
> major feature that has had been held in development for years and it does have a 
> very interested user base waiting for this to land.
> 
> Are there any existing roadblocks to having this make it this merge
> window?

You mean other than the one Bruce and Trond already mentioned and which
you presumably already read? i.e. it's a large feature whose final
incarnation landed when the merge window was already open which by
process should receive incubation in linux-next before being merged.

It is entirely within the gift of the maintainers to vary the incubation
requirements, but if they do and it comes back with a ton of problems
from the 0 day project or smatch or even a build failure that would have
been picked up by linux-next, they'll be at the wrong end of Linus'
flame thrower not you.  So it is rather unfair to pressure the
maintainers like this.

Kernel processes exist for a reason and almost every maintainer has the
scars that remind them of this.

James


