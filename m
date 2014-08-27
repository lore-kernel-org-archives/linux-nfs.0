Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49849 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935462AbaH0T3w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Aug 2014 15:29:52 -0400
Date: Wed, 27 Aug 2014 15:29:50 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: bjschuma@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] NFSD: Implement SEEK
Message-ID: <20140827192950.GE13910@fieldses.org>
References: <1409152678-7806-1-git-send-email-bjschuma@netapp.com>
 <1409152678-7806-4-git-send-email-bjschuma@netapp.com>
 <20140827190940.GD13910@fieldses.org>
 <53FE2FB2.3040606@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <53FE2FB2.3040606@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 27, 2014 at 03:21:22PM -0400, Anna Schumaker wrote:
> On 08/27/2014 03:09 PM, J. Bruce Fields wrote:
> > On Wed, Aug 27, 2014 at 11:17:58AM -0400, bjschuma@netapp.com wrote:
> >> From: Anna Schumaker <Anna.Schumaker@netapp.com>
> >>
> >> This patch adds server support for the NFS v4.2 operation SEEK, which
> >> returns the position of the next hole or data segment in a file.  This
> >> operation is off by default, and needs CONFIG_NFSD_V4_2_SEEK=y to be
> >> compiled.
> >>
> >> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> >> ---
> >>  fs/nfsd/Kconfig      | 12 ++++++++++++
> >>  fs/nfsd/nfs4proc.c   | 47 +++++++++++++++++++++++++++++++++++++++++++++++
> >>  fs/nfsd/nfs4xdr.c    | 45 +++++++++++++++++++++++++++++++++++++++++++++
> >>  fs/nfsd/xdr4.h       | 14 ++++++++++++++
> >>  include/linux/nfs4.h |  5 +++++
> >>  5 files changed, 123 insertions(+)
> >>
> >> diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
> >> index f994e75..804b20a 100644
> >> --- a/fs/nfsd/Kconfig
> >> +++ b/fs/nfsd/Kconfig
> >> @@ -81,6 +81,18 @@ config NFSD_V4
> >>  
> >>  	  If unsure, say N.
> >>  
> >> +config NFSD_V4_2_SEEK
> >> +	bool "Enable SEEK support for the NFS v4.2 server"
> >> +	depends on NFSD_V4
> >> +	help
> >> +	  Say Y here if you want to enable support for the NFS v4.2 operation
> >> +	  SEEK, which adds in SEEK_HOLE and SEEK_DATA support.
> >> +
> >> +	  WARNING: there is still a chance of backwards-incompatible protocol
> >> +	  changes.  This feature is targeted at developers and testers only.
> > 
> > I think now that we should instead confirm with the working group that
> > backwards-incompatible changes are done, and skip this warning.
> > 
> > I'll remove it in the labeled NFS case, which we've decided is "done"
> > even if the rest of the 4.2 draft isn't.
> > 
> > I also wonder if we should ditch these configuration options, or keep
> > them only temporarily.  It's not much code, so I think the only reason
> > to allow configuring it out is to temporarily protect people from
> > immature code.
> 
> I was expecting them to be temporary, and to get removed when the draft becomes an RFC.
> 
> > 
> >> +
> >> +	  If unsure, say N.
> >> +
> >>  config NFSD_V4_SECURITY_LABEL
> >>  	bool "Provide Security Label support for NFSv4 server"
> >>  	depends on NFSD_V4 && SECURITY
> >> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> >> index 5e0dc52..f555eb2 100644
> >> --- a/fs/nfsd/nfs4proc.c
> >> +++ b/fs/nfsd/nfs4proc.c
> >> @@ -1013,6 +1013,45 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >>  	return status;
> >>  }
> >>  
> >> +#ifdef CONFIG_NFSD_V4_2_SEEK
> >> +static __be32
> >> +nfsd4_seek(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >> +		struct nfsd4_seek *seek)
> >> +{
> >> +	struct file *file;
> >> +	__be32 status = nfs_ok;
> >> +
> >> +	status = nfs4_preprocess_stateid_op(SVC_NET(rqstp), cstate,
> >> +					    &seek->seek_stateid,
> >> +					    RD_STATE | WR_STATE, &file);
> > 
> > I think that should be just RD_STATE.
> 
> I was trying to cover the case where an application does:
> 
> 	open(WRITE);
> 	seek(HOLE);
> 	write("blah");
> 
> I can change the code if that's not the way people use SEEK_HOLE / SEEK_DATA ...

Note nfsd4_read() for example passes RD_STATE here.  It means "I'm doing
a read-like operation", not "I can only use a read open".

--b.
