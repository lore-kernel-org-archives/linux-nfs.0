Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:16575 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933227Ab3HGVMT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Aug 2013 17:12:19 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: weird moutstats with pnfs
Date: Wed, 7 Aug 2013 21:12:18 +0000
Message-ID: <AFD56BCA-099D-4401-9110-10F5EB2882E2@netapp.com>
References: <1755011550.291762.1375907427574.JavaMail.zimbra@desy.de>
In-Reply-To: <1755011550.291762.1375907427574.JavaMail.zimbra@desy.de>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I see what's happening here. This is due to stat collection happening in the rpc layer, which works great until you have multiple RPC clients associated with one mountpoint (like pNFS with filelayout).

When we added pNFS READ/WRITE counting to /proc/self/mountstats, we incremented the read/write count on the rpc_client associated with the superblock of the mount being used (aka struct nfs_server), even though the write may have actually happened on a different rpc client (MDS != DS).  The 'rpcsends' (and I'm sure recvs) counter is not being updated in this case, and that's what the WRITE count is being divided by (in the userland mountstats program) to come up with the percentage.

I'll look at fixing this - I think we just want to update send & recv counters on the superblock's rpc_client stats when it's a DS READ/WRITE.

-dros

On Aug 7, 2013, at 4:30 PM, "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de> wrote:

> 
> Hi, 
> 
> I am running some IO tests with pNFS and see some strange(at least to me) numbers:
> 
> WRITE:
> 	44316 ops (249%) 	0 retrans (0%) 	0 major timeouts
> 	avg bytes sent per op: 179112	avg bytes received per op: 111
> 	backlog wait: 2416.041204 	RTT: 11.033735 	total execute time: 2427.148953 (milliseconds)
> 
> 
> 249% What does it tell me?
> 
> This is fedora19 with 3.10.3-300.fc19.x86_64 kernel.
> 
> Tigran.

