Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39671 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751268Ab1JTJOn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Oct 2011 05:14:43 -0400
Date: Thu, 20 Oct 2011 05:14:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: agruen@kernel.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk,
        dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V7 21/26] richacl: xattr mapping functions
Message-ID: <20111020091434.GC5444@fieldses.org>
References: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1318951981-5508-22-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20111019222021.GB1874@fieldses.org>
 <87k4805alx.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87k4805alx.fsf@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 20, 2011 at 02:00:02PM +0530, Aneesh Kumar K.V wrote:
> On Wed, 19 Oct 2011 18:20:21 -0400, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > On Tue, Oct 18, 2011 at 09:02:56PM +0530, Aneesh Kumar K.V wrote:
> > > +#define RICHACL_XATTR "system.richacl"
> > > +
> > > +struct richace_xattr {
> > > +	__le16		e_type;
> > > +	__le16		e_flags;
> > > +	__le32		e_mask;
> > > +	__le32		e_id;
> > > +	char		e_who[0];
> > > +};
> > 
> > Does it really make sense to use a string here just to pick between the
> > three choices OWNER@, GROUP@, and EVERYONE@?  Why not just another small
> > integer?  Is the goal to expand this somehow eventually?
> 
> I guess Andreas wanted the disk layout to be able to store user@domain
> format if needed.

Is that likely?  For that to be useful, tasks would need to be able to
run as user@domain strings.  And we'd probably want owners and groups to
also be user@domain strings.

The container people seem to eventually want to add some kind of
namespace identifier everywhere:

	http://marc.info/?l=linux-kernel&m=131836778427871&w=2

in which case I guess we'd likely end up with (uid, user namespace id)
instead of user@domain?

I suppose the variable-length string field could store that too.

I don't hate the idea, it would make life easier for the NFS server.

--b.

> That should make the layout flexible enough so that
> we won't have to add another xattr later.
