Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.133]:57416 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726482AbeHXJYN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Aug 2018 05:24:13 -0400
Date: Thu, 23 Aug 2018 22:51:08 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "Paul B. Henson" <henson@acm.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: nfs4-acl-tools 0.3.5
Message-ID: <20180824055108.GA31235@infradead.org>
References: <20180821165130.GA14413@fieldses.org>
 <5fa4b700-3d45-cda3-37ed-bdfbd427574d@acm.org>
 <20180822003301.GA17500@fieldses.org>
 <d4649560-ad74-d119-13ba-876af9a4974e@acm.org>
 <20180822151213.GA24172@fieldses.org>
 <c1b05b61-b85e-7dff-8cff-12b85bffb3c6@acm.org>
 <20180822194620.GA25562@fieldses.org>
 <2be55f4f-4c9c-9ee1-72f4-b21e37336b6e@acm.org>
 <20180823143835.GB1019@fieldses.org>
 <470be466-b762-1cf2-83b1-98b535c17909@acm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <470be466-b762-1cf2-83b1-98b535c17909@acm.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 23, 2018 at 12:41:23PM -0700, Paul B. Henson wrote:
> On 8/23/2018 7:38 AM, J. Bruce Fields wrote:
> 
> > > Does something specifically need to be done individually for each
> > > file system, or if it supports the standard extended attribute does
> > > any file system (including an out of tree file system)
> > > automatically function?
> > 
> > Nothing special's required, it should be automatic.
> 
> So if, hypothetically, the NFSv4 server was enhanced to look for and
> understand the standard linux system.nfs4_acl extended attribute, any file
> system, whether in kernel or out of tree, would support exposing NFSv4 ACLs
> via NFS? Even though there's nothing ZFS specific about it, that general
> functionality would not be acceptable for inclusion in the mainstream
> kernel?

Hell no.  We're not going to support anything out of tree in general,
and not something that violates our licensing terms for that matter.
