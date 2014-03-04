Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:39397 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751908AbaCDSfS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Mar 2014 13:35:18 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: What does rpc.mountd dlopen() libnfsjunct.so rather than libnfsjunct.so.0
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20140227095859.19ba8a87@notabene.brown>
Date: Tue, 4 Mar 2014 13:35:09 -0500
Cc: Simo Sorce <simo@redhat.com>, Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <6259E7ED-5D8C-4E29-A8B3-E0D11F2D6FFB@oracle.com>
References: <20140226161646.1520358b@notabene.brown> <1393425572.18299.157.camel@willson.li.ssimo.org> <3A4B7C90-54B8-4373-B751-B02D940199BC@oracle.com> <20140227095859.19ba8a87@notabene.brown>
To: Neil Brown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 26, 2014, at 5:58 PM, NeilBrown <neilb@suse.de> wrote:

[ … rationale removed … ]

> So rather than dlopening "libnfsjunct.so.0" rpc.mountd should probably
> use a library name provided by the include file
> 
> Thanks,
> NeilBrown
> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index ca35de28847a..1a8c20492869 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -1139,7 +1139,11 @@ static struct exportent *lookup_junction(char *dom, const char *pathname,
> 	struct link_map *map;
> 	void *handle;
> 
> -	handle = dlopen("libnfsjunct.so", RTLD_NOW);
> +#ifdef JP_LIB_NAME
> +	handle = dlopen(JP_LIB_NAME, RTLD_NOW);

What I can do now for fedfs-utils 0.10.1 is add a macro to the header file that defines the library name. I'd like to go with

#define JP_NFSPLUGIN_SONAME “libnfsjunct.so.0”

unless there are objections.

The mountd patch could also remove the API version check in invoke_junction_ops() when this macro is present.

> +#else
> +	handle = dlopen("libnfsjunct.so.0", RTLD_NOW);
> +#endif
> 	if (handle == NULL) {
> 		xlog(D_GENERAL, "%s: dlopen: %s", __func__, dlerror());
> 		return NULL;

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



