Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:36671 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752124AbaDPEow (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Apr 2014 00:44:52 -0400
Message-ID: <534E0AC0.5050601@candelatech.com>
Date: Tue, 15 Apr 2014 21:44:48 -0700
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        David Howells <dhowells@redhat.com>
Subject: Re: Question on nfs-utils patch for 'keyctl_invalidate'.
References: <534C7B70.9000500@candelatech.com> <534DCD52.5080202@RedHat.com>
In-Reply-To: <534DCD52.5080202@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/15/2014 05:22 PM, Steve Dickson wrote:
>
>
> On 04/14/2014 08:21 PM, Ben Greear wrote:
>> It seems that key_invalidate is only available in quite recent
>> keyutils packages.
>>
>> Anyone know if there is a relatively simple way to implement
>> the same behaviour using older keyutils packages?
> CC-ing the keyutils maintainer... David, when did that kernel
> change go in that cause keyctl_revoke() to no longer work?
>
> The nfs-utils commit is:
>
> commit 2ae0763a618d30037ebb2520f6292f80d838a440
> Author: Steve Dickson <steved@redhat.com>
> Date:   Tue Mar 25 10:56:58 2014 -0400
>
>      nfsidmap: Keys need to be invalidated instead of revoked
>
> It sound like we need to do some type of #ifdef kernel version....

We might need an #ifdef based on keyutils version (which is what I implemented
to at least get it compiling), but if you need to key on kernel version then
you need run-time probing of the kernel as build system may run different
kernel than installed system.

Thanks,
Ben

>
> steved.
>
>>
>> The reason I ask is that I recently updated to latest nfs-utils
>> package and how build fails on many of my older systems...
>>
>> Thanks,
>> Ben
>>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

