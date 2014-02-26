Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:34676 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751170AbaBZQDK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Feb 2014 11:03:10 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: What does rpc.mountd dlopen() libnfsjunct.so rather than libnfsjunct.so.0
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1393425572.18299.157.camel@willson.li.ssimo.org>
Date: Wed, 26 Feb 2014 08:02:42 -0800
Cc: Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <3A4B7C90-54B8-4373-B751-B02D940199BC@oracle.com>
References: <20140226161646.1520358b@notabene.brown> <1393425572.18299.157.camel@willson.li.ssimo.org>
To: Simo Sorce <simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 26, 2014, at 6:39 AM, Simo Sorce <simo@redhat.com> wrote:

> On Wed, 2014-02-26 at 16:16 +1100, NeilBrown wrote:
>> See $SUBJ
>> 
>> Shared libraries are usually versioned so you can release a new version with
>> an incompatible API and gradually transition to it.
>> 
>> A rpc.mountd dlopens libnfsjunct.so with no version it is effectively
>> prohibited from ever changing the API in an incompatible way.
>> 
>> Both Fedora and openSUSE get upset about packaging a libFOO.so in a non
>> "-devel" package and so trip over this library which clearly needs to be
>> installed even if you aren't doing 'devel'opment.
> 
> Keep in mind this rule is there only for real shared libraries that are
> loaded by the the system loader.
> 
> however it is waived for 'modules' that are opened dynamically but are
> private to the application.
> 
>> I would like to change mountd as per the patch below to use the ".0" file.
>> I believe this will not break any installation as the ".so" is installed as a
>> symlink to the ".0" (or maybe ".0.0.0").
>> 
>> Would this be acceptable?
> 
> It looks to me like this is an internal module for mountd that is not
> for use by other apps (which is why it is not versioned and can be
> changed at will as it is deployed at the same time mountd is ?

The plug-in API is versioned internally, but maybe I got that wrong, and should remove the API version field in favor of having consumers load via a specific .so number.

> Or am I wrong here ?
> 
> If I am not wrong I would be against this change personally and would
> rather move the .so file in a private library dir (if it is not already
> there) to make it clear it is a private module.

rpc.mountd is the only user currently, but it’s not necessarily private to mountd.  A generic storage manager tool might use it to resolve NFS and FedFS referrals for display, for example.  We could add plug-in API functions for creating and removing referrals to enable generic tools to perform these operations.

A separate directory makes sense if there’s more than one thing to put in it.  Right now we just have the plug-in library, and no plans to add more.

I took an expedient approach when implementing the plug-in, and could have gotten it wrong.  I’m open to make this mechanism fit packaging guidelines and requirements.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



