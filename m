Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:32994 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758738Ab3DYS0N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Apr 2013 14:26:13 -0400
Date: Thu, 25 Apr 2013 14:26:10 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 03/17] NFSDv4.2: Added NFS v4.2 support to the NFS server
Message-ID: <20130425182610.GB5049@fieldses.org>
References: <1366834683-29075-1-git-send-email-SteveD@redhat.com>
 <1366834683-29075-4-git-send-email-SteveD@redhat.com>
 <20130424220226.GN20275@fieldses.org>
 <5179396C.3070900@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5179396C.3070900@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 25, 2013 at 10:10:52AM -0400, Steve Dickson wrote:
> On 24/04/13 18:02, J. Bruce Fields wrote:
> > On Wed, Apr 24, 2013 at 04:17:49PM -0400, Steve Dickson wrote:
> >> From: Steve Dickson <steved@redhat.com>
> >>
> >> This enable NFSv4.2 support for the server. To enable this
> >> code do the following:
> >>   echo "+4.2" >/proc/fs/nfsd/versions
> >>
> >> after the nfsd kernel module is loaded.
> >>
> >> Signed-off-by: Steve Dickson <steved@redhat.com>
> >> ---
> >>  fs/nfsd/nfs4xdr.c | 1 +
> >>  fs/nfsd/nfsd.h    | 7 ++++++-
> >>  2 files changed, 7 insertions(+), 1 deletion(-)
> >>
> >> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> >> index a272007..b38de7a 100644
> >> --- a/fs/nfsd/nfs4xdr.c
> >> +++ b/fs/nfsd/nfs4xdr.c
> >> @@ -1572,6 +1572,7 @@ struct nfsd4_minorversion_ops {
> >>  static struct nfsd4_minorversion_ops nfsd4_minorversion[] = {
> >>  	[0] = { nfsd4_dec_ops, ARRAY_SIZE(nfsd4_dec_ops) },
> >>  	[1] = { nfsd41_dec_ops, ARRAY_SIZE(nfsd41_dec_ops) },
> >> +	[2] = { nfsd41_dec_ops, ARRAY_SIZE(nfsd41_dec_ops) },
> >>  };
> >>  
> >>  static __be32
> >> diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
> >> index 553b230..b5eade7 100644
> >> --- a/fs/nfsd/nfsd.h
> >> +++ b/fs/nfsd/nfsd.h
> >> @@ -24,7 +24,7 @@
> >>  /*
> >>   * nfsd version
> >>   */
> >> -#define NFSD_SUPPORTED_MINOR_VERSION	1
> >> +#define NFSD_SUPPORTED_MINOR_VERSION	2
> >>  /*
> >>   * Maximum blocksizes supported by daemon under various circumstances.
> >>   */
> > 
> > These last two chunks belong with a later patch, whenever we make other
> > 4.2 attribute changes:
> I'm a bit confused by this request... 
> 
> The purpose of this patch is to allow echo "+4.2" >/proc/fs/nfsd/versions 
> to work. Basically enabling the setting of the v4.2. Without the above two chunks 
> that echo will fail which means v4.2 can not be set.

Right by "last two chunks" I meant the below.--b.

> 
> Plus the two chunks below are where the generic 4.2 attribute changes are 
> made:
> >> @@ -328,6 +328,8 @@ void		nfsd_lockd_shutdown(void);
> >>  #define NFSD4_1_SUPPORTED_ATTRS_WORD2 \
> >>  	(NFSD4_SUPPORTED_ATTRS_WORD2 | FATTR4_WORD2_SUPPATTR_EXCLCREAT)
> >>  
> >> +#define NFSD4_2_SUPPORTED_ATTRS_WORD2 0
> >> +
> >>  static inline u32 nfsd_suppattrs0(u32 minorversion)
> >>  {
> >>  	return minorversion ? NFSD4_1_SUPPORTED_ATTRS_WORD0
> >> @@ -342,6 +344,9 @@ static inline u32 nfsd_suppattrs1(u32 minorversion)
> >>  
> >>  static inline u32 nfsd_suppattrs2(u32 minorversion)
> >>  {
> >> +	if (minorversion == 2)
> >> +		return NFSD4_2_SUPPORTED_ATTRS_WORD2;
> >> +
> >>  	return minorversion ? NFSD4_1_SUPPORTED_ATTRS_WORD2
> >>  			    : NFSD4_SUPPORTED_ATTRS_WORD2;
> >>  }
> Now in the [PATCH 16/17] NFSD: Server implementation of MAC Labeling
> patch is where the definition of NFSD4_2_SUPPORTED_ATTRS_WORD2
> changes when labels are enabled.
> 
> So it seems to me this patch does want you wanted it to do.
> Enable the setting of v4.2 and only return 4.2 attributes 
> on a v4.2 mount. It's just at this point there are no 4.2
> attributes defined...
> 
> What am I missing?
> 
> steved.
>  
>  
