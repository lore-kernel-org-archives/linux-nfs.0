Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:22693 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752257AbaB0Q6H convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Feb 2014 11:58:07 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: What does rpc.mountd dlopen() libnfsjunct.so rather than libnfsjunct.so.0
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20140227095859.19ba8a87@notabene.brown>
Date: Thu, 27 Feb 2014 08:57:56 -0800
Cc: Simo Sorce <simo@redhat.com>, Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <CD047B67-388C-4848-A020-917E51CF3EB5@oracle.com>
References: <20140226161646.1520358b@notabene.brown> <1393425572.18299.157.camel@willson.li.ssimo.org> <3A4B7C90-54B8-4373-B751-B02D940199BC@oracle.com> <20140227095859.19ba8a87@notabene.brown>
To: Neil Brown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 26, 2014, at 2:58 PM, NeilBrown <neilb@suse.de> wrote:

> On Wed, 26 Feb 2014 08:02:42 -0800 Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> 
>> On Feb 26, 2014, at 6:39 AM, Simo Sorce <simo@redhat.com> wrote:
>> 
>>> On Wed, 2014-02-26 at 16:16 +1100, NeilBrown wrote:
>>>> See $SUBJ
>>>> 
>>>> Shared libraries are usually versioned so you can release a new version with
>>>> an incompatible API and gradually transition to it.
>>>> 
>>>> A rpc.mountd dlopens libnfsjunct.so with no version it is effectively
>>>> prohibited from ever changing the API in an incompatible way.
>>>> 
>>>> Both Fedora and openSUSE get upset about packaging a libFOO.so in a non
>>>> "-devel" package and so trip over this library which clearly needs to be
>>>> installed even if you aren't doing 'devel'opment.
>>> 
>>> Keep in mind this rule is there only for real shared libraries that are
>>> loaded by the the system loader.
>>> 
>>> however it is waived for 'modules' that are opened dynamically but are
>>> private to the application.
>>> 
>>>> I would like to change mountd as per the patch below to use the ".0" file.
>>>> I believe this will not break any installation as the ".so" is installed as a
>>>> symlink to the ".0" (or maybe ".0.0.0").
>>>> 
>>>> Would this be acceptable?
>>> 
>>> It looks to me like this is an internal module for mountd that is not
>>> for use by other apps (which is why it is not versioned and can be
>>> changed at will as it is deployed at the same time mountd is ?
>> 
>> The plug-in API is versioned internally, but maybe I got that wrong, and should remove the API version field in favor of having consumers load via a specific .so number.
> 
> The problem I see with using the internal versioning is that if the version
> is wrong, mountd fails to provide the required service.
> So while I don't object to storing the version and performing the test, we
> should design work-flows so that the test can only fail if there is a serious
> configuration error, not just during a software upgrade.
> 
>> 
>>> Or am I wrong here ?
>>> 
>>> If I am not wrong I would be against this change personally and would
>>> rather move the .so file in a private library dir (if it is not already
>>> there) to make it clear it is a private module.
>> 
>> rpc.mountd is the only user currently, but it’s not necessarily private to mountd.  A generic storage manager tool might use it to resolve NFS and FedFS referrals for display, for example.  We could add plug-in API functions for creating and removing referrals to enable generic tools to perform these operations.
> 
> This is the answer I was looking for to the question I asked earlier - thanks.
> (So this is not an 'intimate library' to use Simo's term - it is truly a
> shared library).
> 
> If, one day, an incompatible ABI change was needed then we could have an
> rpc.mountd installed  (or still running) which requires one ABI, and a
> generic storage manager tool which requires the other.
> So we really need them to be stored in two different files.
> e.g. libnfsjunct.so.0 and libnfsjunct.so.1

I was hoping this would never happen.  One plug-in library should be able to serve mountd or any other tool that might need to play with junctions.

Only a crazy developer like me would ever need to have more than one library version at a time, and even then, it’s pretty simple to build what I need and reinstall, rather than having more than one installed at a time.

> To put it another way... libnfsjunct really is a shared library.
> The *only* reason that rpc.mountd treats it differently to other shared
> libraries is so that it can fail gracefully if the library isn't available
> (thus removing hard dependencies) - a difference that I am very comfortable
> with.
> In every other way it should be treated like a shared library
> - it should live in the standard /lib64 or whatever
> - each application determines at compile-time what version it needs and finds
>   it by appending the version number to the base file name
> - the "libfoo.so" file should live in the "-devel" package along with the
>   include file(s)
> 
> 
> So rather than dlopening "libnfsjunct.so.0" rpc.mountd should probably
> use a library name provided by the include file

I’m dense, I still don’t see why this makes a difference.  I’ll admit that linker fu is something I’ve left to others, so don’t be afraid to spell it out slowly for me.

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
> +#else
> +	handle = dlopen("libnfsjunct.so.0", RTLD_NOW);
> +#endif
> 	if (handle == NULL) {
> 		xlog(D_GENERAL, "%s: dlopen: %s", __func__, dlerror());
> 		return NULL;

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



