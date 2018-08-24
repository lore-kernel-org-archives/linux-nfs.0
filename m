Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lisa.pbhware.com ([96.251.22.156]:41059 "EHLO lisa.pbhware.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725951AbeHXEWx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 24 Aug 2018 00:22:53 -0400
Subject: Re: nfs4-acl-tools 0.3.5
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
References: <20180821165130.GA14413@fieldses.org>
 <5fa4b700-3d45-cda3-37ed-bdfbd427574d@acm.org>
 <20180822003301.GA17500@fieldses.org>
 <d4649560-ad74-d119-13ba-876af9a4974e@acm.org>
 <20180822151213.GA24172@fieldses.org>
 <c1b05b61-b85e-7dff-8cff-12b85bffb3c6@acm.org>
 <20180822194620.GA25562@fieldses.org>
 <2be55f4f-4c9c-9ee1-72f4-b21e37336b6e@acm.org>
 <20180823143835.GB1019@fieldses.org>
 <a52a1f00-69ba-4d09-ae91-d7ae7483d1c1@acm.org>
 <20180823205703.GH32415@fieldses.org>
From: "Paul B. Henson" <henson@acm.org>
Message-ID: <584be3e5-f4d1-3082-5e2c-1a4a74248f22@acm.org>
Date: Thu, 23 Aug 2018 17:50:22 -0700
MIME-Version: 1.0
In-Reply-To: <20180823205703.GH32415@fieldses.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 8/23/2018 1:57 PM, J. Bruce Fields wrote:

> Honestly the system.nfs4_acl extended attribute interface, which
> just exposes the raw xdr of the ACL to userspace, is kind of a
> kludge.  It could be made to work for other filesystems but I was
> hoping that other filesystems would adopt something designed for them
> from scratch (like richacls).

I agree; but it's what I have to work with :). And from a pragmatic 
perspective I'd rather have something that works even if not perfect 
than perfect vaporware I can't use ;). If something like richacls comes 
along at some point in the future it should be possible to migrate to it.

> That said, there *is* already an in-kernel filesystem that supports 
> system.nfs4_acl: knfsd does actually allow limited re-export of NFS.
> So knfsd code that used system.nfs4_acl when available might actually
> have some use, I don't really know.  I'm a little skeptical of the
> idea, to be honest.

Hmm, the door is open a crack :). When I get a chance to put something 
together I'll be back…

 From a design perspective, would you want this to just take the 
verbatim xdr encoded acl from the file system and shove it over the 
wire, or would you want the NFS server to decode the acl received from 
the extended attribute, process or sanity check as necessary, and then 
re-encode it to send over the wire? The same I guess for ones received 
over the network, pass as is to fs xattr call or decode/re-encode.

Thanks…
