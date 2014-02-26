Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:33219 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751720AbaBZQyU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Feb 2014 11:54:20 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: What does rpc.mountd dlopen() libnfsjunct.so rather than libnfsjunct.so.0
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1393431901.18299.167.camel@willson.li.ssimo.org>
Date: Wed, 26 Feb 2014 08:54:08 -0800
Cc: Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <2C382FB2-559C-4A0C-B361-A5A8E60E0E19@oracle.com>
References: <20140226161646.1520358b@notabene.brown> <1393425572.18299.157.camel@willson.li.ssimo.org> <3A4B7C90-54B8-4373-B751-B02D940199BC@oracle.com> <1393431901.18299.167.camel@willson.li.ssimo.org>
To: Simo Sorce <simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 26, 2014, at 8:25 AM, Simo Sorce <simo@redhat.com> wrote:

> On Wed, 2014-02-26 at 08:02 -0800, Chuck Lever wrote:
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
>> The plug-in API is versioned internally, but maybe I got that wrong,
>> and should remove the API version field in favor of having consumers
>> load via a specific .so number.
> 
> Either way works the same, it just changes what component makes the
> determination (app code vs linker)
> 
>>> Or am I wrong here ?
>>> 
>>> If I am not wrong I would be against this change personally and would
>>> rather move the .so file in a private library dir (if it is not already
>>> there) to make it clear it is a private module.
>> 
>> rpc.mountd is the only user currently, but it’s not necessarily
>> private to mountd.  A generic storage manager tool might use it to
>> resolve NFS and FedFS referrals for display, for example.  We could
>> add plug-in API functions for creating and removing referrals to
>> enable generic tools to perform these operations.
> 
> If it is a generic library why is it dlopened() instead of being simply
> linked in at build time ?

Handling NFS and FedFS junctions requires support for sqlite3, LDAP, and XML, among others.  The maintainer of nfs-utils preferred to add zero new build dependencies when we introduced this functionality.  The design we came up with was to dlopen() a library that would pull in everything that was needed at run time.

If the plug-in is not installed, mountd simply skips trying to resolve junctions.  This would be the case for embedded NFS servers, for example.

> 
>> A separate directory makes sense if there’s more than one thing to put
>> in it.  Right now we just have the plug-in library, and no plans to
>> add more.
> 
> directories are cheap, don't fear them :)
> 
>> I took an expedient approach when implementing the plug-in, and could
>> have gotten it wrong.  I’m open to make this mechanism fit packaging
>> guidelines and requirements.
> 
> Packaging guidelines vary depending on whether the library is public or
> private and therefore you need to guarantee ABI compatibility or not.
> 
> I think you need to make that determination first.

I attempted to guarantee API compatibility using the API version field and by publishing the API definition in a header under /usr/include.  By that definition it is a public API that happens to have only one current user.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



