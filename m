Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41577 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754709AbaAFSot (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Jan 2014 13:44:49 -0500
Date: Mon, 6 Jan 2014 13:44:48 -0500
From: "J.,Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NFSD: fix compile warning without CONFIG_NFSD_V3
Message-ID: <20140106184448.GB31764@fieldses.org>
References: <CAB6yy34woYZaJ=k=Ga9iT_mmBWBiCUj1SprT=Se2SVrOu6YO_Q@mail.gmail.com>
 <5D65FDE6-D1AB-442C-BFD8-141AB87FF321@gmail.com>
 <CAB6yy379-A8fgLpQo+ppx5V93P9pXcabvmBJNTZ5hXxeJMuxBg@mail.gmail.com>
 <52C1577B.9080100@gmail.com>
 <52C15847.9030208@gmail.com>
 <68E6D30F-B2D6-4919-9748-E7F1162AC3B7@oracle.com>
 <52C2377E.8040006@gmail.com>
 <52C2536A.5070906@gmail.com>
 <20140103231800.GF5164@fieldses.org>
 <52CA22E9.9030802@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <52CA22E9.9030802@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 06, 2014 at 11:28:41AM +0800, Kinglong Mee wrote:
> Without CONFIG_NFSD_V3, compile will get warning as,
> 
> fs/nfsd/nfssvc.c: In function 'nfsd_svc':
> >> fs/nfsd/nfssvc.c:246:60: warning: array subscript is above array bounds [-Warray-bounds]
>         return (nfsd_versions[2] != NULL) || (nfsd_versions[3] != NULL);

Thanks, applying.

Though it might be simpler to define the array to always be length 4.

--b.

>                                                                ^
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfssvc.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index 55b5b57..9a4a5f9 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -243,7 +243,11 @@ static void nfsd_shutdown_generic(void)
>  
>  static bool nfsd_needs_lockd(void)
>  {
> +#if defined(CONFIG_NFSD_V3)
>  	return (nfsd_versions[2] != NULL) || (nfsd_versions[3] != NULL);
> +#else
> +	return (nfsd_versions[2] != NULL);
> +#endif
>  }
>  
>  static int nfsd_startup_net(int nrservs, struct net *net)
> -- 
> 1.8.4.2
