Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:57458 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751844Ab2KSQOQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Nov 2012 11:14:16 -0500
Message-ID: <50AA5AD4.5070808@RedHat.com>
Date: Mon, 19 Nov 2012 11:14:12 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [RFC PATCH V2] mount: Added the -o v4.1 mount option
References: <1353339810-19126-1-git-send-email-steved@redhat.com>  <4FA345DA4F4AE44899BD2B03EEEC2FA9092EEE7A@SACEXCMBX04-PRD.hq.netapp.com>  <50AA571E.4090509@RedHat.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9092EEFD7@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9092EEFD7@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 19/11/12 11:02, Myklebust, Trond wrote:
> On Mon, 2012-11-19 at 10:58 -0500, Steve Dickson wrote:
>>
>> On 19/11/12 10:54, Myklebust, Trond wrote:
>>> On Mon, 2012-11-19 at 10:43 -0500, Steve Dickson wrote:
>>>> This patch will convert -o v4.1, vers=4.1 or nfsvers=4.1 into
>>>> the corresponding "v4,minorversion=1", "vers=4,minorversion=1"
>>>> or "nfsvers=4,minorversion=1" options.
>>>>
>>>
>>> NACK.
>>>
>>> If you are going to do this, then please do it only for kernels that
>>> don't support the "vers=4.1" syntax. i.e. anything older than Linux-3.4.
>> This is the intention... 
>>
>>>
>>> We want to get rid of minorversion=x, not perpetuate it...
>>>
>> Understood... But that is not option in some worlds... ;-) 
> 
> Sure it is. The mount program can continue to parse minorversion= after
> it is gone from the kernel and convert it into the vers=4.x syntax.
> 
Basically what I'm doing now, with the exception of not adding
the minorversion=1 options... 

BTW, there is a bug in the -o v4.1 current logic... 

mount -o v4.1 produces both "v4.1,vers=4,..." in the string that given
to the kernel which does not seem right... I would assume just a "v4.1,.."
should be pumped down.. 

steved.
