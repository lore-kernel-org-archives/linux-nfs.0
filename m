Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lisa.pbhware.com ([96.251.22.156]:20810 "EHLO lisa.pbhware.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726091AbeHWEiq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 23 Aug 2018 00:38:46 -0400
Subject: Re: nfs4-acl-tools 0.3.5
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
References: <20180807193736.GA18187@fieldses.org>
 <20180821165130.GA14413@fieldses.org>
 <5fa4b700-3d45-cda3-37ed-bdfbd427574d@acm.org>
 <20180822003301.GA17500@fieldses.org>
 <d4649560-ad74-d119-13ba-876af9a4974e@acm.org>
 <20180822151213.GA24172@fieldses.org>
 <c1b05b61-b85e-7dff-8cff-12b85bffb3c6@acm.org>
 <20180822194620.GA25562@fieldses.org>
From: "Paul B. Henson" <henson@acm.org>
Message-ID: <2be55f4f-4c9c-9ee1-72f4-b21e37336b6e@acm.org>
Date: Wed, 22 Aug 2018 18:11:20 -0700
MIME-Version: 1.0
In-Reply-To: <20180822194620.GA25562@fieldses.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 8/22/2018 12:46 PM, J. Bruce Fields wrote:
> 
>> I'll strip them out and send you a patch soon; hopefully it won't 
>> take 10 more years to show up in a release :).
> 
> OK, great, thanks.

Patch sent; it was pretty trivial, hopefully it will suffice.

> I can't take knfsd patches to support something that only an
> out-of-tree filesystem cares about.

Hmm, I hadn't considered that, but I understand the position.

> Looks like ZFS has pretty much no chance of going upstream.

Yah, GPL, CDDL, they don't get along :(.

> You could try to port them to some other filesystem (xfs, ext4).

The ZFS on Linux port already supports the standard POSIX ACL. I'm 
curious, do those work with the NFS server? Does something specifically 
need to be done individually for each file system, or if it supports the 
standard extended attribute does any file system (including an out of 
tree file system) automatically function?

> But the attempt to implement rich ACLs (which are pretty similar)
> seemed to get vetoed for reasons I don't completely understand, and I
> don't see why this would fare any better.

While they have different implementation details, NFSv4 ACLs and rich 
ACLs seem to have compatible expression formats. If they ever do get 
implemented, I'd be able to switch from the somewhat inefficient 
system.nfs4 extended attribute interface between the kernel and user 
space for ZFS ACLs to a rich ACL API... And if the NFS server would 
simply work with any file system that exported a standard rich ACL, 
maybe ZFS would work then.

> So I think you'd be stuck carrying your own out-of-tree patches for
> it.

Hmm, that would greatly reduce the size of the user base; most 
distributions now make ZFS available via their packaging systems, but I 
don't know how many would be willing to include an extra ZFS specific 
kernel patch for NFS service.

Thanks again…
