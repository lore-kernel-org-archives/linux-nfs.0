Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:20518 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752733Ab3JVAEF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Oct 2013 20:04:05 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Ben Greear <greearb@candelatech.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Getting 'not supported' when trying to mount IPv6 NFS v3 server.
Date: Tue, 22 Oct 2013 00:04:04 +0000
Message-ID: <EAF9A96E-EAF9-43C4-A520-B5A971E67DE5@netapp.com>
References: <52659D69.1020609@candelatech.com>
 <4682F017-7329-4690-B336-233DB50537F0@netapp.com>
 <5265BECD.1060601@candelatech.com>
In-Reply-To: <5265BECD.1060601@candelatech.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 21, 2013, at 7:54 PM, Ben Greear <greearb@candelatech.com>
 wrote:

> On 10/21/2013 04:44 PM, Weston Andros Adamson wrote:
>> 
>> On Oct 21, 2013, at 5:32 PM, Ben Greear <greearb@candelatech.com> wrote:
>> 
>>> So, the problem I reported earlier with failing to unmount was fixed
>>> by the back-ported patch.
>>> 
>>> Now, another problem is reported by my user.  In this case, they are
>>> trying to mount an IPv6 NFS server using NFSv3.  Kernel is 3.9.11+,
>>> with patches to support binding mount points to local IP (v4/v6) addresses.
>>> 
>>> Some NFS over IPv6 mounts work fine, but some do not.  A reboot of the
>>> NFS client machine did not fix the problem.
>>> 
>>> I have tried to reproduce the problem locally, but so far everything works fine
>>> for us.
>>> 
>>> From my own app's logs:
>>> 
>>> # mount -t nfs [4001:1::1:1]:/vol/vol1 /mnt/lf/RDnfse11c0 -o srcaddr=4001:1::1:201,vers=3
>>> # requested NFS version or transport protocol is not supported
>>> 
>>> When this problem happens, I do not see any network traffic when trying to mount.
>> 
>> Did you look for the mount protocol when getting a network trace (filter "rpc" in wireshark).
> 
> I saw zero NFS related packets on the wire when hitting this problem.
> But, there could have been packets earlier that put it into a funky
> state, or a bit less likely, they could have been going out some of the
> other virtual interfaces on the system.

Ok, I wanted to make sure you weren't just looking at port 2049...

> 
>> Could you:
>> 
>>  1) run "rpcdebug -m nfs -s mount" before mounting, post output of dmesg after mount fails.
>> 
>>  2) add -v to the mount command and post the output
> 
> I can try this.
> 
>>  3) maybe get rid of srcaddr= option / post info about the ip configuration
> 
> I can't easily do this, as the user's setup requires the srcaddr to route properly
> to the filer.

I just want to make sure it's not a configuration error, but the outputs of 1) and 2) will help us determine what's happening.

> 
> I am also going to run a kernel with printks added around all the EOPNOTSUPP
> returns that I can find to try to track down what part of the kernel is
> complaining.

The rpcdebug part should help with that.  Maybe you should turn on everything (rpcdebug -m nfs -s all) since it's just a (failed) mount.

-dros

> 
> Thanks,
> Ben
> 
> 
> -- 
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

