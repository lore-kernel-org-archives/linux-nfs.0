Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:44332 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844Ab3JUXy4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Oct 2013 19:54:56 -0400
Message-ID: <5265BECD.1060601@candelatech.com>
Date: Mon, 21 Oct 2013 16:54:53 -0700
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: Weston Andros Adamson <dros@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Getting 'not supported' when trying to mount IPv6 NFS v3 server.
References: <52659D69.1020609@candelatech.com> <4682F017-7329-4690-B336-233DB50537F0@netapp.com>
In-Reply-To: <4682F017-7329-4690-B336-233DB50537F0@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/21/2013 04:44 PM, Weston Andros Adamson wrote:
> 
> On Oct 21, 2013, at 5:32 PM, Ben Greear <greearb@candelatech.com> wrote:
> 
>> So, the problem I reported earlier with failing to unmount was fixed
>> by the back-ported patch.
>>
>> Now, another problem is reported by my user.  In this case, they are
>> trying to mount an IPv6 NFS server using NFSv3.  Kernel is 3.9.11+,
>> with patches to support binding mount points to local IP (v4/v6) addresses.
>>
>> Some NFS over IPv6 mounts work fine, but some do not.  A reboot of the
>> NFS client machine did not fix the problem.
>>
>> I have tried to reproduce the problem locally, but so far everything works fine
>> for us.
>>
>> From my own app's logs:
>>
>> # mount -t nfs [4001:1::1:1]:/vol/vol1 /mnt/lf/RDnfse11c0 -o srcaddr=4001:1::1:201,vers=3
>> # requested NFS version or transport protocol is not supported
>>
>> When this problem happens, I do not see any network traffic when trying to mount.
> 
> Did you look for the mount protocol when getting a network trace (filter "rpc" in wireshark).

I saw zero NFS related packets on the wire when hitting this problem.
But, there could have been packets earlier that put it into a funky
state, or a bit less likely, they could have been going out some of the
other virtual interfaces on the system.

> Could you:
> 
>   1) run "rpcdebug -m nfs -s mount" before mounting, post output of dmesg after mount fails.
> 
>   2) add -v to the mount command and post the output

I can try this.

>   3) maybe get rid of srcaddr= option / post info about the ip configuration

I can't easily do this, as the user's setup requires the srcaddr to route properly
to the filer.

I am also going to run a kernel with printks added around all the EOPNOTSUPP
returns that I can find to try to track down what part of the kernel is
complaining.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

