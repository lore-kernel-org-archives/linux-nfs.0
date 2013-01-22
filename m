Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:35211 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752750Ab3AVR0k (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jan 2013 12:26:40 -0500
Message-ID: <50FECBCE.70108@candelatech.com>
Date: Tue, 22 Jan 2013 09:26:38 -0800
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: Eric Dumazet <eric.dumazet@gmail.com>
CC: netdev <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: 3.7.3+:  Bad paging request in ip_rcv_finish while running NFS
 traffic.
References: <50FDADF4.3060601@candelatech.com>  <50FDDE35.7070806@candelatech.com>  <1358829606.3464.3151.camel@edumazet-glaptop>  <50FE2A57.3040804@candelatech.com>  <50FEC796.5090404@candelatech.com> <1358875020.3464.4006.camel@edumazet-glaptop>
In-Reply-To: <1358875020.3464.4006.camel@edumazet-glaptop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/22/2013 09:17 AM, Eric Dumazet wrote:
> On Tue, 2013-01-22 at 09:08 -0800, Ben Greear wrote:
>
>> Unfortunately, I hit it again this morning after the first restart of
>> my application (which bounces all 3000 interfaces).  Memory poisoning
>> was disabled.
>
> Is your NFS traffic using TCP or UDP ?

It's using TCP.

Thanks,
Ben

>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

