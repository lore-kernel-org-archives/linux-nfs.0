Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43234 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752146Ab1JUApi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Oct 2011 20:45:38 -0400
Date: Thu, 20 Oct 2011 20:45:29 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andreas Gruenbacher <agruen@kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
        akpm@linux-foundation.org, viro@zeniv.linux.org.uk,
        dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V7 21/26] richacl: xattr mapping functions
Message-ID: <20111021004529.GA12745@fieldses.org>
References: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1318951981-5508-22-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20111019222021.GB1874@fieldses.org>
 <87k4805alx.fsf@linux.vnet.ibm.com>
 <20111020091434.GC5444@fieldses.org>
 <20111020091946.GA23773@infradead.org>
 <20111020102538.GG5444@fieldses.org>
 <1319154390.2270.52.camel@schurl.linbit>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1319154390.2270.52.camel@schurl.linbit>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 21, 2011 at 01:46:29AM +0200, Andreas Gruenbacher wrote:
> On Thu, 2011-10-20 at 06:25 -0400, J. Bruce Fields wrote:
> > So if we want to do this without strings:
> > 
> > > > > +struct richace_xattr {
> > > > > + __le16          e_type;
> > > > > + __le16          e_flags;
> > > > > + __le32          e_mask;
> > > > > + __le32          e_id;
> > > > > + char            e_who[0];
> > 
> > We could drop that last field and use some predefined values for e_id to
> > represent owner/group/everyone in the e_type == ACE4_SPECIAL_WHO case.
> 
> That makes sense to me.
> 
> There seems to be a WELL_KNOWN_SID_TYPE enumeration which maps those
> kinds of special identifiers to small integers in Windows; maybe it
> makes sense to use the same numbers for OWNER@, GROUP@, and EVERYONE@.
> 
> > Then I'm not sure how you'd extend it if you later decided to add
> > Windows GUID's or whatever.
> > 
> > But maybe it's not realistic to expect to be able to do that without a
> > new interface and on-disk format: how could old software be expected to
> > deal with acls that didn't use uid's?
> 
> The acl itself has a version field, so new formats could be introduced
> in the future with a new version.

OK, sounds good.  So let's just assume uid's, and wait to deal with
anything more complicated until we know what's going to happen.  Aneesh,
does that sound good?

And then I think the patches are ready....

--b.
