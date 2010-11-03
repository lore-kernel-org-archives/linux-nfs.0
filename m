Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:53897 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752818Ab0KCSa6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Nov 2010 14:30:58 -0400
Received: by qyk10 with SMTP id 10so361851qyk.19
        for <linux-nfs@vger.kernel.org>; Wed, 03 Nov 2010 11:30:57 -0700 (PDT)
Message-ID: <4CD1AAE2.3020003@gmail.com>
Date: Wed, 03 Nov 2010 14:33:06 -0400
From: Joe Landman <joe.landman@gmail.com>
To: Shehjar Tikoo <shehjart@gluster.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Streaming perf problem on 10g
References: <766909857.700951.1288807081999.JavaMail.root@mb2>
In-Reply-To: <766909857.700951.1288807081999.JavaMail.root@mb2>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 11/03/2010 01:58 PM, Shehjar Tikoo wrote:
> Hi All,
>
> I am running into a performance problem with 2.6.32-23 Ubuntu lucid on both client and server.
>
> The disk is an SSD performing at 1.4 - 1.6Gbps for a dd of a 6gb file in 64k blocks.
>    

If the size of this file is comparable to or smaller than the client or 
server ram, this number is meaningless.

> The network is performing fine with many Gbps of iperf throughput.
>    

GbE gets you 1 Gbps.  10GbE may get you from 3-10 Gbps, depending upon 
many things.  What are  your numbers?

> Yet, the dd write performance over the nfs mount point ranges from 96-105 Mbps for a 6gb file in 64k blocks.
>    

Sounds like you are writing over the gigabit, and not the 10GbE interface.

> I've tried changing the tcp_slot_table_entries and the wsize but there is negligible gain from these.
>
> Does it sound like a client side inefficiency?
>    

Nope.

-- 
Joseph Landman, Ph.D
Founder and CEO
Scalable Informatics Inc.
email: landman@scalableinformatics.com
web : http://scalableinformatics.com
phone: +1 734 786 8423 x121
fax : +1 866 888 3112
cell : +1 734 612 4615
