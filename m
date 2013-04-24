Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47523 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932071Ab3DXXEb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Apr 2013 19:04:31 -0400
Date: Wed, 24 Apr 2013 19:04:28 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 16/17] NFSD: Server implementation of MAC Labeling
Message-ID: <20130424230428.GT20275@fieldses.org>
References: <1366834683-29075-1-git-send-email-SteveD@redhat.com>
 <1366834683-29075-17-git-send-email-SteveD@redhat.com>
 <20130424212827.GK20275@fieldses.org>
 <51785962.7080008@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <51785962.7080008@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 24, 2013 at 06:14:58PM -0400, Steve Dickson wrote:
> On 24/04/13 17:28, J. Bruce Fields wrote:
> >> @@ -3231,11 +3340,13 @@ nfsd4_encode_setattr(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
> >> >  		WRITE32(2);
> >> >  		WRITE32(0);
> >> >  		WRITE32(0);
> >> > +		WRITE32(0);
> > Note that "2" above is the length of the bitmap field that follows.
> > 
> >> >  	}
> >> >  	else {
> >> >  		WRITE32(2);
> >> >  		WRITE32(setattr->sa_bmval[0]);
> >> >  		WRITE32(setattr->sa_bmval[1]);
> >> > +		WRITE32(setattr->sa_bmval[2]);
> > Ditto.
> Right... I did miss that....

With that change the pynfs tests all pass this time.

--b.

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 75b5b6d..7bbc698 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3310,13 +3310,13 @@ nfsd4_encode_setattr(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 
 	RESERVE_SPACE(12);
 	if (nfserr) {
-		WRITE32(2);
+		WRITE32(3);
 		WRITE32(0);
 		WRITE32(0);
 		WRITE32(0);
 	}
 	else {
-		WRITE32(2);
+		WRITE32(3);
 		WRITE32(setattr->sa_bmval[0]);
 		WRITE32(setattr->sa_bmval[1]);
 		WRITE32(setattr->sa_bmval[2]);
