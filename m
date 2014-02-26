Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:22023 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860AbaBZGHJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Feb 2014 01:07:09 -0500
References: <20140226161646.1520358b@notabene.brown>
Mime-Version: 1.0 (1.0)
In-Reply-To: <20140226161646.1520358b@notabene.brown>
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <728AA1BE-98D9-4E63-B415-8CB922AD121C@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>, NFS <linux-nfs@vger.kernel.org>
From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: What does rpc.mountd dlopen() libnfsjunct.so rather than libnfsjunct.so.0
Date: Tue, 25 Feb 2014 22:06:58 -0800
To: NeilBrown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Feb 25, 2014, at 9:16 PM, NeilBrown <neilb@suse.de> wrote:
> 
> 
> See $SUBJ
> 
> Shared libraries are usually versioned so you can release a new version with
> an incompatible API and gradually transition to it.
> 
> A rpc.mountd dlopens libnfsjunct.so with no version it is effectively
> prohibited from ever changing the API in an incompatible way.

There is an API version field that mountd can examine before using the plug-in.  .so symlinks to whichever library version is the blessed one.

> 
> Both Fedora and openSUSE get upset about packaging a libFOO.so in a non
> "-devel" package and so trip over this library which clearly needs to be
> installed even if you aren't doing 'devel'opment.

I've seen the rpmlint warning for some time.  Never been sure exactly what to do about it, or whether it matters.

> 
> I would like to change mountd as per the patch below to use the ".0" file.
> I believe this will not break any installation as the ".so" is installed as a
> symlink to the ".0" (or maybe ".0.0.0").
> 
> Would this be acceptable?

That dlopen(3) should follow whatever packaging guidelines are set out by distributors.  Do what you guys agree is correct.

> 
> There is a bit of a discussion about this here:
>  https://bugzilla.redhat.com/show_bug.cgi?id=889174
> 
> but I either don't understand it or don't agree with it.
> 
> Thanks,
> NeilBrown
> 
> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index ca35de28847a..f6d78490954f 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -1139,7 +1139,7 @@ static struct exportent *lookup_junction(char *dom, const char *pathname,
>    struct link_map *map;
>    void *handle;
> 
> -    handle = dlopen("libnfsjunct.so", RTLD_NOW);
> +    handle = dlopen("libnfsjunct.so.0", RTLD_NOW);
>    if (handle == NULL) {
>        xlog(D_GENERAL, "%s: dlopen: %s", __func__, dlerror());
>        return NULL;
