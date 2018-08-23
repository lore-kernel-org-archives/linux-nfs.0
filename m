Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:52712 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730300AbeHWSId (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 23 Aug 2018 14:08:33 -0400
Date: Thu, 23 Aug 2018 10:38:35 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Paul B. Henson" <henson@acm.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfs4-acl-tools 0.3.5
Message-ID: <20180823143835.GB1019@fieldses.org>
References: <20180807193736.GA18187@fieldses.org>
 <20180821165130.GA14413@fieldses.org>
 <5fa4b700-3d45-cda3-37ed-bdfbd427574d@acm.org>
 <20180822003301.GA17500@fieldses.org>
 <d4649560-ad74-d119-13ba-876af9a4974e@acm.org>
 <20180822151213.GA24172@fieldses.org>
 <c1b05b61-b85e-7dff-8cff-12b85bffb3c6@acm.org>
 <20180822194620.GA25562@fieldses.org>
 <2be55f4f-4c9c-9ee1-72f4-b21e37336b6e@acm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2be55f4f-4c9c-9ee1-72f4-b21e37336b6e@acm.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 22, 2018 at 06:11:20PM -0700, Paul B. Henson wrote:
> >You could try to port them to some other filesystem (xfs, ext4).
> 
> The ZFS on Linux port already supports the standard POSIX ACL. I'm
> curious, do those work with the NFS server?

Yes.  Sort of.  There's a sideband protocol for NFSv3 that supports them
pretty much as they are.  NFSv4 only has NFSv4 ACLs, so we support them
by translating between "posix" and NFSv4 ACLs on the fly, and the
result can be a pain to use.

> Does something specifically need to be done individually for each file
> system, or if it supports the standard extended attribute does any
> file system (including an out of tree file system) automatically
> function?

Nothing special's required, it should be automatic.

--b.
