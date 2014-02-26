Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:23626 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750942AbaBZOjl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Feb 2014 09:39:41 -0500
Subject: Re: What does rpc.mountd dlopen() libnfsjunct.so rather than
 libnfsjunct.so.0
From: Simo Sorce <simo@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: Chuck Lever <chuck.lever@oracle.com>, Steve Dickson <SteveD@redhat.com>,
        NFS <linux-nfs@vger.kernel.org>
In-Reply-To: <20140226161646.1520358b@notabene.brown>
References: <20140226161646.1520358b@notabene.brown>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 26 Feb 2014 09:39:32 -0500
Message-ID: <1393425572.18299.157.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2014-02-26 at 16:16 +1100, NeilBrown wrote:
> See $SUBJ
> 
> Shared libraries are usually versioned so you can release a new version with
> an incompatible API and gradually transition to it.
> 
> A rpc.mountd dlopens libnfsjunct.so with no version it is effectively
> prohibited from ever changing the API in an incompatible way.
> 
> Both Fedora and openSUSE get upset about packaging a libFOO.so in a non
> "-devel" package and so trip over this library which clearly needs to be
> installed even if you aren't doing 'devel'opment.

Keep in mind this rule is there only for real shared libraries that are
loaded by the the system loader.

however it is waived for 'modules' that are opened dynamically but are
private to the application.

> I would like to change mountd as per the patch below to use the ".0" file.
> I believe this will not break any installation as the ".so" is installed as a
> symlink to the ".0" (or maybe ".0.0.0").
> 
> Would this be acceptable?

It looks to me like this is an internal module for mountd that is not
for use by other apps (which is why it is not versioned and can be
changed at will as it is deployed at the same time mountd is ?

Or am I wrong here ?

If I am not wrong I would be against this change personally and would
rather move the .so file in a private library dir (if it is not already
there) to make it clear it is a private module.

> There is a bit of a discussion about this here:
>   https://bugzilla.redhat.com/show_bug.cgi?id=889174
> 
> but I either don't understand it or don't agree with it.

Which part of it, there are different opinions stated in the bugzilla at
different times.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

