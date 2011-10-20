Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43115 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754406Ab1JTRtZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Oct 2011 13:49:25 -0400
Date: Thu, 20 Oct 2011 13:49:15 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Christoph Hellwig <hch@infradead.org>, agruen@kernel.org,
        akpm@linux-foundation.org, viro@zeniv.linux.org.uk,
        dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        ebiederm@xmission.com
Subject: Re: [PATCH -V7 21/26] richacl: xattr mapping functions
Message-ID: <20111020174915.GA9987@fieldses.org>
References: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1318951981-5508-22-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20111019222021.GB1874@fieldses.org>
 <87k4805alx.fsf@linux.vnet.ibm.com>
 <20111020091434.GC5444@fieldses.org>
 <20111020091946.GA23773@infradead.org>
 <87aa8w53kj.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87aa8w53kj.fsf@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 20, 2011 at 04:32:04PM +0530, Aneesh Kumar K.V wrote:
> On Thu, 20 Oct 2011 05:19:46 -0400, Christoph Hellwig <hch@infradead.org> wrote:
> > On Thu, Oct 20, 2011 at 05:14:34AM -0400, J. Bruce Fields wrote:
> > > > > Does it really make sense to use a string here just to pick between the
> > > > > three choices OWNER@, GROUP@, and EVERYONE@?  Why not just another small
> > > > > integer?  Is the goal to expand this somehow eventually?
> > > > 
> > 
> > > > I guess Andreas wanted the disk layout to be able to store user@domain
> > > > format if needed.
> > > 
> > > Is that likely?  For that to be useful, tasks would need to be able to
> > > run as user@domain strings.  And we'd probably want owners and groups to
> > > also be user@domain strings.
> > > 
> > > The container people seem to eventually want to add some kind of
> > > namespace identifier everywhere:
> > > 
> > > 	http://marc.info/?l=linux-kernel&m=131836778427871&w=2
> > > 
> > > in which case I guess we'd likely end up with (uid, user namespace id)
> > > instead of user@domain?
> > 
> > 
> > Storing strings is an extremly stupid idea.  The only thing that would
> > make sense would be storing a windows-style 128-bit GUID.
> > 
> 
> How about updating the richacl_xattr as below 
> 
> struct richace_xattr {
> 	__le16		e_type;
> 	__le16		e_flags;
> 	__le32		e_mask;
> 	__le32		e_size;
> 	u8		e_id[0];
> };
> 
> now e_flags can contain ACE4_SPECIAL_WHO to indicate value in e_id
> indicate special who values (which could be 1 byte value indicating
> OWNER@, GROUP@ or EVERYONE@), ACE4_UNIXID_WHO, to indicate value
> in e_id is the little endian value of unix id. ACE_WINSID_WHO to
> indicate e_id is the 128 bit array containing SID value. ?

That's effectively still a string.

Would it be so bad to have to introduce another xattr type if we needed
a new id type?  You'll have to modify the filesystem and the userspace
tools and everything anyway, won't you?

But if we decide we don't need strings, then at a minimum let's make
these some fixed small size.

You could do something like:

	struct richace_xattr {
		__le16		e_type;
		__le16		e_flags;
		__le32		e_mask;
		__le32		e_id[4];
	}

and just use e_id[0] for now.  That would still leave room for a 128-bit
id, or for a 32-bit uid + some-size namespace-id.

Cc'ing Eric Biederman in hopes of finding out whether that would satifsy
whatever wacky future ideas might be expected for user namespaces.

--b.
