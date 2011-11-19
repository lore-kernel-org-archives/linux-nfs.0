Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out02.mta.xmission.com ([166.70.13.232]:54666 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752190Ab1KSJ1N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 19 Nov 2011 04:27:13 -0500
From: ebiederm@xmission.com (Eric W. Biederman)
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
        Christoph Hellwig <hch@infradead.org>, agruen@kernel.org,
        akpm@linux-foundation.org, viro@zeniv.linux.org.uk,
        dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Serge E. Hallyn" <serge@hallyn.com>,
        Andreas Dilger <adilger@dilger.ca>
References: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<1318951981-5508-22-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<20111019222021.GB1874@fieldses.org>
	<87k4805alx.fsf@linux.vnet.ibm.com>
	<20111020091434.GC5444@fieldses.org>
	<20111020091946.GA23773@infradead.org>
	<87aa8w53kj.fsf@linux.vnet.ibm.com>
	<20111020174915.GA9987@fieldses.org>
Date: Sat, 19 Nov 2011 01:28:10 -0800
In-Reply-To: <20111020174915.GA9987@fieldses.org> (J. Bruce Fields's message
	of "Thu, 20 Oct 2011 13:49:15 -0400")
Message-ID: <m1y5vcxxzp.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: Re: [PATCH -V7 21/26] richacl: xattr mapping functions
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"J. Bruce Fields" <bfields@fieldses.org> writes:

> On Thu, Oct 20, 2011 at 04:32:04PM +0530, Aneesh Kumar K.V wrote:
>> On Thu, 20 Oct 2011 05:19:46 -0400, Christoph Hellwig <hch@infradead.org> wrote:
>> > On Thu, Oct 20, 2011 at 05:14:34AM -0400, J. Bruce Fields wrote:
>> > > > > Does it really make sense to use a string here just to pick between the
>> > > > > three choices OWNER@, GROUP@, and EVERYONE@?  Why not just another small
>> > > > > integer?  Is the goal to expand this somehow eventually?
>> > > > 
>> > 
>> > > > I guess Andreas wanted the disk layout to be able to store user@domain
>> > > > format if needed.
>> > > 
>> > > Is that likely?  For that to be useful, tasks would need to be able to
>> > > run as user@domain strings.  And we'd probably want owners and groups to
>> > > also be user@domain strings.
>> > > 
>> > > The container people seem to eventually want to add some kind of
>> > > namespace identifier everywhere:
>> > > 
>> > > 	http://marc.info/?l=linux-kernel&m=131836778427871&w=2
>> > > 
>> > > in which case I guess we'd likely end up with (uid, user namespace id)
>> > > instead of user@domain?
>> > 
>> > 
>> > Storing strings is an extremly stupid idea.  The only thing that would
>> > make sense would be storing a windows-style 128-bit GUID.
>> > 
>> 
>> How about updating the richacl_xattr as below 
>> 
>> struct richace_xattr {
>> 	__le16		e_type;
>> 	__le16		e_flags;
>> 	__le32		e_mask;
>> 	__le32		e_size;
>> 	u8		e_id[0];
>> };
>> 
>> now e_flags can contain ACE4_SPECIAL_WHO to indicate value in e_id
>> indicate special who values (which could be 1 byte value indicating
>> OWNER@, GROUP@ or EVERYONE@), ACE4_UNIXID_WHO, to indicate value
>> in e_id is the little endian value of unix id. ACE_WINSID_WHO to
>> indicate e_id is the 128 bit array containing SID value. ?
>
> That's effectively still a string.
>
> Would it be so bad to have to introduce another xattr type if we needed
> a new id type?  You'll have to modify the filesystem and the userspace
> tools and everything anyway, won't you?
>
> But if we decide we don't need strings, then at a minimum let's make
> these some fixed small size.
>
> You could do something like:
>
> 	struct richace_xattr {
> 		__le16		e_type;
> 		__le16		e_flags;
> 		__le32		e_mask;
> 		__le32		e_id[4];
> 	}
>
> and just use e_id[0] for now.  That would still leave room for a 128-bit
> id, or for a 32-bit uid + some-size namespace-id.
>
> Cc'ing Eric Biederman in hopes of finding out whether that would satifsy
> whatever wacky future ideas might be expected for user namespaces.

Thanks for the cc.  After looking at the user namespace issues it looks
like the sane thing is really to map the user namespace uids into
appropriate uids for storing on the filesystem.  Anything else
seems to be a lot of pain for very little gain.

If a filesystem went as far as storing string ids.  I think I would
be happy to use different domains for different user namespaces, but
for anything else I just don't see the point.

What it does look like to me is that at some point we will want to
support > 32bit uids.  There are 7 billion people on the planet and we
only have 4 billion user ids.  The biggest individual organization have
3 million users, which keeps us safe for now.  However my forecast is
each user namespace is going to wind up giving each user a bunch of
uids.  That will accelerate the point at which we find 32bit uids tight.
How fast being generous and assigning 10k uids per user is going to get
us into trouble I don't know. 

Eric
