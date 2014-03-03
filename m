Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:33715 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753521AbaCCRqF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Mar 2014 12:46:05 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: What does rpc.mountd dlopen() libnfsjunct.so rather than libnfsjunct.so.0
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20140303142113.180679fb@notabene.brown>
Date: Mon, 3 Mar 2014 12:45:55 -0500
Cc: Simo Sorce <simo@redhat.com>, Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <CB870329-4F13-49BC-9D10-A02BD4DDB680@oracle.com>
References: <20140226161646.1520358b@notabene.brown> <1393425572.18299.157.camel@willson.li.ssimo.org> <3A4B7C90-54B8-4373-B751-B02D940199BC@oracle.com> <20140227095859.19ba8a87@notabene.brown> <CD047B67-388C-4848-A020-917E51CF3EB5@oracle.com> <20140303142113.180679fb@notabene.brown>
To: Neil Brown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 2, 2014, at 10:21 PM, NeilBrown <neilb@suse.de> wrote:

> On Thu, 27 Feb 2014 08:57:56 -0800 Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> 
>> On Feb 26, 2014, at 2:58 PM, NeilBrown <neilb@suse.de> wrote:
>> 
>>> On Wed, 26 Feb 2014 08:02:42 -0800 Chuck Lever <chuck.lever@oracle.com> wrote:
>>> 
>>>> 
>>>> On Feb 26, 2014, at 6:39 AM, Simo Sorce <simo@redhat.com> wrote:
>>>> 
>>>>> On Wed, 2014-02-26 at 16:16 +1100, NeilBrown wrote:
>>>>>> See $SUBJ
>>>>>> 
>>>>>> Shared libraries are usually versioned so you can release a new version with
>>>>>> an incompatible API and gradually transition to it.
>>>>>> 
>>>>>> A rpc.mountd dlopens libnfsjunct.so with no version it is effectively
>>>>>> prohibited from ever changing the API in an incompatible way.
>>>>>> 
>>>>>> Both Fedora and openSUSE get upset about packaging a libFOO.so in a non
>>>>>> "-devel" package and so trip over this library which clearly needs to be
>>>>>> installed even if you aren't doing 'devel'opment.
>>>>> 
>>>>> Keep in mind this rule is there only for real shared libraries that are
>>>>> loaded by the the system loader.
>>>>> 
>>>>> however it is waived for 'modules' that are opened dynamically but are
>>>>> private to the application.
>>>>> 
>>>>>> I would like to change mountd as per the patch below to use the ".0" file.
>>>>>> I believe this will not break any installation as the ".so" is installed as a
>>>>>> symlink to the ".0" (or maybe ".0.0.0").
>>>>>> 
>>>>>> Would this be acceptable?
>>>>> 
>>>>> It looks to me like this is an internal module for mountd that is not
>>>>> for use by other apps (which is why it is not versioned and can be
>>>>> changed at will as it is deployed at the same time mountd is ?
>>>> 
>>>> The plug-in API is versioned internally, but maybe I got that wrong, and should remove the API version field in favor of having consumers load via a specific .so number.
>>> 
>>> The problem I see with using the internal versioning is that if the version
>>> is wrong, mountd fails to provide the required service.
>>> So while I don't object to storing the version and performing the test, we
>>> should design work-flows so that the test can only fail if there is a serious
>>> configuration error, not just during a software upgrade.
>>> 
>>>> 
>>>>> Or am I wrong here ?
>>>>> 
>>>>> If I am not wrong I would be against this change personally and would
>>>>> rather move the .so file in a private library dir (if it is not already
>>>>> there) to make it clear it is a private module.
>>>> 
>>>> rpc.mountd is the only user currently, but it’s not necessarily private to mountd.  A generic storage manager tool might use it to resolve NFS and FedFS referrals for display, for example.  We could add plug-in API functions for creating and removing referrals to enable generic tools to perform these operations.
>>> 
>>> This is the answer I was looking for to the question I asked earlier - thanks.
>>> (So this is not an 'intimate library' to use Simo's term - it is truly a
>>> shared library).
>>> 
>>> If, one day, an incompatible ABI change was needed then we could have an
>>> rpc.mountd installed  (or still running) which requires one ABI, and a
>>> generic storage manager tool which requires the other.
>>> So we really need them to be stored in two different files.
>>> e.g. libnfsjunct.so.0 and libnfsjunct.so.1
>> 
>> I was hoping this would never happen.  One plug-in library should be able to serve mountd or any other tool that might need to play with junctions.
> 
> Certainly that is the hope.  I think everyone who writes a shared library
> hopes they will get it right first time, and that if a change is ever needed
> then all users can be upgraded simultaneously.
> 
> $ ls -l /lib64/lib*.so.1 | grep -c '^-'
> 4
> $ ls -l /lib64/lib*.so.1.* | grep -c '^-'
> 17
> $ ls -l /lib64/lib*.so.[2-9]* | grep -c '^-'
> 20
> 
> That seems to happen often, but not always.  That is why we have shared
> library versioning.
> 
>> 
>> Only a crazy developer like me would ever need to have more than one library version at a time, and even then, it’s pretty simple to build what I need and reinstall, rather than having more than one installed at a time.
>> 
>>> To put it another way... libnfsjunct really is a shared library.
>>> The *only* reason that rpc.mountd treats it differently to other shared
>>> libraries is so that it can fail gracefully if the library isn't available
>>> (thus removing hard dependencies) - a difference that I am very comfortable
>>> with.
>>> In every other way it should be treated like a shared library
>>> - it should live in the standard /lib64 or whatever
>>> - each application determines at compile-time what version it needs and finds
>>>  it by appending the version number to the base file name
>>> - the "libfoo.so" file should live in the "-devel" package along with the
>>>  include file(s)
>>> 
>>> 
>>> So rather than dlopening "libnfsjunct.so.0" rpc.mountd should probably
>>> use a library name provided by the include file
>> 
>> I’m dense, I still don’t see why this makes a difference.  I’ll admit that linker fu is something I’ve left to others, so don’t be afraid to spell it out slowly for me.
> 
> I'll try (might make sure I understand it too).
> The following is based in part on section 3.1.1 of
> http://tldp.org/HOWTO/Program-Library-HOWTO/shared-libraries.html
> 
> A shared library (like a cat) has three different names.
> 
> 1/ The file name.  This is normally /$LIBDIR/libFOO.so.maj.min.release
>  (e.g. /usr/lib/libnfsjunct.so.0.0.0), though it can be almost whatever you
>  like.   It is used by installers to install the library, and by ldconfig.
>  ldconfig only wants it to start "lib" or "ld-" and to have ".so" somewhere
>  in the name.
> 
> 2/ The "soname".  This is /$LIBDIR/libFOO.so.maj (i.e. only major number).
>   ldconfig will create a symlink from this name to the "most recent" library
>   found with that SONAME (a field in the shared library:
>         objdump -x $LIBRARY | grep SONAME
>   ).
>   An application which needs to be linked will contain the "soname" of each
>   library that it wants to use. "ldd" lists these and the matching filename
>   for each.  ld.so effective calls "dlopen" on each "soname".
> 
> 3/ The "linker name".  This is the name that is used when you compile code.
>   You typically specify "-lFOO" and the linker interprets that at
>   "$LIBPATH/libFOO.so" and finds a shared library.  It extracts the SONAME
>   from this library and stores that in that generated binary.
>   Naturally the library version found at the "linker name" must match the
>   include files describing data structures etc in the library.
> 
> To follow this pattern as closely as possible, and yet allow rpc.mountd to
> use dlopen() to load the library:
> - the "soname" should be passed to dlopen(). (That is what ld.so does)
> - that name should be determined from the compile-time environment. (that is
>   what 'ld' does).
> 
> i.e. we should pass "libnfsjunct.so.0" to dlopen() (if the current
> fedfs-utils provides the compile-time environment).  We could determine that
> string with a little script which runs
> 
>   objdump -x /lib64/libnfsjunct.so | sed -n -e 's/^ *SONAME *//p'
> 
> or we could simply keep it in the include file (which must be in-sync with
> the .so).
> 
> Doing this
> 1/ ensures that we have the full flexibility of shared libraries should we
>    ever need that.
> 2/ makes the nfsjunct library look just like any other shared library and so
>    avoids confusion for package checkers.
> 
> Does that clarify at all?

Thank you Neil, it’s coming into focus for me.

We had some conversation about this at Connectathon last week. It seems like a better design would look like:

  o  A separate directory under /usr/lib{64} where fedfs-utils would install its plug-ins

  o  Plug-in consumers would dlopen() via the plug-in library's soname to guarantee ABI compatibility

  o  The API version field would be deprecated

  o  We didn’t discuss how consumers discover the plug-in soname, but if the API is defined in the header and the soname has to match, maybe that’s the way to go

I don’t think any of these changes would alter the “loose-ness” of current coupling between rpc.mountd and the plug-in library (to address Steve’s concern), but they would make a better guarantee that mountd was loading the correct plug-in library version.

I’m not sure exactly how to get from point A to point B. Probably fedfs-utils would have to package the plug-in library in the old and new places until all distributed versions of mountd was changed to find the plug-ins in the right place. That would have to be the case to allow nfs-utils downgrades for a particular distribution.




> 
> Thanks,
> NeilBrown
> 
> 
>>> 
>>> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
>>> index ca35de28847a..1a8c20492869 100644
>>> --- a/utils/mountd/cache.c
>>> +++ b/utils/mountd/cache.c
>>> @@ -1139,7 +1139,11 @@ static struct exportent *lookup_junction(char *dom, const char *pathname,
>>> 	struct link_map *map;
>>> 	void *handle;
>>> 
>>> -	handle = dlopen("libnfsjunct.so", RTLD_NOW);
>>> +#ifdef JP_LIB_NAME
>>> +	handle = dlopen(JP_LIB_NAME, RTLD_NOW);
>>> +#else
>>> +	handle = dlopen("libnfsjunct.so.0", RTLD_NOW);
>>> +#endif
>>> 	if (handle == NULL) {
>>> 		xlog(D_GENERAL, "%s: dlopen: %s", __func__, dlerror());
>>> 		return NULL;
>> 
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>> 
>> 
> 

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



