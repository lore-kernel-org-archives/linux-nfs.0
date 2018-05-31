Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55926 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755025AbeEaPSU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 31 May 2018 11:18:20 -0400
Date: Thu, 31 May 2018 11:18:19 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: "Shawn Lu (shawlu)" <shawlu@cisco.com>
Cc: Joshua Watt <jpewhacker@gmail.com>,
        "trond.myklebust@primarydata.com" <trond.myklebust@primarydata.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Is "unmount -f"  worked as expected?
Message-ID: <20180531151819.GC1298@fieldses.org>
References: <8CC8F228-1A66-4A44-A23B-855E33F4D1D5@cisco.com>
 <0dae4862d6e5b754ba8f90a6391b6645fdf6889a.camel@gmail.com>
 <EE6D39C5-09BB-4133-9CF5-674038E1538F@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <EE6D39C5-09BB-4133-9CF5-674038E1538F@cisco.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 31, 2018 at 03:14:44PM +0000, Shawn Lu (shawlu) wrote:
>  Thanks Joshua for great help.   From context provided by joshua, I am
>  believe that the community is full aware of the “-f “ issue, but
>  still pending on solution. 
> 
>  Wondering whether community have consensus yet on what should be the
>  correct behavior for “ force unmount”?  I hope maintainer of NFS can
>  give some guardian for direction.
> 
> My use case is also on embedded system where NFS server can go offline
> unexpected. What I looks for is something that can aggressive umount
> NFS in timely manner.  Data loss is secondly in my situation.

Dumb question: in that case, why not just cut power?

> One case is involved with  cross mounted nfs from different host.

Note: in theory I think there are some deadlocks possible if client and
server mount each other.  (Each host could be waiting on the other one
to process writes before it can free memory that it needs to make
progress.)

--b.

> Here,
> both server and client will be  shutdown at same time on reboot.  NFS
> client side will stuck on shutdown for long time if “umount –l”  is
> used to umount NFS.
> 
> The previous work done by Joshua and  Neil Brown will definitely help
> to resolve my use case if patch can be up streamed.  Hope magic will
> happen soon . 
> 
> Just wondering whether a kernel configure (eg.
> CONFIG_NFS_AGRRESSIVE_SHUTDOWN)  can be added to enhance “force
> umount “ to act more aggressive.  This feature will be off by default
> so the admin use to the “soft “ force mount will get the same behavior
> as before.  When the feature is turn on,  “umount –f”  is Guarantee to
> succeed.  
