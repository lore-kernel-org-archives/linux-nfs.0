Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:32851 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831Ab0IAXuI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Sep 2010 19:50:08 -0400
Message-ID: <4C7EE6AE.6060209@candelatech.com>
Date: Wed, 01 Sep 2010 16:50:06 -0700
From: Ben Greear <greearb@candelatech.com>
To: Sorin Faibish <sfaibish@emc.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Does the 2.6.34 kernel support NFS over IPv6?
References: <4C7ECD62.7020802@candelatech.com> <op.vidoaslgrwwil4@sfaibish1.corp.emc.com>
In-Reply-To: <op.vidoaslgrwwil4@sfaibish1.corp.emc.com>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/01/2010 04:45 PM, Sorin Faibish wrote:
> Yes. We tested at connectathon with Fedora.
>
>
> On Wed, 01 Sep 2010 18:02:10 -0400, Ben Greear <greearb@candelatech.com>
> wrote:
>
>> If not, do more recent kernels?
>>
>> I'm using Fedora 13.
> Should work if configured properly.

How about as a server?  It doesn't seem to listen on IPv6
addresses.  I tried 2.6.36-rc2+ kernel as well.

I tried setting /etc/exports to look like this:

[root@localhost ~]# more /etc/exports
/exports/tmp [2002::0/16](rw)

[root@localhost ~]# netstat -an|grep LISTEN |grep 2049
tcp        0      0 0.0.0.0:2049                0.0.0.0:*                   LISTEN

I'm trying to test some NFS/IPv6 client changes, but I need
at least a minimal IPv6 server to test against!

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

