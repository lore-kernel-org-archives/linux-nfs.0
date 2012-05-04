Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:58793 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751679Ab2EDIJm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 May 2012 04:09:42 -0400
Message-ID: <4FA38EB9.2010302@panasas.com>
Date: Fri, 4 May 2012 11:09:29 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Marek Stopka <mstopka@opensuse.org>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: MultiPath NFS (Oracle DirectNFS)
References: <CABdhxhS+OscW43pHLodfKQ-qV9ddLaJ1Dasp9s3H902_vCU-gQ@mail.gmail.com>
In-Reply-To: <CABdhxhS+OscW43pHLodfKQ-qV9ddLaJ1Dasp9s3H902_vCU-gQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/04/2012 01:31 AM, Marek Stopka wrote:

> Hi,
> as you might already know, Oracle 11g have its own implementation of NFS called
> DirectNFS, it works pretty with very same NFSv3 protocol as everyone else,
> except it implements some advanced features on a client side, such as MultiPath.
> 
> Currently if you want to have multiple physical paths to storage in Linux
> environment, you need to configure Ethernet bonding, which might be a pain over
> multiple physical switches, especially when you consider adding capacity as well
> as redundancy. With Direct NFS you configure each path to a storage as separate
> L1/L2/L3 domain with no support from Ethernet whatsoever and Oracle NFS client
> "knows" these multiple IP addresses you provided leads to same storage with same
> data and it automatically distributes your requests over these three paths.
> 
> Have you ever considered implementing same functionality in kernel NFS client?
> It have some advantages over bonding/etherchannel scenario, such as you are
> protected against L2 netwokr errors, whatever happends in one path L2 domain,
> will not affect others paths L2 domains. It will remove all complexity of
> bonding ethernet interfaces, which does not always work with all Ethernet
> drivers for all Ethernet cards,... While at a same time, you can implement
> redundancy and increased performance with multiple paths to the storage even
> without advanced switches (Nexus with vPC, Catalyst with VSS,..) because you
> don't need any link aggregation protocols to work over multiple
> physical switches...
> 


A well crafted pNFS MDS Server could achieve the same exact results and more
with the existing v4.1 pnfs client. It's kind of the point to all this.

So it's not done over NFSv3 but it surly exists if willing to move to
pnfs

Think about it: Other then plain NFSv3 as a cluster there is a new Protocol
running that conveys the topology of the cluster to clients - the multipath list.
That's exactly the pnfs-layout. Only more automatic, more dynamic, and more cluster
configurations then plain old multipath.

"Been there done that"
Cheers
Boaz

> http://www.oracle.com/technetwork/articles/directnfsclient-11gr1-twp-129785.pdf
> - Direct NFS whitepaper
> --
> S pozdravem / Best regards
> Marek Stopka
> Kontakty / Contacts
> Mobil/Cell phone:+420 608 149 955
> WEB: www.stopkaconsulting.eu
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


