Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:41633 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934984Ab3DJPUB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Apr 2013 11:20:01 -0400
Date: Wed, 10 Apr 2013 11:19:53 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 13/19] NFSD: Server implementation of MAC Labeling
Message-ID: <20130410151953.GC24404@pad.fieldses.org>
References: <1364939160-20874-1-git-send-email-SteveD@redhat.com>
 <1364939160-20874-14-git-send-email-SteveD@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1364939160-20874-14-git-send-email-SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 02, 2013 at 05:45:54PM -0400, Steve Dickson wrote:
> +__be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
> +		struct nfs4_label *label)
> +{
> +	return -EOPNOTSUPP;

Anything that returns a __be32 is expecting nfserr_something, not
-ERRNO.

I made the same comment on a previous review:

	http://www.spinics.net/lists/linux-nfs/msg36104.html

Please keep a careful list of these review comments!

--b.
