Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56807 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750751Ab1JTKZr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Oct 2011 06:25:47 -0400
Date: Thu, 20 Oct 2011 06:25:38 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, agruen@kernel.org,
        akpm@linux-foundation.org, viro@zeniv.linux.org.uk,
        dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V7 21/26] richacl: xattr mapping functions
Message-ID: <20111020102538.GG5444@fieldses.org>
References: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1318951981-5508-22-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20111019222021.GB1874@fieldses.org>
 <87k4805alx.fsf@linux.vnet.ibm.com>
 <20111020091434.GC5444@fieldses.org>
 <20111020091946.GA23773@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111020091946.GA23773@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 20, 2011 at 05:19:46AM -0400, Christoph Hellwig wrote:
> On Thu, Oct 20, 2011 at 05:14:34AM -0400, J. Bruce Fields wrote:
> > > > Does it really make sense to use a string here just to pick between the
> > > > three choices OWNER@, GROUP@, and EVERYONE@?  Why not just another small
> > > > integer?  Is the goal to expand this somehow eventually?
> > > 
> 
> > > I guess Andreas wanted the disk layout to be able to store user@domain
> > > format if needed.
> > 
> > Is that likely?  For that to be useful, tasks would need to be able to
> > run as user@domain strings.  And we'd probably want owners and groups to
> > also be user@domain strings.
> > 
> > The container people seem to eventually want to add some kind of
> > namespace identifier everywhere:
> > 
> > 	http://marc.info/?l=linux-kernel&m=131836778427871&w=2
> > 
> > in which case I guess we'd likely end up with (uid, user namespace id)
> > instead of user@domain?
> 
> 
> Storing strings is an extremly stupid idea.  The only thing that would
> make sense would be storing a windows-style 128-bit GUID.
> 

So if we want to do this without strings:

> > > +struct richace_xattr {
> > > + __le16          e_type;
> > > + __le16          e_flags;
> > > + __le32          e_mask;
> > > + __le32          e_id;
> > > + char            e_who[0];

We could drop that last field and use some predefined values for e_id to
represent owner/group/everyone in the e_type == ACE4_SPECIAL_WHO case.

Then I'm not sure how you'd extend it if you later decided to add
Windows GUID's or whatever.

But maybe it's not realistic to expect to be able to do that without a
new interface and on-disk format: how could old software be expected to
deal with acls that didn't use uid's?

--b.
