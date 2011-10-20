Return-Path: linux-nfs-owner@vger.kernel.org
Received: from idcmail-mo2no.shaw.ca ([64.59.134.9]:51795 "EHLO
	idcmail-mo2no.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751326Ab1JTTtd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Oct 2011 15:49:33 -0400
Subject: Re: [PATCH -V7 21/26] richacl: xattr mapping functions
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <20111020174915.GA9987@fieldses.org>
Date: Thu, 20 Oct 2011 13:49:33 -0600
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
        Christoph Hellwig <hch@infradead.org>, agruen@kernel.org,
        akpm@linux-foundation.org, viro@zeniv.linux.org.uk,
        dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        ebiederm@xmission.com
Message-Id: <E394C0CC-6124-42FD-9962-A061DC4784E3@dilger.ca>
References: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1318951981-5508-22-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20111019222021.GB1874@fieldses.org> <87k4805alx.fsf@linux.vnet.ibm.com> <20111020091434.GC5444@fieldses.org> <20111020091946.GA23773@infradead.org> <87aa8w53kj.fsf@linux.vnet.ibm.com> <20111020174915.GA9987@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-10-20, at 11:49 AM, J. Bruce Fields wrote:
> On Thu, Oct 20, 2011 at 04:32:04PM +0530, Aneesh Kumar K.V wrote:
>> On Thu, 20 Oct 2011 05:19:46 -0400, Christoph Hellwig <hch@infradead.org> wrote:
>>> Storing strings is an extremly stupid idea.  The only thing that would
>>> make sense would be storing a windows-style 128-bit GUID.
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

Just as an FYI, from back when we were trying to port Lustre to Solaris,
Solaris itself uses a 64-bit "FUID" (32-bit UID + 32-bit namespace) to
handle this.

It has a table for arbitrary mapping of 128-bit Windows domains to a
32-bit FUID namespace (don't know much detail here, sorry), and it is
(reasonably) expected that a single system will not be in more than
2^32 namespaces at once.  This keeps the datatypes sane (u64 or 2x u32)
and doesn't put much complexity into the filesystem/kernel.  For most
uses, the high 32-bit value is 0 (local Unix domain).

Cheers, Andreas





