Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:63014 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758126Ab1FJWfX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 18:35:23 -0400
Subject: Re: [PATCH v3 4/6] nfs-utils:  Support srcaddr=n option for string mount.
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4DF29AF2.6020508@candelatech.com>
Date: Fri, 10 Jun 2011 18:35:11 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <D5F0D4D5-8F59-4131-88ED-88708D9CF92D@oracle.com>
References: <1307740096-19933-1-git-send-email-greearb@candelatech.com> <1307740096-19933-5-git-send-email-greearb@candelatech.com> <D9DC610C-5620-403C-BF0A-CCD37AFAF4BB@oracle.com> <4DF29AF2.6020508@candelatech.com>
To: Ben Greear <greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jun 10, 2011, at 6:30 PM, Ben Greear wrote:

> On 06/10/2011 03:07 PM, Chuck Lever wrote:
>> 
>> On Jun 10, 2011, at 5:08 PM, greearb@candelatech.com wrote:
>> 
>>> From: Ben Greear<greearb@candelatech.com>
>>> 
>>> Look for and parse the srcaddr=n argument.  If parsing
>>> succeeds, pass this down the call chain.  This fully
>>> implements binding to a specified source address when
>>> mounting.
> 
>>> +		if (!local_ip->is_set) {
>>> +			free(local_ip);
>>> +			return 0;
>>> +		}
>>> +		mi->local_ip = local_ip;
>>> +	}
>> 
>> I'm wondering what kind of sanity checking is done on the srcaddr value.
>> 
>> 1.  Do we verify that srcaddr == clientaddr?
> 
> No, and I'm not sure we should.  If they are specifying
> both srcaddr and clientaddr, they are already in the rarely-used-options
> category, so maybe they know what they are doing.
> 
> And, if it clientaddr is automatically figured out by
> the kernel, then I think it must necessarily always be
> srcaddr.

Today the kernel doesn't automatically figure out a value for clientaddr=, that value is provided by the mount.nfs command.  I guess no harm is done if they are different, but you probably want to remove any comments or other documentation that suggests that is bad.  Maybe you've already done that.

> Makes me wonder though..could you do some sort of lame security
> violation by making clientaddr some third-party IP?
> 
>> 
>> 2.  Do we verify that srcaddr.sa_family == addr.sa_family ?
> 
> Not directly, but it will blow up in the bind() call if you
> try it:
> 
> strace -f mount -t nfs [2002::100:157]:/rpool/ben /mnt/lf/znfs36-sol-1 -o srcaddr=192.168.100.117,vers=3
> ...
> [pid  1488] munmap(0x7f0cd7b20000, 4096) = 0
> [pid  1488] socket(PF_INET6, SOCK_STREAM, IPPROTO_TCP) = 3
> [pid  1488] bind(3, {sa_family=AF_INET, sin_port=htons(0), sin_addr=inet_addr("192.168.100.117")}, 16) = -1 EINVAL (Invalid argument)
> 
> [root@ice-si-dmz fileio]# mount -t nfs [2002::100:157]:/rpool/ben /mnt/lf/znfs36-sol-1 -o srcaddr=192.168.100.117,vers=3
> mount.nfs: an incorrect mount option was specified
> 
> That sufficient you think?

I think it would be more helpful to admins if mount.nfs were more explicit about the problem.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




