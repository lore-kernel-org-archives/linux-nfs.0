Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48661 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754616Ab1IHXVW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Sep 2011 19:21:22 -0400
Date: Thu, 8 Sep 2011 16:08:53 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: agruen@kernel.org, akpm@linux-foundation.org, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V6 11/26] vfs: Add permission flags for setting file
 attributes
Message-ID: <20110908200853.GC17215@fieldses.org>
References: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1315243548-18664-12-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20110907205503.GG8074@fieldses.org>
 <87d3fb5qbg.fsf@skywalker.in.ibm.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87d3fb5qbg.fsf@skywalker.in.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 08, 2011 at 03:06:03PM +0530, Aneesh Kumar K.V wrote:
> On Wed, 7 Sep 2011 16:55:03 -0400, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > On Mon, Sep 05, 2011 at 10:55:33PM +0530, Aneesh Kumar K.V wrote:
> > > From: Andreas Gruenbacher <agruen@kernel.org>
> > > 
> > > Some permission models can allow processes to take ownership of a file,
> > > change the file permissions, and set the file timestamps.  Introduce new
> > > permission mask flags and check for those permissions in
> > > inode_change_ok().
> > 
> > These little helper functions seem like they might be reasonable cleanup
> > even without the richacl_change_ok() piece; wonder if it'd be worth
> > splitting out the cleanup and applying it now?
> > 
> > Not that it's necessary--seems like a straightforward enough patch as
> > is.
> 
> Those helpers also have richacl_chage_ok(..) done as a part of the call. So
> they cannot directly be applied to upstream. But we can do similar
> helpers for upstream and add richacl changes as a separate patch ? Is
> that what you are suggesting. I can split this patch to two in that case

Yes, that's what I was suggesting, though I don't feel terribly strong
about it; up to you whether you think it's worth it.

--b.
