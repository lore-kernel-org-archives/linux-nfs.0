Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53912 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752290Ab3DWToH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Apr 2013 15:44:07 -0400
Date: Tue, 23 Apr 2013 15:44:04 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 13/19] NFSD: Server implementation of MAC Labeling
Message-ID: <20130423194404.GH20622@pad.fieldses.org>
References: <1364939160-20874-1-git-send-email-SteveD@redhat.com>
 <1364939160-20874-14-git-send-email-SteveD@redhat.com>
 <20130410151953.GC24404@pad.fieldses.org>
 <5176E3BB.4020508@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5176E3BB.4020508@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 23, 2013 at 03:40:43PM -0400, Steve Dickson wrote:
> 
> 
> On 10/04/13 11:19, J. Bruce Fields wrote:
> > On Tue, Apr 02, 2013 at 05:45:54PM -0400, Steve Dickson wrote:
> >> +__be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
> >> +		struct nfs4_label *label)
> >> +{
> >> +	return -EOPNOTSUPP;
> > 
> > Anything that returns a __be32 is expecting nfserr_something, not
> > -ERRNO.
> > 
> I think it makes sense when label are not configured for this to
> return nfserr_notsupp which will then get turned into a -EOPNOTSUPP, 
> agreed?

Right though as I've said on previous review really this should be
caught by fs/nfsd/nfs4proc.c:check_attr_support() which is called just
before nfsd4_set_nfs4_label() in nfsd4_setattr().

--b.
