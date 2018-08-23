Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:53386 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727134AbeHXA23 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 23 Aug 2018 20:28:29 -0400
Date: Thu, 23 Aug 2018 16:57:03 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Paul B. Henson" <henson@acm.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfs4-acl-tools 0.3.5
Message-ID: <20180823205703.GH32415@fieldses.org>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <a52a1f00-69ba-4d09-ae91-d7ae7483d1c1@acm.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 23, 2018 at 12:41:49PM -0700, Paul B. Henson wrote:
> On 8/23/2018 7:38 AM, J. Bruce Fields wrote:
> 
> >>Does something specifically need to be done individually for each
> >>file system, or if it supports the standard extended attribute does
> >>any file system (including an out of tree file system)
> >>automatically function?
> >
> >Nothing special's required, it should be automatic.
> 
> So if, hypothetically, the NFSv4 server was enhanced to look for and
> understand the standard linux system.nfs4_acl extended attribute,
> any file system, whether in kernel or out of tree, would support
> exposing NFSv4 ACLs via NFS? Even though there's nothing ZFS
> specific about it, that general functionality would not be
> acceptable for inclusion in the mainstream kernel?

Right, it's against kernel policy, and even if it weren't, I don't want
to be in the position of maintaining code, even simple code, that's
really only needed for third-party modules without any path to upstream.

> That seems a bit of a chicken and egg problem, do you add a feature
> for a subsystem to use so said subsystem could be updated to use it,
> or you update a subsystem to use a feature that doesn't exist yet
> :)?

Honestly the system.nfs4_acl extended attribute interface, which just
exposes the raw xdr of the ACL to userspace, is kind of a kludge.  It
could be made to work for other filesystems but I was hoping that other
filesystems would adopt something designed for them from scratch (like
richacls).

That said, there *is* already an in-kernel filesystem that supports
system.nfs4_acl: knfsd does actually allow limited re-export of NFS.  So
knfsd code that used system.nfs4_acl when available might actually have
some use, I don't really know.  I'm a little skeptical of the idea, to
be honest.

--b.
