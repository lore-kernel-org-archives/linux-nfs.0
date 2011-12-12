Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58940 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753267Ab1LLQNt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Dec 2011 11:13:49 -0500
Date: Mon, 12 Dec 2011 11:13:48 -0500
To: John Simon <tzzhc4@yahoo.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Intermittent performance issues with Solaris 10 NFS V3 client
 to RHEL 5.5 NFS server
Message-ID: <20111212161348.GG18185@fieldses.org>
References: <1323633645.16114.YahooMailClassic@web181402.mail.ne1.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1323633645.16114.YahooMailClassic@web181402.mail.ne1.yahoo.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Dec 11, 2011 at 12:00:45PM -0800, John Simon wrote:
> I recently attached a Solaris 10 8/07 client (6900 with ce gigbit
> interface) to our NFS server which runs RHEL 5.5 (kernel
> 2.6.18-194.el5).

Could you file a bug against Red Hat and/or Solaris?

> Performance typically is good running around
> 25-50MB/s but sometimes seemingly without reason the performance drops
> to abysmal levels and will stay like that until NFS is unmounted and
> remounted. I have tested this after hours when there is no load on
> either server, no traffic on the network and using a 1GB test file.
> Our other 300 Linux clients have no performance issues, I have ruled
> out network issues by isolating the server to a switch dedicated to it
> and an additional port on the NFS server and the tests I performed
> were with the file cache in memory.
> 
> $ time cp /var/tmp/1g.TEST.new /mnt/ real    25m1.456s user
> 0m0.276s sys     0m6.699s
> 
> After an unmount, wait 5 minutes and remount:
> 
> $ time cp /var/tmp/1g.TEST.new /mnt/ real    0m26.767s user
> 0m0.277s sys     0m6.589s
> 
> Mount options I am using on Solaris:
> 
>   Flags:
>   vers=3,proto=tcp,sec=none,hard,intr,link,symlink,acl,rsize=32768,wsize=32768,retrans=5,timeo=600
>   Attr cache:    acregmin=120,acregmax=120,acdirmin=120,acdirmax=120

Some ideas:

	- Anything interesting in the logs on client or server?
	- If you look at a small part of the network traffic in
	  wireshark, in the bad case, is there any obvious problem?
	  (Lots of retransmissions, errors returned from the server, ?)
	- Can you get any rpc statistics out of the client?  (Average
	  time to respond to an rpc, mix of rpc's sent, etc.?)

--b.
