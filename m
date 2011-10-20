Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e4.ny.us.ibm.com ([32.97.182.144]:53858 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752043Ab1JTLF6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Oct 2011 07:05:58 -0400
Received: from /spool/local
	by e4.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 20 Oct 2011 07:03:45 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: agruen@kernel.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk,
        dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V7 21/26] richacl: xattr mapping functions
In-Reply-To: <20111020091946.GA23773@infradead.org>
References: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1318951981-5508-22-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20111019222021.GB1874@fieldses.org> <87k4805alx.fsf@linux.vnet.ibm.com> <20111020091434.GC5444@fieldses.org> <20111020091946.GA23773@infradead.org>
Date: Thu, 20 Oct 2011 16:32:04 +0530
Message-ID: <87aa8w53kj.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 20 Oct 2011 05:19:46 -0400, Christoph Hellwig <hch@infradead.org> wrote:
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

How about updating the richacl_xattr as below 

struct richace_xattr {
	__le16		e_type;
	__le16		e_flags;
	__le32		e_mask;
	__le32		e_size;
	u8		e_id[0];
};

now e_flags can contain ACE4_SPECIAL_WHO to indicate value in e_id
indicate special who values (which could be 1 byte value indicating
OWNER@, GROUP@ or EVERYONE@), ACE4_UNIXID_WHO, to indicate value
in e_id is the little endian value of unix id. ACE_WINSID_WHO to
indicate e_id is the 128 bit array containing SID value. ?

-aneesh

