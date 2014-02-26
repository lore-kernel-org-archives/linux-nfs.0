Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:24838 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751170AbaBZOv7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Feb 2014 09:51:59 -0500
References: <20140226161646.1520358b@notabene.brown> <728AA1BE-98D9-4E63-B415-8CB922AD121C@oracle.com> <20140226180158.7f7d0e62@notabene.brown>
Mime-Version: 1.0 (1.0)
In-Reply-To: <20140226180158.7f7d0e62@notabene.brown>
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <497B345F-1900-42AC-9249-74A70738827B@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>, NFS <linux-nfs@vger.kernel.org>
From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: What does rpc.mountd dlopen() libnfsjunct.so rather than libnfsjunct.so.0
Date: Wed, 26 Feb 2014 06:51:47 -0800
To: NeilBrown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Feb 25, 2014, at 11:01 PM, NeilBrown <neilb@suse.de> wrote:
> 
>> On Tue, 25 Feb 2014 22:06:58 -0800 Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>> 
>> 
>>> On Feb 25, 2014, at 9:16 PM, NeilBrown <neilb@suse.de> wrote:
>>> 
>>> 
>>> See $SUBJ
>>> 
>>> Shared libraries are usually versioned so you can release a new version with
>>> an incompatible API and gradually transition to it.
>>> 
>>> A rpc.mountd dlopens libnfsjunct.so with no version it is effectively
>>> prohibited from ever changing the API in an incompatible way.
>> 
>> There is an API version field that mountd can examine before using the plug-in.  .so symlinks to whichever library version is the blessed one.
> 
> What exactly does "blessed one" mean...

It means the one the local administrator chooses to use.  The only reason to have more than one plug-in version installed is when testing an upgrade.

> 
> Maybe the question I want to ask is:
> Is libnfsjunct.so something that only rpc.mountd would ever use and it could
> not possibly make any sense for anything else to ever use it?

There is a public header in /usr/include that contains the API definition.  In the future the plug-in might also be able to perform administrative operations on junctions, and other applications could invoke this functionality via the plug-in.

I don't think it's applicability is narrow, even though mountd is its only user today.

> 
> If so, then we probably don't want to install the .so.0 or .so.0.0.0 files
> and maybe should give libnfsjunct.so a different suffix because it is not
> "shared" in any sense (I wanted to suggest ".lo" for loadable object, but I
> think that is already used).
> 
> If not, then you could conceivably have two tool installed which use
> different version, so it doesn't make sense for either to be "blessed".
> The bare ".so" name would be "the version that should be used when building
> anything from source".

I don't understand this last bit.  The plug-in can get bug fixes and new features and mountd does not need to be rebuilt from source to use them.

> 
> Does the question have a simple answer?

I'm afraid I don't yet understand the problem you are trying to solve.

> 
> Thanks,
> NeilBrown
