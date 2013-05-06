Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:44038 "EHLO
	bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756421Ab3EFUZh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 May 2013 16:25:37 -0400
Message-ID: <1367871935.1868.48.camel@dabdike>
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
Date: Mon, 06 May 2013 13:25:35 -0700
In-Reply-To: <51880B01.5040907@redhat.com>
References: <1367515151-31015-1-git-send-email-SteveD@redhat.com>
	  <51848BE0.2080901@redhat.com> <1367855617.1868.16.camel@dabdike>
	 <51880B01.5040907@redhat.com>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-05-06 at 22:56 +0300, Ric Wheeler wrote:
> On 05/06/2013 06:53 PM, James Bottomley wrote:
> > On Sat, 2013-05-04 at 07:17 +0300, Ric Wheeler wrote:
> >> On 05/02/2013 08:18 PM, Steve Dickson wrote:
> >>> From: Steve Dickson <steved@redhat.com>
> >>>
> >>> Here is an the next rlease of the label NFS patches
> >>> ported to the linux-3.9 release
> >>>
> >>> The following changes were made from the previous release.
> >>> (Note, only the server patch changed in this release)
> >>>
> >>> * Remove the buffer overflow in the allocation of labels.
> >>>
> >>> * Removed needless char * casting
> >>>
> >>> * Removed the -EMSGSIZE to nfs4err_badlabel errno mapping
> >>>     by changing the return value of nfsd4_label_alloc() to
> >>>     be a _be32 value.
> >> It would be great to see this patch series land in time for 3.10 - seems like a
> >> major feature that has had been held in development for years and it does have a
> >> very interested user base waiting for this to land.
> >>
> >> Are there any existing roadblocks to having this make it this merge
> >> window?
> > You mean other than the one Bruce and Trond already mentioned and which
> > you presumably already read? i.e. it's a large feature whose final
> > incarnation landed when the merge window was already open which by
> > process should receive incubation in linux-next before being merged.
> >
> > It is entirely within the gift of the maintainers to vary the incubation
> > requirements, but if they do and it comes back with a ton of problems
> > from the 0 day project or smatch or even a build failure that would have
> > been picked up by linux-next, they'll be at the wrong end of Linus'
> > flame thrower not you.  So it is rather unfair to pressure the
> > maintainers like this.
> >
> > Kernel processes exist for a reason and almost every maintainer has the
> > scars that remind them of this.
> >
> > James
> >
> >
> 
> Don't worry James - this one has had at least as much testing as the average 
> SCSI driver update :)
> 
> This is was not meant as pressure, James Morris (not you) had replied that his 
> patches are ready and he expected them to be pulled via the NFS trees.

Yes, I know this ... Trond and Bruce both said definitely 3.11 and
probably 3.11 respectively, that's why I was surprised to see a 3.10
request.

> This was meant to facilitate getting this multi-tree, multi-maintainer series 
> ready to merge and make sure we aren't stuck each waiting for a response from 
> the next person in the loop.
> 
> Note that this patch set has been in development for *years*, been tested at 
> connectathon, tested by interested parties who promoted the earliest versions of 
> the patches and tested by RHEL (of course, the series has evolved over time).

That's good, but not sufficient.  A large number of "well tested" big
patch sets have failed integration nastily when they were merged over
the years.  That wasn't because they weren't actually tested, but
because as soon as they hit the tree, they caused side effects, or
people tried configurations the submitters hadn't or because they tried
tests the submitters hadn't thought of.  This is why we have an
integration process involving linux-next ... to try and find these types
of problems *before* merger and that's why large features tend to spend
at least a week in linux-next to try to find the issues.

James


