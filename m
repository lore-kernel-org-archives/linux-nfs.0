Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:46694 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754158AbaCKSTh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Mar 2014 14:19:37 -0400
Message-ID: <531F53B3.4070409@RedHat.com>
Date: Tue, 11 Mar 2014 14:19:31 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: Chuck Lever <chuck.lever@oracle.com>, Simo Sorce <simo@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH: nfs-utils] mountd: use SONAME fir libnfsjunct when loading
 with dlopen.
References: <20140226161646.1520358b@notabene.brown>	<1393425572.18299.157.camel@willson.li.ssimo.org>	<3A4B7C90-54B8-4373-B751-B02D940199BC@oracle.com>	<20140227095859.19ba8a87@notabene.brown>	<6259E7ED-5D8C-4E29-A8B3-E0D11F2D6FFB@oracle.com>	<20140305144503.7310db31@notabene.brown> <20140305150741.19cead16@notabene.brown>
In-Reply-To: <20140305150741.19cead16@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/04/2014 11:07 PM, NeilBrown wrote:
> 
> 
> The standard for loading shared libraries is to identify them by their
> "soname" (Which "objdump -x $BINARY | grep SONAME" will report).
> However mountd currently loads using the "linker name" which should only
> be used when building new code.
> 
> Future releases of fedfs-utils will define the soname in the include
> file, so if that is defined, use it.  If not, use the soname of the
> first version: "libnfsjunct.so.0".
> 
> This is a slight behavioural change.  However all distros known to
> package fedfs-utils will install "libnfsjunct.so.0" whenever they
> install the old name of "libnfsjunct.so", and "make install" will
> install both.  So it should not be a noticeable change.
> 
> Also only test the JP_API_VERSION if it is defined.  As the version is
> embedded in the soname, a secondary test is not needed.
> 
> Cc: Chuck Lever <chuck.lever@oracle.com>
> Signed-off-by: NeilBrown <neilb@suse.de>
Committed... 

steved.
> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index ca35de28847a..9a1bb2767ac2 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -1087,12 +1087,13 @@ static struct exportent *invoke_junction_ops(void *handle, char *dom,
>  			__func__, error);
>  		return NULL;
>  	}
> +#ifdef JP_API_VERSION
>  	if (ops->jp_api_version != JP_API_VERSION) {
>  		xlog(D_GENERAL, "%s: unrecognized junction API version: %u",
>  			__func__, ops->jp_api_version);
>  		return NULL;
>  	}
> -
> +#endif
>  	status = ops->jp_init(false);
>  	if (status != JP_OK) {
>  		xlog(D_GENERAL, "%s: failed to resolve %s: %s",
> @@ -1139,7 +1140,11 @@ static struct exportent *lookup_junction(char *dom, const char *pathname,
>  	struct link_map *map;
>  	void *handle;
>  
> -	handle = dlopen("libnfsjunct.so", RTLD_NOW);
> +#ifdef JP_NFSPLUGIN_SONAME
> +	handle = dlopen(JP_NFSPLUGIN_SONAME, RTLD_NOW);
> +#else
> +	handle = dlopen("libnfsjunct.so.0", RTLD_NOW);
> +#endif
>  	if (handle == NULL) {
>  		xlog(D_GENERAL, "%s: dlopen: %s", __func__, dlerror());
>  		return NULL;
> 
