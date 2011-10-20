Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail09.linbit.com ([212.69.161.110]:38664 "EHLO
	mail09.linbit.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933Ab1JTXzq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Oct 2011 19:55:46 -0400
Subject: Re: [PATCH -V7 21/26] richacl: xattr mapping functions
From: Andreas Gruenbacher <agruen@kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
        akpm@linux-foundation.org, viro@zeniv.linux.org.uk,
        dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Fri, 21 Oct 2011 01:46:29 +0200
In-Reply-To: <20111020102538.GG5444@fieldses.org>
References: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <1318951981-5508-22-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <20111019222021.GB1874@fieldses.org> <87k4805alx.fsf@linux.vnet.ibm.com>
	 <20111020091434.GC5444@fieldses.org> <20111020091946.GA23773@infradead.org>
	 <20111020102538.GG5444@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1319154390.2270.52.camel@schurl.linbit>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2011-10-20 at 06:25 -0400, J. Bruce Fields wrote:
> On Thu, Oct 20, 2011 at 05:19:46AM -0400, Christoph Hellwig wrote:
> > On Thu, Oct 20, 2011 at 05:14:34AM -0400, J. Bruce Fields wrote:
> > > > > Does it really make sense to use a string here just to pick between the
> > > > > three choices OWNER@, GROUP@, and EVERYONE@?  Why not just another small
> > > > > integer?  Is the goal to expand this somehow eventually?
> > > > 
> > 
> > > > I guess Andreas wanted the disk layout to be able to store user@domain
> > > > format if needed.

Yep.  On the other hand, none of the code won't actually allow to use
user@domain identifiers, it won't help with other identifier types like
Windows SIDs, and it doesn't make the code any prettier, so this should
probably go away.

> > > Is that likely?  For that to be useful, tasks would need to be able to
> > > run as user@domain strings.  And we'd probably want owners and groups to
> > > also be user@domain strings.

I really don't see this happen anytime soon, and likely not at all.

> > > The container people seem to eventually want to add some kind of
> > > namespace identifier everywhere:
> > > 
> > > 	http://marc.info/?l=linux-kernel&m=131836778427871&w=2
> > > 
> > > in which case I guess we'd likely end up with (uid, user namespace id)
> > > instead of user@domain?

The filesystem still wouldn't have namespace ids for the owner and
owning group, which is a much bigger issue.  I think we're safe not to
worry about namespace ids at this point; they also might never happen.

> > Storing strings is an extremly stupid idea.  The only thing that would
> > make sense would be storing a windows-style 128-bit GUID.
> > 
> 
> So if we want to do this without strings:
> 
> > > > +struct richace_xattr {
> > > > + __le16          e_type;
> > > > + __le16          e_flags;
> > > > + __le32          e_mask;
> > > > + __le32          e_id;
> > > > + char            e_who[0];
> 
> We could drop that last field and use some predefined values for e_id to
> represent owner/group/everyone in the e_type == ACE4_SPECIAL_WHO case.

That makes sense to me.

There seems to be a WELL_KNOWN_SID_TYPE enumeration which maps those
kinds of special identifiers to small integers in Windows; maybe it
makes sense to use the same numbers for OWNER@, GROUP@, and EVERYONE@.

> Then I'm not sure how you'd extend it if you later decided to add
> Windows GUID's or whatever.
> 
> But maybe it's not realistic to expect to be able to do that without a
> new interface and on-disk format: how could old software be expected to
> deal with acls that didn't use uid's?

The acl itself has a version field, so new formats could be introduced
in the future with a new version.

Thanks,
Andreas

