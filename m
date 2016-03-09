Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp2.wiktel.com ([69.89.207.152]:36223 "EHLO smtp2.wiktel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750819AbcCIVmR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Mar 2016 16:42:17 -0500
Subject: Re: PROBLEM: NFS Client Ignores TCP Resets
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        trond.myklebust@primarydata.com
References: <56BFE55D.1010509@wiktel.com> <56DF067F.4090606@wiktel.com>
 <56E092C3.6030508@Netapp.com>
Cc: linux-nfs@vger.kernel.org
From: Richard Laager <rlaager@wiktel.com>
Message-ID: <56E098B8.4030805@wiktel.com>
Date: Wed, 9 Mar 2016 15:42:16 -0600
MIME-Version: 1.0
In-Reply-To: <56E092C3.6030508@Netapp.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for looking at this!

On 03/09/2016 03:16 PM, Anna Schumaker wrote:
> I'm looking into this, but I'm not yet sure of what the client is doing.  Your packet trace makes it look like we do recover, although I don't know why it takes more than one RST packet.

Correct, it does recover, but only after several minutes. I think that's 
the length of some NFS timeout. To be clear, it's a *fixed length of 
time*, not AFAIK a specific number of RST packets, before it works.

> Is this easy for you to reproduce?  It would be great if you can send me debugging statements from the client.  You can enable them with the command:  `rpcdebug -m rpc -s trans call` and then rerun the failover.  Client messages should show up in dmesg.

It is 100% reproducible, but the failover process does have some impact 
on production services, so I have to wait until after hours. I can run 
that test tonight. Is there anything else you'd like me to test at the 
same time?

-- 
Richard
