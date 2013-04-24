Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40416 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758005Ab3DXVyR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Apr 2013 17:54:17 -0400
Date: Wed, 24 Apr 2013 17:54:11 -0400
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 01/17] NFSv4.2: Added v4.2 error codes
Message-ID: <20130424215411.GL20275@fieldses.org>
References: <1366834683-29075-1-git-send-email-SteveD@redhat.com>
 <1366834683-29075-2-git-send-email-SteveD@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1366834683-29075-2-git-send-email-SteveD@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 24, 2013 at 04:17:47PM -0400, Steve Dickson wrote:
> From: Steve Dickson <steved@redhat.com>

This seems uncontroversial; applying to 3.10 absent any objections,
except:

> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  fs/nfsd/nfsd.h       | 6 ++++++
>  fs/nfsd/nfsproc.c    | 1 +
>  include/linux/nfs4.h | 8 ++++++++
>  3 files changed, 15 insertions(+)
> 
> diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
> index 07a473f..553b230 100644
> --- a/fs/nfsd/nfsd.h
> +++ b/fs/nfsd/nfsd.h
> @@ -243,6 +243,12 @@ void		nfsd_lockd_shutdown(void);
>  #define nfserr_reject_deleg		cpu_to_be32(NFS4ERR_REJECT_DELEG)
>  #define nfserr_returnconflict		cpu_to_be32(NFS4ERR_RETURNCONFLICT)
>  #define nfserr_deleg_revoked		cpu_to_be32(NFS4ERR_DELEG_REVOKED)
> +#define nfserr_partner_notsupp		cpu_to_be32(NFS4ERR_PARTNER_NOTSUPP)
> +#define nfserr_partner_no_auth		cpu_to_be32(NFS4ERR_PARTNER_NO_AUTH)
> +#define nfserr_metadata_notsupp		cpu_to_be32(NFS4ERR_METADATA_NOTSUPP)
> +#define nfserr_offload_denied		cpu_to_be32(NFS4ERR_OFFLOAD_DENIED)
> +#define nfserr_wrong_lfs		cpu_to_be32(NFS4ERR_WRONG_LFS)
> +#define nfs4err_badlabel		cpu_to_be32(NFS4ERR_BADLABEL)
>  
>  /* error codes for internal use */
>  /* if a request fails due to kmalloc failure, it gets dropped.
> diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
> index 54c6b3d..85289a5 100644
> --- a/fs/nfsd/nfsproc.c
> +++ b/fs/nfsd/nfsproc.c
> @@ -743,6 +743,7 @@ nfserrno (int errno)
>  		{ nfserr_notsupp, -EOPNOTSUPP },
>  		{ nfserr_toosmall, -ETOOSMALL },
>  		{ nfserr_serverfault, -ESERVERFAULT },
> +		{ nfs4err_badlabel, -EMSGSIZE },

dropping this one chunk, it should probably go in patch 16/17 with the
other nfsd code.

--b.

>  	};
>  	int	i;
>  
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index 7b8fc73..377fb3f 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -219,6 +219,14 @@ enum nfsstat4 {
>  	NFS4ERR_REJECT_DELEG	= 10085,	/* on callback */
>  	NFS4ERR_RETURNCONFLICT	= 10086,	/* outstanding layoutreturn */
>  	NFS4ERR_DELEG_REVOKED	= 10087,	/* deleg./layout revoked */
> +
> +	/* nfs42 */
> +	NFS4ERR_PARTNER_NOTSUPP	= 10088,
> +	NFS4ERR_PARTNER_NO_AUTH	= 10089,
> +	NFS4ERR_METADATA_NOTSUPP = 10090,
> +	NFS4ERR_OFFLOAD_DENIED = 10091,
> +	NFS4ERR_WRONG_LFS = 10092,
> +	NFS4ERR_BADLABEL = 10093,
>  };
>  
>  static inline bool seqid_mutating_err(u32 err)
> -- 
> 1.8.1.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
