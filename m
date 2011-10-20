Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e8.ny.us.ibm.com ([32.97.182.138]:41458 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751723Ab1JTIaM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Oct 2011 04:30:12 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: agruen@kernel.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk,
        dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V7 21/26] richacl: xattr mapping functions
In-Reply-To: <20111019222021.GB1874@fieldses.org>
References: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1318951981-5508-22-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20111019222021.GB1874@fieldses.org>
Date: Thu, 20 Oct 2011 14:00:02 +0530
Message-ID: <87k4805alx.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 19 Oct 2011 18:20:21 -0400, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Tue, Oct 18, 2011 at 09:02:56PM +0530, Aneesh Kumar K.V wrote:
> > +#define RICHACL_XATTR "system.richacl"
> > +
> > +struct richace_xattr {
> > +	__le16		e_type;
> > +	__le16		e_flags;
> > +	__le32		e_mask;
> > +	__le32		e_id;
> > +	char		e_who[0];
> > +};
> 
> Does it really make sense to use a string here just to pick between the
> three choices OWNER@, GROUP@, and EVERYONE@?  Why not just another small
> integer?  Is the goal to expand this somehow eventually?

I guess Andreas wanted the disk layout to be able to store user@domain
format if needed. That should make the layout flexible enough so that
we won't have to add another xattr later.

-aneesh
