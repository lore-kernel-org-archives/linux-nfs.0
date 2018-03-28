Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59140 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751072AbeC1OyG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 28 Mar 2018 10:54:06 -0400
Date: Wed, 28 Mar 2018 10:54:06 -0400
To: daedalus@pingtimeout.net
Cc: linux-nfs@vger.kernel.org
Subject: Re: Regarding client fairness
Message-ID: <20180328145406.GA2641@fieldses.org>
References: <f9c6c1c493d0dde6c4a24afeca00fa5b@pingtimeout.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <f9c6c1c493d0dde6c4a24afeca00fa5b@pingtimeout.net>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 28, 2018 at 02:04:57PM +0300, daedalus@pingtimeout.net wrote:
> I came across a rather annoying issue where a single NFS client
> caused resource starvation for NFS server. The server has several
> storage pools which are used, in this particular case a single
> client did fairly large read requests and effectively ate all nfsd
> threads on the server and during that other clients were getting
> hardly any I/O through to the other storage pool which was
> completely idle.

What version of the kernel are you running on your server?

--b.

> 
> I then proceeded to make a simple testcase and noticed that reading
> a file with large blocksize causes NFS server to read using multiple
> threads, effectively consuming all nfsd threads on the server and
> causing starvation to other clients regardless of the share/backing
> disk they were accessing.
> 
> In my testcase a simple (ridiculous) dd was able to effectively
> reserve the entire NFS server for itself:
> 
> # dd if=fgsfds bs=1000M count=10000 iflag=direct
> 
> Also several similar dd runs with blocksize of 100M caused the same
> effect. During those dd-runs the server was responding at a very
> slow rate to any other requests by other clients (or to other NFS
> shares on different disks on the server).
> 
> My question here is that are there any methods to ensure client
> fairness with Linux NFS and/or are there some best common practices
> to ensure something like that. I think it would be pretty awesome if
> clients had some kind of limit/fairness that would be scoped like
> {client, share-on-server} so client which accesses a single share on
> a server (with large read IO requests) would not effectively cause
> denial of service for the entire NFS server but rather only to the
> share it is accessing and at same time other clients accessing
> different/same share would get fair amount of access to the data.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
