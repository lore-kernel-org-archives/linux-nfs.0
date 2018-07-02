Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mails2n1-route0.email.arizona.edu ([128.196.130.123]:49314 "EHLO
        mails2n1-route0.email.arizona.edu" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932080AbeGBXWe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jul 2018 19:22:34 -0400
Subject: Re: RDMA connection closed and not re-opened
Cc: Chuck Lever <chucklever@gmail.com>
References: <f1e596cf-0e70-39af-99e9-a0a7e912bad3@genome.arizona.edu>
 <4A72535B-E6D2-4E8A-B6DB-BF09856A41EB@gmail.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: admin@genome.arizona.edu
Message-ID: <19cd3809-669b-2d63-d453-ed553c9e01a9@genome.arizona.edu>
Date: Mon, 2 Jul 2018 16:22:32 -0700
MIME-Version: 1.0
In-Reply-To: <4A72535B-E6D2-4E8A-B6DB-BF09856A41EB@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks Chuck for your input, let me address it below like normal for 
mailing lists.  Although I'm confused as to why my message hasn't shown 
up on the mailing list, even though I'm subscribed with this address... 
I've written to owner-linux-nfs@vger.kernel.org regarding this 
discrepancy and it was rejected as spam so now i'm waiting to hear from 
postmaster@vger.kernel.org, so I guess I'll need to continue to CC you 
as well in the time being since your responses show up on the mailing 
list at least...


Chuck Lever wrote on 06/29/2018 08:04 AM:
 > These are informational messages that are typical of network
 > problems or maybe the server has failed or is overloaded. I'm
 > especially inclined to think this is not a client issue because it
 > happens on multiple clients at around the same time.

Yes it makes sense to be a server problem, however our server is more 
than capable of handling this I would think.  Although it is an older 
server, it still has 2x 6-core Intel Xeon E5-2620 v2 @ 2.10GHz with 
128GB of RAM and maybe 10% utilization normally.  I have not watched the 
server when we start these daligner jobs so that could be something I 
look for to see if I notice any bottlenecks... what is a typical 
bottleneck for NFS/RDMA?


 > If there are no other constraints on your NFS server's kernel /
 > distribution, I recommend upgrading it to a recent update of CentOS
 > 7 (not simply a newer CentOS 6 release).

Unfortunately CentOS doesn't support upgrading from 6 to 7 and this 
machine is too critical to take down for a fresh 
installation/reconfiguration, so I have a feeling we'll need to figure 
out how to get the 6.9 kernel working.  I will try updating to the 
latest kernel on all of the nodes to see if it helps.


