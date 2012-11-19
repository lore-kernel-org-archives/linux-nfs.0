Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:21142 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754495Ab2KSSjs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Nov 2012 13:39:48 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: [RFC PATCH V2] mount: Added the -o v4.1 mount option
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9092EF4AA@SACEXCMBX04-PRD.hq.netapp.com>
Date: Mon, 19 Nov 2012 13:39:42 -0500
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <428AB13F-9EE3-4357-8C88-11F2DA45453C@oracle.com>
References: <1353339810-19126-1-git-send-email-steved@redhat.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9092EEE7A@SACEXCMBX04-PRD.hq.netapp.com> <50AA571E.4090509@RedHat.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9092EEFD7@SACEXCMBX04-PRD.hq.netapp.com> <50AA5AD4.5070808@RedHat.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9092EF0B3@SACEXCMBX04-PRD.hq.netapp.com> <8B557EF0-A1F7-4487-8887-0B08F6922784@oracle.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9092EF4AA@SACEXCMBX04-PRD.hq.netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 19, 2012, at 1:29 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Mon, 2012-11-19 at 13:11 -0500, Chuck Lever wrote:
>> On Nov 19, 2012, at 11:24 AM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
>> 
>>> On Mon, 2012-11-19 at 11:14 -0500, Steve Dickson wrote:
>>>> 
>>>> On 19/11/12 11:02, Myklebust, Trond wrote:
>>>>> On Mon, 2012-11-19 at 10:58 -0500, Steve Dickson wrote:
>>>>>> 
>>>>>> On 19/11/12 10:54, Myklebust, Trond wrote:
>>>>>>> On Mon, 2012-11-19 at 10:43 -0500, Steve Dickson wrote:
>>>>>>>> This patch will convert -o v4.1, vers=4.1 or nfsvers=4.1 into
>>>>>>>> the corresponding "v4,minorversion=1", "vers=4,minorversion=1"
>>>>>>>> or "nfsvers=4,minorversion=1" options.
>>>>>>>> 
>>>>>>> 
>>>>>>> NACK.
>>>>>>> 
>>>>>>> If you are going to do this, then please do it only for kernels that
>>>>>>> don't support the "vers=4.1" syntax. i.e. anything older than Linux-3.4.
>>>>>> This is the intention... 
>>>>>> 
>>>>>>> 
>>>>>>> We want to get rid of minorversion=x, not perpetuate it...
>>>>>>> 
>>>>>> Understood... But that is not option in some worlds... ;-) 
>>>>> 
>>>>> Sure it is. The mount program can continue to parse minorversion= after
>>>>> it is gone from the kernel and convert it into the vers=4.x syntax.
>>>>> 
>>>> Basically what I'm doing now, with the exception of not adding
>>>> the minorversion=1 options... 
>>>> 
>>>> BTW, there is a bug in the -o v4.1 current logic... 
>>>> 
>>>> mount -o v4.1 produces both "v4.1,vers=4,..." in the string that given
>>>> to the kernel which does not seem right... I would assume just a "v4.1,.."
>>>> should be pumped down.. 
>>> 
>>> Yes. I remember seeing that in the Bakeathon tests... I agree that we
>>> just need the vers=4.1. The extra 'vers=4' isn't harmful in that the
>>> kernel won't interpret it as vers=4.0, but it would be nice to get rid
>>> of it.
>>> 
>>> Essentially, the plan is that some time in the future we will want to
>>> have 'vers=4' be the 'auto-negotiate minor version' syntax, while
>>> vers=4.x will be the 'use minor version x' syntax.
>>> Of course, auto-negotiation should be driven by the 'mount' program,
>>> which will be using the 'vers=4.x' syntax in the mount system call, for
>>> various values of 'x', until it achieves success.
>> 
>> Interesting.  I assume you want "mount.nfs" to do this to allow some kind of auto-negotiation policy to be specified (say, via the mount command configuration file).
> 
> Right. I'd like to be able to set Defaultvers=4.1 in /etc/nfsmount.conf
> and have it work.
> 
>> As a design precursor, can you speculate on how the mount command would go about negotiating the minor version?  mount.nfs cannot use protocol versions advertised by rpcbind, for instance, and neither can a simple NULL request identify which minor versions are available on the server.
> 
> Note that the mount command should in any case not be relying on rpcbind
> to decide whether or not the server supports NFSv4.
> 
> As for minor version negotiation, RFC3530 already tells you how to do
> this: the client has to start with the highest version that it supports,
> and then walk that number down until the server stops replying with
> NFS4ERR_MINOR_VERS_MISMATCH.
> 
> Note that if you want to do this in userland before calling the mount
> syscall, then the spec does allow you to "ping" the NFSv4 server with an
> empty COMPOUND.

I see: not an NFSv4 NULL, but an NFSv4 COMPOUND that has no operations.  That carries a compound header, which would have the minor version number in it.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




