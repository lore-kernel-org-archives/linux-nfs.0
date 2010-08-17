From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for August 9 (nfs)
Date: Tue, 17 Aug 2010 14:39:08 -0700
Message-ID: <4C6B017C.8030404@oracle.com>
References: <20100809132314.789e13f3.sfr@canb.auug.org.au>	 <20100809100856.b03a9bc1.randy.dunlap@oracle.com>	 <20100812091842.6a3b84b9.randy.dunlap@oracle.com>	 <1281634268.14329.18.camel@heimdal.trondhjem.org>	 <4C643136.5090808@oracle.com> <1282080208.12506.7.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:54057 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750746Ab0HQVl1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Aug 2010 17:41:27 -0400
In-Reply-To: <1282080208.12506.7.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/17/10 14:23, Trond Myklebust wrote:
> On Thu, 2010-08-12 at 10:36 -0700, Randy Dunlap wrote:
>> On 08/12/10 10:31, Trond Myklebust wrote:
>>> On Thu, 2010-08-12 at 09:18 -0700, Randy Dunlap wrote:
>>>> On Mon, 9 Aug 2010 10:08:56 -0700 Randy Dunlap wrote:
>>>>
>>>> ping??
>>>
>>> Hi Randy,
>>>
>>> I'm sorry. A heavy travel schedule is affecting my response time at the
>>> moment. I'll try to take care of this by Tuesday (when I get back home)
>>> if not before.
>>
>> No problem.  Just wanted to make sure that it's not lost.
> 
> Hi Randy,
> 
> How about the following fix?

Thanks, this fixes the build error.

Acked-by: Randy Dunlap <randy.dunlap@oracle.com>


> Cheers
>   Trond
> 
> ------------------------------------------------------------------------------------
> Subject: [PATCH] NFS: Fix the selection of security flavours in Kconfig
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Randy Dunlap reports:
> 
> ERROR: "svc_gss_principal" [fs/nfs/nfs.ko] undefined!
> 
> 
> because in fs/nfs/Kconfig, NFS_V4 selects RPCSEC_GSS_KRB5
> and/or in fs/nfsd/Kconfig, NFSD_V4 selects RPCSEC_GSS_KRB5.
> 
> RPCSEC_GSS_KRB5 does 5 selects, but none of these is enforced/followed
> by the fs/nfs[d]/Kconfig configs:
> 
> 	select SUNRPC_GSS
> 	select CRYPTO
> 	select CRYPTO_MD5
> 	select CRYPTO_DES
> 	select CRYPTO_CBC
> 
> Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
> Cc: J. Bruce Fields <bfields@fieldses.org>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  fs/nfs/Kconfig     |    1 -
>  fs/nfsd/Kconfig    |    1 -
>  net/sunrpc/Kconfig |    9 +++++----
>  3 files changed, 5 insertions(+), 6 deletions(-)
> 
> 
> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
> index cc1bb33..2ddc384 100644
> --- a/fs/nfs/Kconfig
> +++ b/fs/nfs/Kconfig
> @@ -63,7 +63,6 @@ config NFS_V3_ACL
>  config NFS_V4
>  	bool "NFS client support for NFS version 4"
>  	depends on NFS_FS
> -	select RPCSEC_GSS_KRB5
>  	help
>  	  This option enables support for version 4 of the NFS protocol
>  	  (RFC 3530) in the kernel's NFS client.
> diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
> index 503b9da..95932f5 100644
> --- a/fs/nfsd/Kconfig
> +++ b/fs/nfsd/Kconfig
> @@ -69,7 +69,6 @@ config NFSD_V4
>  	depends on NFSD && PROC_FS && EXPERIMENTAL
>  	select NFSD_V3
>  	select FS_POSIX_ACL
> -	select RPCSEC_GSS_KRB5
>  	help
>  	  This option enables support in your system's NFS server for
>  	  version 4 of the NFS protocol (RFC 3530).
> diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
> index 443c161..3376d76 100644
> --- a/net/sunrpc/Kconfig
> +++ b/net/sunrpc/Kconfig
> @@ -18,10 +18,11 @@ config SUNRPC_XPRT_RDMA
>  	  If unsure, say N.
>  
>  config RPCSEC_GSS_KRB5
> -	tristate "Secure RPC: Kerberos V mechanism (EXPERIMENTAL)"
> -	depends on SUNRPC && EXPERIMENTAL
> +	tristate
> +	depends on SUNRPC && CRYPTO
> +	prompt "Secure RPC: Kerberos V mechanism" if !(NFS_V4 || NFSD_V4)
> +	default y
>  	select SUNRPC_GSS
> -	select CRYPTO
>  	select CRYPTO_MD5
>  	select CRYPTO_DES
>  	select CRYPTO_CBC
> @@ -34,7 +35,7 @@ config RPCSEC_GSS_KRB5
>  	  available from http://linux-nfs.org/.  In addition, user-space
>  	  Kerberos support should be installed.
>  
> -	  If unsure, say N.
> +	  If unsure, say Y.
>  
>  config RPCSEC_GSS_SPKM3
>  	tristate "Secure RPC: SPKM3 mechanism (EXPERIMENTAL)"
> 
> 


-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
