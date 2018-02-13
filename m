Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:55426 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S965344AbeBMS2b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Feb 2018 13:28:31 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Harald Dunkel" <harald.dunkel@aixigo.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: running NFS in LXC
Date: Tue, 13 Feb 2018 13:28:30 -0500
Message-ID: <6860CF8E-9790-4456-82D3-86A6A29E90BE@redhat.com>
In-Reply-To: <5cedd413-81eb-6921-47bc-3c56e56d530a@aixigo.de>
References: <5cedd413-81eb-6921-47bc-3c56e56d530a@aixigo.de>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Harri,

I think this is a very effective and simple approach to building out a 
hardware resilient NFS service.

I have some experience with this approach running multiple (< 100) NFS 
servers in VMs that could started and moved between hardware hosts.  If 
you have the hardware for it (or want to use iSCSI), you don't need DRBD 
- only a way to share your block devices between nodes and ensure that 
each is only used by a single host at a time.

We also created some automated orchestration that was able to deploy new 
NFS servers and dynamically migrate parts of the filesystem tree to new 
servers, which gave us a lot of capability to scale horizontally.

I really think the containerized or virtualized knfsd is a nice solution 
to both hardware failure and horizontal scaling if your use-case allows 
brief outages for part of the filesystem's tree.

I'm happy to share more, or hear more about your experience.

Ben


On 13 Feb 2018, at 4:55, Harald Dunkel wrote:

> Hi folks,
>
> to support a HA setup I have a block device mirrored via
> drbd on 2 hosts (write-through). The drbd Primary runs
> the NFS service, using a dedicated IP address. NFS is not
> running on the drbd Secondary.
>
> To make this work I have to move several system files and
> /var directories to a file system on the mirrored block
> device as well. This is pretty clumsy, it breaks system
> updates, etc.
>
> Question: What if I run the NFS service in a LXC container
> instead?
>
> The idea is to put the whole service as a container on the
> same block device as the NFS export partitions. In case of
> a hardware failure on the Primary I can stop the NFS service,
> make the Secondary to the new Primary and start the NFS
> service on the other hardware again.
>
> Do you expect some serious problems here? Please share your
> thoughts. Every helpful comment is highly appreciated.
>
>
> Harri
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" 
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
